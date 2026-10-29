-- Project Khata | ফেজ ২: প্রজেক্ট ও সুপারভাইজার অ্যাসাইনমেন্ট

-- ১. প্রজেক্ট টেবিল (৩ ধরন: sqft, contract, daily)
create table if not exists public.projects (
  id                  uuid primary key default gen_random_uuid(),
  organization_id     uuid not null references public.organizations(id) on delete cascade,
  client_id           uuid not null references public.profiles(id) on delete restrict,
  name                text not null,
  type                text not null check (type in ('sqft', 'contract', 'daily')),
  address             text,
  lat                 double precision not null,
  lng                 double precision not null,
  geofence_radius_m   integer not null default 150 check (geofence_radius_m between 100 and 200),
  start_date          date not null default current_date,
  end_date            date,
  status              text not null default 'active' check (status in ('planned', 'active', 'completed', 'on_hold')),
  budget              numeric(14,2) default 0,
  rate_per_sqft       numeric(12,2),
  total_sqft          numeric(12,2),
  daily_wage          numeric(12,2),
  note                text,
  created_at          timestamptz not null default now()
);

-- ২. সুপারভাইজার অ্যাসাইনমেন্ট টেবিল
create table if not exists public.supervisor_assignments (
  id              uuid primary key default gen_random_uuid(),
  organization_id uuid not null references public.organizations(id) on delete cascade,
  project_id      uuid not null references public.projects(id) on delete cascade,
  supervisor_id   uuid not null references public.profiles(id) on delete cascade,
  assigned_at     timestamptz not null default now(),
  unassigned_at   timestamptz,
  check (unassigned_at is null or unassigned_at >= assigned_at)
);

-- ৩. ইনডেক্স
create index if not exists projects_org_idx on public.projects(organization_id);
create index if not exists projects_client_idx on public.projects(client_id);
create index if not exists supervisor_assignments_proj_idx on public.supervisor_assignments(project_id);
create index if not exists supervisor_assignments_sup_idx on public.supervisor_assignments(supervisor_id);

-- ৪. হেল্পার ফাংশন: সুপারভাইজার অ্যাসাইনমেন্ট যাচাই
create or replace function public.is_assigned_supervisor(proj_id uuid, user_id uuid)
returns boolean
language sql stable security definer set search_path = public
as $$
  select exists (
    select 1 from public.supervisor_assignments
    where project_id = proj_id
      and supervisor_id = user_id
      and unassigned_at is null
  );
$$;

-- ৫. RLS চালু
alter table public.projects               enable row level security;
alter table public.supervisor_assignments enable row level security;

-- projects RLS:
-- ঠিকাদার: নিজের প্রতিষ্ঠানের সব প্রজেক্ট
-- ক্লায়েন্ট: নিজের প্রজেক্ট
-- সুপারভাইজার: সক্রিয় অ্যাসাইন করা প্রজেক্ট
-- শ্রমিক: প্রতিষ্ঠানের সক্রিয় প্রজেক্ট (হাজিরার জন্য প্রজেক্ট সিলেক্ট করতে)
create policy projects_select on public.projects
  for select using (
    (organization_id = public.current_org_id() and public.current_role() = 'contractor') or
    (client_id = auth.uid()) or
    (organization_id = public.current_org_id() and public.current_role() = 'supervisor' and public.is_assigned_supervisor(id, auth.uid())) or
    (organization_id = public.current_org_id() and public.current_role() = 'worker' and status = 'active')
  );

create policy projects_contractor_all on public.projects
  for all using (organization_id = public.current_org_id() and public.current_role() = 'contractor')
  with check (organization_id = public.current_org_id() and public.current_role() = 'contractor');

-- supervisor_assignments RLS:
create policy supervisor_assignments_select on public.supervisor_assignments
  for select using (
    (organization_id = public.current_org_id() and public.current_role() = 'contractor') or
    (supervisor_id = auth.uid())
  );

create policy supervisor_assignments_contractor on public.supervisor_assignments
  for all using (organization_id = public.current_org_id() and public.current_role() = 'contractor')
  with check (organization_id = public.current_org_id() and public.current_role() = 'contractor');
