-- ==============================================================================
-- Phase 5 Migration: Notifications, Triggers & Report Snapshots
-- Project Khata (প্রজেক্ট খাতা)
-- ==============================================================================

-- 1. Align notifications table schema with PRD requirements
alter table notifications add column if not exists organization_id uuid references organizations(id) on delete cascade;
alter table notifications add column if not exists type text;
alter table notifications add column if not exists data jsonb default '{}'::jsonb;
alter table notifications add column if not exists is_read boolean not null default false;

-- Sync existing data if any
update notifications set organization_id = org_id where organization_id is null and org_id is not null;
update notifications set type = kind where type is null and kind is not null;
update notifications set is_read = (read_at is not null) where is_read is false and read_at is not null;

-- Indexes for performant user inbox queries
create index if not exists idx_notifications_user_read on notifications(user_id, is_read, created_at desc);
create index if not exists idx_notifications_org on notifications(organization_id, created_at desc);

-- Enable Row Level Security (RLS)
alter table notifications enable row level security;

-- Drop old policies if existing
drop policy if exists "Users can view their own notifications" on notifications;
drop policy if exists "Users can update their own notifications" on notifications;
drop policy if exists "Users can insert notifications in their organization" on notifications;

-- RLS Policies
create policy "Users can view their own notifications"
  on notifications for select
  using (user_id = auth.uid());

create policy "Users can update their own notifications"
  on notifications for update
  using (user_id = auth.uid())
  with check (user_id = auth.uid());

create policy "Users can insert notifications in their organization"
  on notifications for insert
  with check (
    organization_id in (
      select organization_id from profiles where id = auth.uid()
    )
  );

-- Enable Realtime
do $$
begin
  if not exists (
    select 1 from pg_publication_tables
    where pubname = 'supabase_realtime' and schemaname = 'public' and tablename = 'notifications'
  ) then
    alter publication supabase_realtime add table notifications;
  end if;
end;
$$;

-- ==============================================================================
-- Automated Notification Triggers
-- ==============================================================================

-- Trigger 1: Supervisor Assignment / Unassignment Notifications
create or replace function fn_notify_supervisor_assignment()
returns trigger as $$
declare
  v_proj_name text;
begin
  select name into v_proj_name from projects where id = new.project_id;

  if (TG_OP = 'INSERT') and new.unassigned_at is null then
    insert into notifications (organization_id, user_id, type, title, body, data)
    values (
      new.organization_id,
      new.supervisor_id,
      'assignment_changed',
      'নতুন প্রজেক্টে দায়িত্ব দেওয়া হয়েছে',
      coalesce(v_proj_name, 'প্রজেক্ট') || ' প্রজেক্টে আপনাকে সুপারভাইজার হিসেবে নিযুক্ত করা হয়েছে।',
      jsonb_build_object('project_id', new.project_id)
    );
  elsif (TG_OP = 'UPDATE') and old.unassigned_at is null and new.unassigned_at is not null then
    insert into notifications (organization_id, user_id, type, title, body, data)
    values (
      new.organization_id,
      new.supervisor_id,
      'assignment_changed',
      'প্রজেক্ট অ্যাসাইনমেন্ট সরানো হয়েছে',
      coalesce(v_proj_name, 'প্রজেক্ট') || ' প্রজেক্ট থেকে আপনার সুপারভাইজার দায়িত্ব প্রত্যাহার করা হয়েছে।',
      jsonb_build_object('project_id', new.project_id)
    );
  end if;
  return new;
end;
$$ language plpgsql security definer;

drop trigger if exists trg_notify_supervisor_assignment on supervisor_assignments;
create trigger trg_notify_supervisor_assignment
after insert or update of unassigned_at on supervisor_assignments
for each row execute function fn_notify_supervisor_assignment();

-- Trigger 2: Daily Entry Opened Notification to Contractor
create or replace function fn_notify_daily_entry_opened()
returns trigger as $$
declare
  v_proj_name text;
  v_contractor_id uuid;
begin
  select name into v_proj_name from projects where id = new.project_id;
  select owner_id into v_contractor_id from organizations where id = new.organization_id;

  if v_contractor_id is not null and (new.supervisor_id is not null and new.supervisor_id != v_contractor_id) then
    insert into notifications (organization_id, user_id, type, title, body, data)
    values (
      new.organization_id,
      v_contractor_id,
      'entry_opened',
      'দৈনিক এন্ট্রি খোলা হয়েছে',
      coalesce(v_proj_name, 'প্রজেক্ট') || ' এ ' || to_char(new.entry_date, 'DD/MM/YYYY') || ' তারিখের এন্ট্রি খোলা হয়েছে।',
      jsonb_build_object('entry_id', new.id, 'project_id', new.project_id)
    );
  end if;

  return new;
end;
$$ language plpgsql security definer;

drop trigger if exists trg_notify_daily_entry_opened on daily_entries;
create trigger trg_notify_daily_entry_opened
after insert on daily_entries
for each row execute function fn_notify_daily_entry_opened();

-- Trigger 3: Outside Site Attendance Warning to Contractor
create or replace function fn_notify_outside_site_attendance()
returns trigger as $$
declare
  v_contractor_id uuid;
  v_worker_name text;
  v_proj_name text;
begin
  if new.location_status = 'outside_site' and (TG_OP = 'INSERT' or (TG_OP = 'UPDATE' and old.location_status != 'outside_site')) then
    select owner_id into v_contractor_id from organizations where id = new.organization_id;
    select name into v_worker_name from profiles where id = new.worker_id;
    select name into v_proj_name from projects where id = new.project_id;

    if v_contractor_id is not null then
      insert into notifications (organization_id, user_id, type, title, body, data)
      values (
        new.organization_id,
        v_contractor_id,
        'outside_site_attendance',
        'সাইটের বাইরে হাজিরা সতর্কবার্তা',
        coalesce(v_worker_name, 'কর্মী') || ' ' || coalesce(v_proj_name, 'প্রজেক্ট') || ' সাইটের বাইরে থেকে হাজিরা দিয়েছেন। অনুমোদন প্রয়োজন।',
        jsonb_build_object('attendance_id', new.id, 'project_id', new.project_id, 'worker_id', new.worker_id)
      );
    end if;
  end if;

  return new;
end;
$$ language plpgsql security definer;

drop trigger if exists trg_notify_outside_site_attendance on attendance_records;
create trigger trg_notify_outside_site_attendance
after insert or update of location_status on attendance_records
for each row execute function fn_notify_outside_site_attendance();

-- Trigger 4: Bill Statement Sent Notification to Client
create or replace function fn_notify_bill_statement_sent()
returns trigger as $$
declare
  v_client_id uuid;
  v_proj_name text;
begin
  if new.sent_to_client_at is not null and (TG_OP = 'INSERT' or (TG_OP = 'UPDATE' and old.sent_to_client_at is null)) then
    select client_id, name into v_client_id, v_proj_name from projects where id = new.project_id;

    if v_client_id is not null then
      insert into notifications (organization_id, user_id, type, title, body, data)
      values (
        new.organization_id,
        v_client_id,
        'bill_statement_sent',
        'নতুন বিল স্টেটমেন্ট পাঠানো হয়েছে',
        coalesce(v_proj_name, 'প্রজেক্ট') || ' এর ' || to_char(new.period_from, 'DD/MM/YYYY') || ' হতে ' || to_char(new.period_to, 'DD/MM/YYYY') || ' সময়কালের বিল খতিয়ান পাঠানো হয়েছে।',
        jsonb_build_object('statement_id', new.id, 'project_id', new.project_id)
      );
    end if;
  end if;

  return new;
end;
$$ language plpgsql security definer;

drop trigger if exists trg_notify_bill_statement_sent on bill_statements;
create trigger trg_notify_bill_statement_sent
after insert or update of sent_to_client_at on bill_statements
for each row execute function fn_notify_bill_statement_sent();
