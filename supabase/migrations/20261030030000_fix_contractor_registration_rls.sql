-- Fix contractor registration: profiles insert policy & atomic registration function

-- 1. Add insert and select policy on profiles for self registration & lookup
drop policy if exists profiles_insert_self on public.profiles;
create policy profiles_insert_self on public.profiles
  for insert with check (id = auth.uid());

drop policy if exists profiles_select_same_org on public.profiles;
drop policy if exists profiles_select on public.profiles;
create policy profiles_select on public.profiles
  for select using (id = auth.uid() or organization_id = public.current_org_id());

-- 2. Verify organizations insert policy
drop policy if exists org_insert_owner on public.organizations;
create policy org_insert_owner on public.organizations
  for insert with check (owner_id = auth.uid());

-- 3. Atomic registration function for contractors
create or replace function public.register_contractor(
  p_org_name text,
  p_org_address text default null,
  p_org_phone text default null,
  p_name text default null
) returns json language plpgsql security definer set search_path = public as $$
declare
  v_user_id uuid;
  v_org_id uuid;
  v_user_email text;
  v_profile record;
begin
  v_user_id := auth.uid();
  if v_user_id is null then
    raise exception 'Unauthorized: User is not authenticated';
  end if;

  -- Fetch user email from auth.users
  select email into v_user_email from auth.users where id = v_user_id;

  -- 1. Create Organization
  insert into public.organizations (name, address, phone, owner_id)
  values (p_org_name, p_org_address, p_org_phone, v_user_id)
  returning id into v_org_id;

  -- 2. Create Contractor Profile
  insert into public.profiles (
    id, organization_id, role, name, email, mobile, must_change_password, status
  ) values (
    v_user_id,
    v_org_id,
    'contractor'::user_role,
    coalesce(p_name, 'Contractor'),
    v_user_email,
    p_org_phone,
    false,
    'active'::user_status
  )
  returning * into v_profile;

  return json_build_object(
    'id', v_profile.id,
    'organization_id', v_profile.organization_id,
    'role', v_profile.role,
    'name', v_profile.name,
    'email', v_profile.email,
    'mobile', v_profile.mobile,
    'must_change_password', v_profile.must_change_password,
    'status', v_profile.status
  );
end;
$$;

grant execute on function public.register_contractor to authenticated;

-- 4. Clean up any orphaned auth users without an organization or profile
delete from auth.users
where id not in (select id from public.profiles)
  and id not in (select owner_id from public.organizations);
