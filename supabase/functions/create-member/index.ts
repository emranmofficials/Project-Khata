import { createClient } from "jsr:@supabase/supabase-js@2";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
};

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: corsHeaders });

  try {
    const authHeader = req.headers.get("Authorization");
    if (!authHeader) return json({ error: "Unauthorized" }, 401);

    // ১. কলকারীর পরিচয় যাচাই (তার নিজের টোকেন দিয়ে)
    const userClient = createClient(
      Deno.env.get("SUPABASE_URL")!,
      Deno.env.get("SUPABASE_ANON_KEY")!,
      { global: { headers: { Authorization: authHeader } } },
    );
    const { data: { user }, error: userErr } = await userClient.auth.getUser();
    if (userErr || !user) return json({ error: "Unauthorized" }, 401);

    const { data: caller } = await userClient
      .from("profiles")
      .select("organization_id, role")
      .eq("id", user.id)
      .single();
    if (!caller || caller.role !== "contractor") {
      return json({ error: "শুধু ঠিকাদার ইউজার তৈরি করতে পারবে" }, 403);
    }

    // ২. ইনপুট যাচাই
    const body = await req.json();
    const { name, mobile, role, designation_id } = body as {
      name: string; mobile: string; role: string; designation_id?: string;
    };
    if (!name?.trim()) return json({ error: "নাম আবশ্যক" }, 400);
    if (!/^01[3-9]\d{8}$/.test(mobile ?? "")) {
      return json({ error: "সঠিক বাংলাদেশি মোবাইল নম্বর দিন" }, 400);
    }
    if (!["client", "supervisor", "worker"].includes(role)) {
      return json({ error: "অবৈধ ভূমিকা" }, 400);
    }

    // ৩. Admin client (service-role) — শুধু এই সার্ভারে
    const admin = createClient(
      Deno.env.get("SUPABASE_URL")!,
      Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!,
    );

    // ৪. একই প্রতিষ্ঠানে একই মোবাইল আছে কি না
    const { data: dup } = await admin
      .from("profiles")
      .select("id")
      .eq("organization_id", caller.organization_id)
      .eq("mobile", mobile)
      .maybeSingle();
    if (dup) return json({ error: "এই মোবাইল নম্বর ইতিমধ্যে যুক্ত আছে" }, 409);

    // ৫. প্রাথমিক পাসওয়ার্ড = মোবাইলের শেষ ৬ সংখ্যা
    const initialPassword = mobile.slice(-6);
    const syntheticEmail = `${mobile}@members.projectkhata.app`;

    const { data: created, error: createErr } = await admin.auth.admin.createUser({
      email: syntheticEmail,
      password: initialPassword,
      email_confirm: true,
      user_metadata: { mobile, name },
    });
    if (createErr || !created.user) {
      return json({ error: createErr?.message ?? "ইউজার তৈরি ব্যর্থ" }, 400);
    }

    // ৬. প্রোফাইল যোগ
    const { error: profErr } = await admin.from("profiles").insert({
      id: created.user.id,
      organization_id: caller.organization_id,
      role,
      name: name.trim(),
      mobile,
      designation_id: designation_id ?? null,
      must_change_password: true,
    });
    if (profErr) {
      await admin.auth.admin.deleteUser(created.user.id); // রোলব্যাক
      return json({ error: profErr.message }, 400);
    }

    // ৭. অডিট লগ
    await admin.from("audit_logs").insert({
      organization_id: caller.organization_id,
      actor_id: user.id,
      action: "create_member",
      table_name: "profiles",
      record_id: created.user.id,
      new_data: { name, mobile, role, designation_id },
    });

    return json({ id: created.user.id, mobile, role }, 201);
  } catch (e) {
    return json({ error: String(e) }, 500);
  }
});

function json(payload: unknown, status = 200) {
  return new Response(JSON.stringify(payload), {
    status,
    headers: { ...corsHeaders, "Content-Type": "application/json" },
  });
}
