-- Project Khata | ফেজ ১: অডিট লগ (audit_logs)

create table if not exists public.audit_logs (
  id              uuid primary key default gen_random_uuid(),
  organization_id uuid not null references public.organizations(id) on delete cascade,
  actor_id        uuid references auth.users(id) on delete set null,
  action          text not null,
  table_name      text not null,
  record_id       uuid,
  old_data        jsonb,
  new_data        jsonb,
  created_at      timestamptz not null default now()
);

create index if not exists audit_logs_org_idx on public.audit_logs(organization_id);
create index if not exists audit_logs_created_at_idx on public.audit_logs(created_at desc);

alter table public.audit_logs enable row level security;

create policy audit_logs_select on public.audit_logs
  for select using (organization_id = public.current_org_id() and public.current_role() = 'contractor');
