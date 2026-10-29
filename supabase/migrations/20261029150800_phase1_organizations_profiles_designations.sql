-- Project Khata | ফেজ ১: ফ্রেশ স্কিমা (প্রতিষ্ঠান, প্রোফাইল, পদ)

-- ০. পুরনো টেস্ট টেবিল ও টাইপ পরিষ্কার
drop table if exists public.attendance cascade;
drop table if exists public.materials cascade;
drop table if exists public.expenses cascade;
drop table if exists public.work_logs cascade;
drop table if exists public.workers cascade;
drop table if exists public.supervisor_assignments cascade;
drop table if exists public.daily_entries cascade;
drop table if exists public.projects cascade;
drop table if exists public.users cascade;
drop table if exists public.profiles cascade;
drop table if exists public.designations cascade;
drop table if exists public.organizations cascade;

drop type if exists public.user_role cascade;
drop type if exists public.user_status cascade;

-- ১. প্রতিষ্ঠান (একজন ঠিকাদার = একটি প্রতিষ্ঠান)
create table public.organizations (
  id          uuid primary key default gen_random_uuid(),
  name        text not null,
  address     text,
  logo_url    text,
  phone       text,
  owner_id    uuid not null unique references auth.users(id) on delete restrict,
  created_at  timestamptz not null default now()
);

-- ২. পদ (designation): দৈনিক মজুরি ও ওভারটাইম হার
create table public.designations (
  id                      uuid primary key default gen_random_uuid(),
  organization_id         uuid not null references public.organizations(id) on delete cascade,
  name                    text not null,
  daily_rate              numeric(12,2) not null check (daily_rate >= 0),
  overtime_rate_per_hour  numeric(12,2) not null default 0 check (overtime_rate_per_hour >= 0),
  created_at              timestamptz not null default now(),
  unique (organization_id, name)
);

-- ৩. প্রোফাইল (সব ইউজার, auth.users-এর সাথে যুক্ত)
create type public.user_role as enum ('contractor', 'client', 'supervisor', 'worker');
create type public.user_status as enum ('active', 'inactive');

create table public.profiles (
  id                    uuid primary key references auth.users(id) on delete cascade,
  organization_id       uuid not null references public.organizations(id) on delete cascade,
  role                  public.user_role not null,
  name                  text not null,
  mobile                text,
  email                 text,
  photo_url             text,
  address               text,
  designation_id        uuid references public.designations(id) on delete set null,
  must_change_password  boolean not null default false,
  status                public.user_status not null default 'active',
  created_at            timestamptz not null default now(),
  unique (organization_id, mobile)
);

-- ৪. ইনডেক্স
create index designations_org_idx on public.designations(organization_id);
create index profiles_org_role_idx on public.profiles(organization_id, role);

-- ৫. helper ফাংশন: বর্তমান ইউজারের organization_id ও role
create or replace function public.current_org_id()
returns uuid
language sql stable security definer set search_path = public
as $$
  select organization_id from public.profiles where id = auth.uid();
$$;

create or replace function public.current_role()
returns public.user_role
language sql stable security definer set search_path = public
as $$
  select role from public.profiles where id = auth.uid();
$$;

-- ৬. RLS চালু
alter table public.organizations enable row level security;
alter table public.designations  enable row level security;
alter table public.profiles      enable row level security;

-- organizations: নিজের প্রতিষ্ঠান দেখা; তৈরি ও সম্পাদনা শুধু ঠিকাদার
create policy org_select on public.organizations
  for select using (id = public.current_org_id() or owner_id = auth.uid());

create policy org_insert_owner on public.organizations
  for insert with check (owner_id = auth.uid());

create policy org_update_contractor on public.organizations
  for update using (id = public.current_org_id() and public.current_role() = 'contractor')
  with check (id = public.current_org_id() and public.current_role() = 'contractor');

-- designations: সবাই নিজের প্রতিষ্ঠানের পদ দেখতে পারবে; বদলাতে শুধু ঠিকাদার
create policy designations_select on public.designations
  for select using (organization_id = public.current_org_id());

create policy designations_write_contractor on public.designations
  for all using (organization_id = public.current_org_id() and public.current_role() = 'contractor')
  with check (organization_id = public.current_org_id() and public.current_role() = 'contractor');

-- profiles: নিজের প্রতিষ্ঠানের প্রোফাইল দেখা যাবে; নিজের প্রোফাইল সম্পাদনা; ইনসার্ট/ডিলিট শুধু ঠিকাদার (Edge Function-এর মাধ্যমে)
create policy profiles_select_same_org on public.profiles
  for select using (organization_id = public.current_org_id());

create policy profiles_update_self on public.profiles
  for update using (id = auth.uid())
  with check (id = auth.uid() and role = (select role from public.profiles where id = auth.uid()));

create policy profiles_update_contractor on public.profiles
  for update using (organization_id = public.current_org_id() and public.current_role() = 'contractor')
  with check (organization_id = public.current_org_id() and public.current_role() = 'contractor');
