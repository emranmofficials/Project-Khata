-- ==============================================================================
-- Migration: Phase 4 - Accounts, Wages, FIFO Allocations, Materials & Ledgers
-- Description:
--   1. wage_ledger: Date-wise worker/supervisor earned wage and overtime ledger.
--   2. payments: Organization payments to workers and supervisors.
--   3. payment_allocations: FIFO or manual allocation of payments to projects/wages.
--   4. client_payments: Client billing and payment tracking for projects.
--   5. materials: Project materials purchasing and usage records.
--   6. expenses: Project-level sundry expenses.
--   7. bill_statements: Worker-bill ledger statements with client-facing snapshots.
-- ==============================================================================

-- 1. Wage Ledger (মজুরি ও ওভারটাইম হিসাব খতিয়ান)
create table if not exists wage_ledger (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid not null references organizations(id) on delete cascade,
  project_id uuid not null references projects(id) on delete cascade,
  worker_id uuid not null references profiles(id) on delete cascade,
  work_date date not null,
  attendance_id uuid references attendance_records(id) on delete set null,
  earned_amount numeric(12, 2) not null default 0.00 check (earned_amount >= 0),
  overtime_amount numeric(12, 2) not null default 0.00 check (overtime_amount >= 0),
  total_earned numeric(12, 2) generated always as (earned_amount + overtime_amount) stored,
  is_paid boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint uq_wage_ledger_worker_date unique (worker_id, work_date)
);

create index if not exists idx_wage_ledger_org_proj on wage_ledger(organization_id, project_id);
create index if not exists idx_wage_ledger_worker on wage_ledger(worker_id, work_date);
create index if not exists idx_wage_ledger_date on wage_ledger(work_date desc);

-- 2. Trigger function to auto-sync wage_ledger from attendance_records
create or replace function sync_wage_ledger_from_attendance()
returns trigger
language plpgsql
security definer
as $$
declare
  v_daily_rate numeric(12, 2) := 0.00;
  v_ot_rate numeric(12, 2) := 0.00;
  v_status_mult numeric(3, 2) := 0.00;
  v_earned numeric(12, 2) := 0.00;
  v_overtime numeric(12, 2) := 0.00;
begin
  -- Fetch worker designation rates
  select coalesce(d.daily_rate, 0.00), coalesce(d.overtime_rate_per_hour, 0.00)
  into v_daily_rate, v_ot_rate
  from profiles p
  left join designations d on d.id = p.designation_id
  where p.id = NEW.worker_id;

  -- Multipliers: full_day=1.0x, half_day=0.5x, absent=0.0x
  if NEW.status = 'full_day' then
    v_status_mult := 1.00;
  elsif NEW.status = 'half_day' then
    v_status_mult := 0.50;
  else
    v_status_mult := 0.00;
  end if;

  v_earned := round(v_status_mult * v_daily_rate, 2);
  v_overtime := round(coalesce(NEW.ot_hours, 0.00) * v_ot_rate, 2);

  insert into wage_ledger (
    organization_id,
    project_id,
    worker_id,
    work_date,
    attendance_id,
    earned_amount,
    overtime_amount,
    updated_at
  )
  values (
    NEW.organization_id,
    NEW.project_id,
    NEW.worker_id,
    NEW.entry_date,
    NEW.id,
    v_earned,
    v_overtime,
    now()
  )
  on conflict (worker_id, work_date) do update set
    project_id = excluded.project_id,
    attendance_id = excluded.attendance_id,
    earned_amount = excluded.earned_amount,
    overtime_amount = excluded.overtime_amount,
    updated_at = now();

  return NEW;
end;
$$;

drop trigger if exists trg_sync_wage_from_attendance on attendance_records;
create trigger trg_sync_wage_from_attendance
after insert or update on attendance_records
for each row
execute function sync_wage_ledger_from_attendance();

-- 3. Payments table (মজুরি ও বেতন প্রদান)
create table if not exists payments (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid not null references organizations(id) on delete cascade,
  payee_type text not null default 'worker' check (payee_type in ('worker', 'supervisor')),
  payee_id uuid not null references profiles(id) on delete cascade,
  amount numeric(12, 2) not null check (amount > 0),
  payment_date date not null default current_date,
  payment_method text not null default 'cash' check (payment_method in ('cash', 'bkash', 'nagad', 'bank')),
  note text,
  created_by uuid not null references profiles(id),
  created_at timestamptz not null default now()
);

create index if not exists idx_payments_org on payments(organization_id);
create index if not exists idx_payments_payee on payments(payee_id, payment_date desc);

-- 4. Payment Allocations (প্রজেক্টভিত্তিক মজুরি বরাদ্দ - FIFO / Manual)
create table if not exists payment_allocations (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid not null references organizations(id) on delete cascade,
  payment_id uuid not null references payments(id) on delete cascade,
  project_id uuid not null references projects(id) on delete cascade,
  wage_ledger_id uuid not null references wage_ledger(id) on delete cascade,
  allocated_amount numeric(12, 2) not null check (allocated_amount > 0),
  method text not null default 'fifo' check (method in ('fifo', 'manual')),
  created_at timestamptz not null default now()
);

create index if not exists idx_allocations_payment on payment_allocations(payment_id);
create index if not exists idx_allocations_project on payment_allocations(project_id);
create index if not exists idx_allocations_wage on payment_allocations(wage_ledger_id);

-- 5. Stored Procedure for Automatic FIFO Allocation
create or replace function allocate_payment_fifo(
  p_payment_id uuid
)
returns void
language plpgsql
security definer
as $$
declare
  v_payee_id uuid;
  v_org_id uuid;
  v_remaining_amount numeric(12, 2);
  v_rec record;
  v_to_allocate numeric(12, 2);
begin
  select payee_id, organization_id, amount
  into v_payee_id, v_org_id, v_remaining_amount
  from payments
  where id = p_payment_id;

  if not found or v_remaining_amount <= 0 then
    return;
  end if;

  -- Clear previous allocations if re-allocating
  delete from payment_allocations where payment_id = p_payment_id;

  -- Find unpaid or partially paid wages in FIFO order (oldest work_date first)
  for v_rec in
    select
      wl.id as wage_id,
      wl.project_id,
      wl.total_earned,
      coalesce(sum(pa.allocated_amount), 0.00) as already_allocated
    from wage_ledger wl
    left join payment_allocations pa on pa.wage_ledger_id = wl.id
    where wl.worker_id = v_payee_id and wl.organization_id = v_org_id
    group by wl.id, wl.project_id, wl.total_earned, wl.work_date
    having (wl.total_earned - coalesce(sum(pa.allocated_amount), 0.00)) > 0
    order by wl.work_date asc
  loop
    exit when v_remaining_amount <= 0;

    v_to_allocate := least(v_remaining_amount, v_rec.total_earned - v_rec.already_allocated);

    if v_to_allocate > 0 then
      insert into payment_allocations (
        organization_id,
        payment_id,
        project_id,
        wage_ledger_id,
        allocated_amount,
        method
      ) values (
        v_org_id,
        p_payment_id,
        v_rec.project_id,
        v_rec.wage_id,
        v_to_allocate,
        'fifo'
      );

      v_remaining_amount := v_remaining_amount - v_to_allocate;

      -- Mark wage paid if settled
      if (v_rec.already_allocated + v_to_allocate) >= v_rec.total_earned then
        update wage_ledger set is_paid = true where id = v_rec.wage_id;
      end if;
    end if;
  end loop;
end;
$$;

-- 6. Client Payments (ক্লায়েন্ট বিল ও পেমেন্ট খতিয়ান)
create table if not exists client_payments (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid not null references organizations(id) on delete cascade,
  project_id uuid not null references projects(id) on delete cascade,
  amount numeric(12, 2) not null check (amount > 0),
  payment_date date not null default current_date,
  payment_method text not null default 'bank' check (payment_method in ('cash', 'bank', 'cheque', 'bkash', 'nagad')),
  reference_no text,
  note text,
  receipt_url text,
  received_by uuid not null references profiles(id),
  created_at timestamptz not null default now()
);

create index if not exists idx_client_payments_project on client_payments(project_id, payment_date desc);

-- 7. Materials (মালামাল ক্রয় ও ব্যবহার হিসাব)
create table if not exists materials (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid not null references organizations(id) on delete cascade,
  project_id uuid not null references projects(id) on delete cascade,
  name text not null,
  unit text not null default 'বস্তা',
  qty numeric(12, 2) not null check (qty > 0),
  unit_price numeric(12, 2) not null check (unit_price >= 0),
  total_price numeric(12, 2) generated always as (round(qty * unit_price, 2)) stored,
  purchase_date date not null default current_date,
  receipt_url text,
  added_by uuid not null references profiles(id),
  notes text,
  created_at timestamptz not null default now()
);

create index if not exists idx_materials_project on materials(project_id, purchase_date desc);

-- 8. Sundry Expenses (অন্যান্য সাইট খরচ)
create table if not exists expenses (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid not null references organizations(id) on delete cascade,
  project_id uuid not null references projects(id) on delete cascade,
  category text not null default 'অন্যান্য' check (category in ('পরিবহন', 'যন্ত্রপাতি', 'চা-নাস্তা', 'ইউটিলিটি', 'অন্যান্য')),
  amount numeric(12, 2) not null check (amount > 0),
  expense_date date not null default current_date,
  note text,
  receipt_url text,
  added_by uuid not null references profiles(id),
  created_at timestamptz not null default now()
);

create index if not exists idx_expenses_project on expenses(project_id, expense_date desc);

-- 9. Bill Statements & Snapshots (শ্রমিক-বিল খতিয়ান ও স্টেটমেন্ট স্ন্যাপশট)
create table if not exists bill_statements (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid not null references organizations(id) on delete cascade,
  project_id uuid not null references projects(id) on delete cascade,
  period_from date not null,
  period_to date not null,
  preset text not null default 'custom' check (preset in ('custom', 'weekly', 'monthly')),
  generated_by uuid not null references profiles(id),
  sent_to_client_at timestamptz,
  is_locked boolean not null default false,
  locked_snapshot jsonb,
  file_url text,
  created_at timestamptz not null default now()
);

create index if not exists idx_bill_statements_project on bill_statements(project_id, period_from desc);

-- ==============================================================================
-- Row Level Security (RLS) Policies
-- ==============================================================================

alter table wage_ledger enable row level security;
alter table payments enable row level security;
alter table payment_allocations enable row level security;
alter table client_payments enable row level security;
alter table materials enable row level security;
alter table expenses enable row level security;
alter table bill_statements enable row level security;

-- wage_ledger policies
create policy "Contractors have full access to wage_ledger"
  on wage_ledger for all
  using (
    exists (
      select 1 from profiles
      where profiles.id = auth.uid()
        and profiles.organization_id = wage_ledger.organization_id
        and profiles.role = 'contractor'
    )
  );

create policy "Workers can read own wage_ledger"
  on wage_ledger for select
  using (worker_id = auth.uid());

create policy "Supervisors can read wage_ledger of assigned projects"
  on wage_ledger for select
  using (is_assigned_supervisor(project_id, auth.uid()));

create policy "Clients can read wage_ledger of own project"
  on wage_ledger for select
  using (
    exists (
      select 1 from projects
      where projects.id = wage_ledger.project_id
        and projects.client_id = auth.uid()
    )
  );

-- payments policies
create policy "Contractors have full access to payments"
  on payments for all
  using (
    exists (
      select 1 from profiles
      where profiles.id = auth.uid()
        and profiles.organization_id = payments.organization_id
        and profiles.role = 'contractor'
    )
  );

create policy "Payees can read own payments"
  on payments for select
  using (payee_id = auth.uid());

-- payment_allocations policies
create policy "Contractors have full access to payment_allocations"
  on payment_allocations for all
  using (
    exists (
      select 1 from profiles
      where profiles.id = auth.uid()
        and profiles.organization_id = payment_allocations.organization_id
        and profiles.role = 'contractor'
    )
  );

create policy "Clients can read payment_allocations of own project"
  on payment_allocations for select
  using (
    exists (
      select 1 from projects
      where projects.id = payment_allocations.project_id
        and projects.client_id = auth.uid()
    )
  );

create policy "Workers can read allocations of own wage ledger"
  on payment_allocations for select
  using (
    exists (
      select 1 from wage_ledger
      where wage_ledger.id = payment_allocations.wage_ledger_id
        and wage_ledger.worker_id = auth.uid()
    )
  );

-- client_payments policies
create policy "Contractors have full access to client_payments"
  on client_payments for all
  using (
    exists (
      select 1 from profiles
      where profiles.id = auth.uid()
        and profiles.organization_id = client_payments.organization_id
        and profiles.role = 'contractor'
    )
  );

create policy "Clients can view client_payments of own project"
  on client_payments for select
  using (
    exists (
      select 1 from projects
      where projects.id = client_payments.project_id
        and projects.client_id = auth.uid()
    )
  );

-- materials policies
create policy "Contractors have full access to materials"
  on materials for all
  using (
    exists (
      select 1 from profiles
      where profiles.id = auth.uid()
        and profiles.organization_id = materials.organization_id
        and profiles.role = 'contractor'
    )
  );

create policy "Supervisors have full access to materials of assigned project"
  on materials for all
  using (is_assigned_supervisor(project_id, auth.uid()));

create policy "Clients have full access to materials of own project"
  on materials for all
  using (
    exists (
      select 1 from projects
      where projects.id = materials.project_id
        and projects.client_id = auth.uid()
    )
  );

-- expenses policies
create policy "Contractors have full access to expenses"
  on expenses for all
  using (
    exists (
      select 1 from profiles
      where profiles.id = auth.uid()
        and profiles.organization_id = expenses.organization_id
        and profiles.role = 'contractor'
    )
  );

create policy "Supervisors have full access to expenses of assigned project"
  on expenses for all
  using (is_assigned_supervisor(project_id, auth.uid()));

create policy "Clients can view expenses of own project"
  on expenses for select
  using (
    exists (
      select 1 from projects
      where projects.id = expenses.project_id
        and projects.client_id = auth.uid()
    )
  );

-- bill_statements policies
create policy "Contractors have full access to bill_statements"
  on bill_statements for all
  using (
    exists (
      select 1 from profiles
      where profiles.id = auth.uid()
        and profiles.organization_id = bill_statements.organization_id
        and profiles.role = 'contractor'
    )
  );

create policy "Clients can view sent bill_statements of own project"
  on bill_statements for select
  using (
    sent_to_client_at is not null
    and exists (
      select 1 from projects
      where projects.id = bill_statements.project_id
        and projects.client_id = auth.uid()
    )
  );

-- 10. Audit Logging integration for Phase 4 tables
create or replace function log_phase4_audit()
returns trigger
language plpgsql
security definer
as $$
begin
  insert into audit_logs (
    organization_id,
    actor_id,
    action,
    table_name,
    record_id,
    old_data,
    new_data
  ) values (
    coalesce(NEW.organization_id, OLD.organization_id),
    auth.uid(),
    TG_OP,
    TG_TABLE_NAME,
    coalesce(NEW.id, OLD.id),
    case when TG_OP in ('UPDATE', 'DELETE') then to_jsonb(OLD) else null end,
    case when TG_OP in ('INSERT', 'UPDATE') then to_jsonb(NEW) else null end
  );
  return coalesce(NEW, OLD);
end;
$$;

drop trigger if exists trg_audit_payments on payments;
create trigger trg_audit_payments
after insert or update or delete on payments
for each row execute function log_phase4_audit();

drop trigger if exists trg_audit_client_payments on client_payments;
create trigger trg_audit_client_payments
after insert or update or delete on client_payments
for each row execute function log_phase4_audit();

drop trigger if exists trg_audit_materials on materials;
create trigger trg_audit_materials
after insert or update or delete on materials
for each row execute function log_phase4_audit();

drop trigger if exists trg_audit_expenses on expenses;
create trigger trg_audit_expenses
after insert or update or delete on expenses
for each row execute function log_phase4_audit();
