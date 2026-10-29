-- Project Khata | ফেজ ৩: দৈনিক এন্ট্রি, দল ও হাজিরা (GPS ও জিওফেন্সিং সহ)

-- ১. দূরত্ব পরিমাপ ফাংশন (Haversine সূত্রানুসারে মিটারে)
create or replace function public.calculate_distance_meters(
  lat1 double precision,
  lon1 double precision,
  lat2 double precision,
  lon2 double precision
) returns double precision as $$
declare
  r double precision := 6371000.0; -- পৃথিবীর গড় ব্যাসার্ধ (মিটার)
  phi1 double precision;
  phi2 double precision;
  delta_phi double precision;
  delta_lambda double precision;
  a double precision;
  c double precision;
begin
  if lat1 is null or lon1 is null or lat2 is null or lon2 is null then
    return null;
  end if;
  phi1 := radians(lat1);
  phi2 := radians(lat2);
  delta_phi := radians(lat2 - lat1);
  delta_lambda := radians(lon2 - lon1);
  a := sin(delta_phi / 2.0)^2 + cos(phi1) * cos(phi2) * sin(delta_lambda / 2.0)^2;
  c := 2.0 * atan2(sqrt(a), sqrt(1.0 - a));
  return round((r * c)::numeric, 2)::double precision;
end;
$$ language plpgsql immutable;

-- ২. দৈনিক এন্ট্রি টেবিল
create table if not exists public.daily_entries (
  id                  uuid primary key default gen_random_uuid(),
  organization_id     uuid not null references public.organizations(id) on delete cascade,
  project_id          uuid not null references public.projects(id) on delete cascade,
  supervisor_id       uuid not null references public.profiles(id) on delete cascade,
  entry_date          date not null default current_date,
  work_description    text,
  status              text not null default 'draft' check (status in ('draft', 'submitted', 'approved', 'handover_required')),
  notes               text,
  photos              text[] default array[]::text[],
  created_at          timestamptz not null default now(),
  updated_at          timestamptz not null default now()
);

-- ৩. হাজিরা রেকর্ড টেবিল
create table if not exists public.attendance_records (
  id                  uuid primary key default gen_random_uuid(),
  organization_id     uuid not null references public.organizations(id) on delete cascade,
  daily_entry_id      uuid not null references public.daily_entries(id) on delete cascade,
  project_id          uuid not null references public.projects(id) on delete cascade,
  worker_id           uuid not null references public.profiles(id) on delete cascade,
  entry_date          date not null,
  status              text not null default 'full_day' check (status in ('full_day', 'half_day', 'absent')),
  ot_hours            numeric(4,2) not null default 0.00 check (ot_hours >= 0 and ot_hours <= 24),
  supervisor_lat      double precision,
  supervisor_lng      double precision,
  site_distance_meters double precision,
  location_status     text not null default 'inside_site' check (location_status in ('inside_site', 'outside_site', 'location_unavailable')),
  is_approved         boolean not null default false,
  approved_by         uuid references public.profiles(id),
  approved_at         timestamptz,
  remarks             text,
  created_at          timestamptz not null default now(),
  updated_at          timestamptz not null default now(),
  -- ব্যবসায়িক নিয়ম ২৫ ও ১৫৮: একই তারিখে একজন শ্রমিক শুধুমাত্র একটি প্রজেক্টে হাজিরা দিতে পারবে
  constraint unq_worker_entry_date unique (worker_id, entry_date),
  -- একটি দৈনিক এন্ট্রিতে একজন শ্রমিক একবারই থাকবে
  constraint unq_entry_worker unique (daily_entry_id, worker_id)
);

-- ৪. ইনডেক্স সমূহ
create index if not exists daily_entries_org_idx on public.daily_entries(organization_id);
create index if not exists daily_entries_proj_date_idx on public.daily_entries(project_id, entry_date);
create index if not exists daily_entries_supervisor_idx on public.daily_entries(supervisor_id);
create index if not exists attendance_org_idx on public.attendance_records(organization_id);
create index if not exists attendance_entry_idx on public.attendance_records(daily_entry_id);
create index if not exists attendance_worker_date_idx on public.attendance_records(worker_id, entry_date);
create index if not exists attendance_proj_date_idx on public.attendance_records(project_id, entry_date);

-- ৫. হেল্পার ফাংশন (RLS রিকার্সন প্রতিরোধে security definer)
create or replace function public.is_worker_in_entry(entry_id uuid, user_id uuid)
returns boolean
language sql stable security definer set search_path = public
as $$
  select exists (
    select 1 from public.attendance_records
    where daily_entry_id = entry_id and worker_id = user_id
  );
$$;

-- ৬. ট্রিগার: উপস্থিতির লোকেশন ও দূরত্ব স্বয়ংক্রিয় যাচাই
create or replace function public.process_attendance_location()
returns trigger language plpgsql security definer as $$
declare
  proj record;
  dist double precision;
begin
  select lat, lng, geofence_radius_m into proj
  from public.projects
  where id = new.project_id;

  if new.supervisor_lat is null or new.supervisor_lng is null then
    new.location_status := 'location_unavailable';
    new.site_distance_meters := null;
  elsif proj is not null and proj.lat is not null and proj.lng is not null then
    dist := public.calculate_distance_meters(proj.lat, proj.lng, new.supervisor_lat, new.supervisor_lng);
    new.site_distance_meters := dist;
    if dist <= coalesce(proj.geofence_radius_m, 150) then
      new.location_status := 'inside_site';
    else
      new.location_status := 'outside_site';
    end if;
  end if;
  return new;
end;
$$;

drop trigger if exists trg_attendance_location on public.attendance_records;
create trigger trg_attendance_location
  before insert or update of supervisor_lat, supervisor_lng, project_id
  on public.attendance_records
  for each row
  execute function public.process_attendance_location();

-- ৭. Row Level Security (RLS) চালুকরণ
alter table public.daily_entries enable row level security;
alter table public.attendance_records enable row level security;

-- daily_entries পলিসি:
-- ঠিকাদার: নিজের প্রতিষ্ঠানের সব এন্ট্রি দেখতে ও পরিবর্তন করতে পারবে
create policy daily_entries_contractor_all on public.daily_entries
  for all using (organization_id = public.current_org_id() and public.current_role() = 'contractor')
  with check (organization_id = public.current_org_id() and public.current_role() = 'contractor');

-- সুপারভাইজার: অ্যাসাইন করা প্রজেক্টের এন্ট্রি দেখতে পারবে
create policy daily_entries_supervisor_select on public.daily_entries
  for select using (
    organization_id = public.current_org_id() and
    public.current_role() = 'supervisor' and
    (public.is_assigned_supervisor(project_id, auth.uid()) or supervisor_id = auth.uid())
  );

-- সুপারভাইজার: অ্যাসাইন করা প্রজেক্টে এন্ট্রি তৈরি করতে পারবে
create policy daily_entries_supervisor_insert on public.daily_entries
  for insert with check (
    organization_id = public.current_org_id() and
    public.current_role() = 'supervisor' and
    public.is_assigned_supervisor(project_id, auth.uid()) and
    supervisor_id = auth.uid()
  );

-- সুপারভাইজার: ড্রাফট বা সাবমিটেড এন্ট্রি আপডেট করতে পারবে (অনুমোদিত হলে লক)
create policy daily_entries_supervisor_update on public.daily_entries
  for update using (
    organization_id = public.current_org_id() and
    public.current_role() = 'supervisor' and
    supervisor_id = auth.uid() and
    status in ('draft', 'submitted')
  ) with check (
    organization_id = public.current_org_id() and
    public.current_role() = 'supervisor' and
    supervisor_id = auth.uid() and
    status in ('draft', 'submitted')
  );

-- শ্রমিক: যে এন্ট্রিতে তার হাজিরা রয়েছে তা দেখতে পারবে
create policy daily_entries_worker_select on public.daily_entries
  for select using (
    organization_id = public.current_org_id() and
    public.current_role() = 'worker' and
    public.is_worker_in_entry(id, auth.uid())
  );

-- attendance_records পলিসি:
-- ঠিকাদার: সম্পূর্ণ প্রবেশাধিকার
create policy attendance_contractor_all on public.attendance_records
  for all using (organization_id = public.current_org_id() and public.current_role() = 'contractor')
  with check (organization_id = public.current_org_id() and public.current_role() = 'contractor');

-- সুপারভাইজার: অ্যাসাইন করা প্রজেক্টের হাজিরা দেখতে পারবে
create policy attendance_supervisor_select on public.attendance_records
  for select using (
    organization_id = public.current_org_id() and
    public.current_role() = 'supervisor' and
    public.is_assigned_supervisor(project_id, auth.uid())
  );

-- সুপারভাইজার: আনলকড এন্ট্রির জন্য হাজিরা যোগ করতে পারবে
create policy attendance_supervisor_insert on public.attendance_records
  for insert with check (
    organization_id = public.current_org_id() and
    public.current_role() = 'supervisor' and
    public.is_assigned_supervisor(project_id, auth.uid())
  );

-- সুপারভাইজার: আনলকড এন্ট্রির হাজিরা সংশোধন করতে পারবে
create policy attendance_supervisor_update on public.attendance_records
  for update using (
    organization_id = public.current_org_id() and
    public.current_role() = 'supervisor' and
    public.is_assigned_supervisor(project_id, auth.uid())
  ) with check (
    organization_id = public.current_org_id() and
    public.current_role() = 'supervisor' and
    public.is_assigned_supervisor(project_id, auth.uid())
  );

-- শ্রমিক: শুধু নিজের হাজিরা দেখতে পারবে (ক্লায়েন্ট কোনো হাজিরা দেখতে পারবে না - PRD 176)
create policy attendance_worker_select on public.attendance_records
  for select using (
    organization_id = public.current_org_id() and
    public.current_role() = 'worker' and
    worker_id = auth.uid()
  );

-- ৮. সাইট ফটোর জন্য স্টোরেজ বাকেট
insert into storage.buckets (id, name, public)
values ('site-photos', 'site-photos', true)
on conflict (id) do nothing;

create policy "site_photos_public_select" on storage.objects
  for select using (bucket_id = 'site-photos');

create policy "site_photos_auth_insert" on storage.objects
  for insert with check (bucket_id = 'site-photos' and auth.role() = 'authenticated');
