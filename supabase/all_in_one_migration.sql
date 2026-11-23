-- ============================================================================
-- Migration: 01_initial_schema.sql
-- Project: Project Khata (প্রজেক্ট খাতা) - Version 2.1
-- Description: Core Schema, Enums, Tables, Constraints, and Indexes
-- ============================================================================

-- Enable required extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- ============================================================================
-- 1. ENUMS (কাস্টম টাইপসমূহ)
-- ============================================================================

DO $$ BEGIN
    CREATE TYPE user_role AS ENUM ('contractor', 'client', 'supervisor', 'worker');
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
    CREATE TYPE user_status AS ENUM ('active', 'inactive');
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
    CREATE TYPE project_type AS ENUM ('sqft', 'contract', 'daily');
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
    CREATE TYPE project_status AS ENUM ('planned', 'active', 'completed', 'on_hold');
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
    CREATE TYPE entry_status AS ENUM ('open', 'submitted', 'locked', 'handover_required');
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
    CREATE TYPE attendance_status AS ENUM ('present', 'absent', 'half', 'overtime');
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
    CREATE TYPE location_status AS ENUM ('verified', 'outside_site', 'not_available');
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
    CREATE TYPE approval_status AS ENUM ('auto', 'pending', 'approved', 'rejected');
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
    CREATE TYPE expense_status AS ENUM ('pending', 'approved', 'rejected');
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
    CREATE TYPE allocation_method AS ENUM ('fifo', 'manual');
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
    CREATE TYPE statement_preset AS ENUM ('custom', 'monthly', 'weekly');
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

-- ============================================================================
-- 2. CORE TABLES (প্রতিষ্ঠান ও ইউজার)
-- ============================================================================

-- প্রতিষ্ঠান (Organizations: ১ জন ঠিকাদার = ১টি প্রতিষ্ঠান)
CREATE TABLE IF NOT EXISTS organizations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL,
    address TEXT,
    phone TEXT,
    logo_url TEXT,
    owner_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE RESTRICT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    CONSTRAINT uq_organization_owner UNIQUE (owner_id)
);

-- পদ ও মজুরি হার (Designations)
CREATE TABLE IF NOT EXISTS designations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    organization_id UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    daily_rate NUMERIC(12,2) NOT NULL DEFAULT 0.00 CHECK (daily_rate >= 0),
    overtime_rate_per_hour NUMERIC(12,2) NOT NULL DEFAULT 0.00 CHECK (overtime_rate_per_hour >= 0),
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    CONSTRAINT uq_org_designation_name UNIQUE (organization_id, name)
);

-- প্রোফাইল (Profiles: auth.users এর সাথে সংযুক্ত)
CREATE TABLE IF NOT EXISTS profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    organization_id UUID REFERENCES organizations(id) ON DELETE CASCADE,
    role user_role NOT NULL,
    name TEXT NOT NULL,
    mobile TEXT NOT NULL,
    email TEXT,
    photo_url TEXT,
    designation_id UUID REFERENCES designations(id) ON DELETE SET NULL,
    must_change_password BOOLEAN NOT NULL DEFAULT false,
    status user_status NOT NULL DEFAULT 'active',
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    CONSTRAINT uq_org_mobile UNIQUE (organization_id, mobile)
);

-- ============================================================================
-- 3. PROJECTS & ASSIGNMENTS (প্রজেক্ট ও দায়িত্ব বরাদ্দ)
-- ============================================================================

-- প্রজেক্ট (Projects)
CREATE TABLE IF NOT EXISTS projects (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    organization_id UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    type project_type NOT NULL,
    address TEXT NOT NULL,
    lat DOUBLE PRECISION NOT NULL, -- সাইট লোকেশন বাধ্যতামূলক
    lng DOUBLE PRECISION NOT NULL,
    geofence_radius_m INTEGER NOT NULL DEFAULT 150 CHECK (geofence_radius_m BETWEEN 100 AND 200),
    status project_status NOT NULL DEFAULT 'planned',
    start_date DATE,
    end_date DATE,
    budget NUMERIC(14,2) DEFAULT 0.00 CHECK (budget >= 0),
    cover_url TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- প্রজেক্ট ও ক্লায়েন্ট সংযোগ (Project Clients: একজন ক্লায়েন্ট একাধিক প্রজেক্টে থাকতে পারে)
CREATE TABLE IF NOT EXISTS project_clients (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    project_id UUID NOT NULL REFERENCES projects(id) ON DELETE CASCADE,
    client_profile_id UUID NOT NULL REFERENCES profiles(id) ON DELETE RESTRICT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    CONSTRAINT uq_project_client UNIQUE (project_id, client_profile_id)
);

-- সুপারভাইজার অ্যাসাইনমেন্ট (Supervisor Assignments)
CREATE TABLE IF NOT EXISTS supervisor_assignments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    organization_id UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
    project_id UUID NOT NULL REFERENCES projects(id) ON DELETE CASCADE,
    supervisor_id UUID NOT NULL REFERENCES profiles(id) ON DELETE RESTRICT,
    assigned_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    unassigned_at TIMESTAMPTZ -- NULL থাকলে সক্রিয়
);

-- আংশিক ইউনিক ইনডেক্স: একই প্রজেক্টে একই সময়ে একজন সুপারভাইজার একবারই সক্রিয় অ্যাসাইন থাকতে পারবে
CREATE UNIQUE INDEX IF NOT EXISTS uq_active_supervisor_assignment 
ON supervisor_assignments(project_id, supervisor_id) 
WHERE unassigned_at IS NULL;

-- ============================================================================
-- 4. DAILY ENTRIES & ATTENDANCE (দৈনিক এন্ট্রি, দল ও হাজিরা)
-- ============================================================================

-- দৈনিক এন্ট্রি (Daily Entries)
CREATE TABLE IF NOT EXISTS daily_entries (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    organization_id UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
    project_id UUID NOT NULL REFERENCES projects(id) ON DELETE RESTRICT,
    entry_date DATE NOT NULL,
    status entry_status NOT NULL DEFAULT 'open',
    opened_by UUID NOT NULL REFERENCES profiles(id) ON DELETE RESTRICT,
    is_backdated BOOLEAN NOT NULL DEFAULT false,
    backdate_reason TEXT,
    submitted_at TIMESTAMPTZ,
    locked_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    CONSTRAINT uq_project_entry_date UNIQUE (project_id, entry_date)
);

-- এন্ট্রি দল (Entry Teams: সেদিনের দল গঠন)
CREATE TABLE IF NOT EXISTS entry_teams (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    entry_id UUID NOT NULL REFERENCES daily_entries(id) ON DELETE CASCADE,
    supervisor_id UUID NOT NULL REFERENCES profiles(id) ON DELETE RESTRICT,
    team_date DATE NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- হাজিরা (Attendance)
CREATE TABLE IF NOT EXISTS attendance (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    organization_id UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
    entry_id UUID NOT NULL REFERENCES daily_entries(id) ON DELETE CASCADE,
    worker_id UUID NOT NULL REFERENCES profiles(id) ON DELETE RESTRICT,
    entry_date DATE NOT NULL,
    status attendance_status NOT NULL DEFAULT 'present',
    overtime_hours NUMERIC(4,2) NOT NULL DEFAULT 0.00 CHECK (overtime_hours >= 0),
    marked_by UUID NOT NULL REFERENCES profiles(id) ON DELETE RESTRICT,
    marked_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    latitude DOUBLE PRECISION,
    longitude DOUBLE PRECISION,
    accuracy_m DOUBLE PRECISION,
    distance_m DOUBLE PRECISION,
    location_status location_status NOT NULL DEFAULT 'not_available',
    approval_status approval_status NOT NULL DEFAULT 'auto',
    approved_by UUID REFERENCES profiles(id) ON DELETE SET NULL,
    sync_status TEXT NOT NULL DEFAULT 'synced',
    synced_at TIMESTAMPTZ DEFAULT now(),
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    CONSTRAINT uq_entry_worker UNIQUE (entry_id, worker_id),
    CONSTRAINT uq_worker_date UNIQUE (worker_id, entry_date) -- একদিনে একটির বেশি প্রজেক্টে হাজিরা নয়
);

-- ============================================================================
-- 5. WAGE, PAYMENTS & BILLING (মজুরি, পেমেন্ট ও খতিয়ান)
-- ============================================================================

-- মজুরি খতিয়ান (Wage Ledger)
CREATE TABLE IF NOT EXISTS wage_ledger (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    organization_id UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
    project_id UUID NOT NULL REFERENCES projects(id) ON DELETE RESTRICT,
    worker_id UUID NOT NULL REFERENCES profiles(id) ON DELETE RESTRICT,
    work_date DATE NOT NULL,
    attendance_id UUID NOT NULL REFERENCES attendance(id) ON DELETE CASCADE,
    designation_id UUID REFERENCES designations(id) ON DELETE SET NULL,
    daily_amount NUMERIC(12,2) NOT NULL DEFAULT 0.00 CHECK (daily_amount >= 0),
    overtime_amount NUMERIC(12,2) NOT NULL DEFAULT 0.00 CHECK (overtime_amount >= 0),
    total_amount NUMERIC(12,2) NOT NULL DEFAULT 0.00 CHECK (total_amount >= 0),
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    CONSTRAINT uq_wage_attendance UNIQUE (attendance_id)
);

-- শ্রমিক/সুপারভাইজার পেমেন্ট (Payments: প্রতিষ্ঠান স্তরে রেকর্ড)
CREATE TABLE IF NOT EXISTS payments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    organization_id UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
    payee_id UUID NOT NULL REFERENCES profiles(id) ON DELETE RESTRICT,
    payee_role user_role NOT NULL,
    amount NUMERIC(14,2) NOT NULL CHECK (amount > 0),
    payment_date DATE NOT NULL DEFAULT CURRENT_DATE,
    note TEXT,
    created_by UUID NOT NULL REFERENCES profiles(id) ON DELETE RESTRICT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- পেমেন্ট বরাদ্দ (Payment Allocations: FIFO বা ম্যানুয়াল বরাদ্দ)
CREATE TABLE IF NOT EXISTS payment_allocations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    payment_id UUID NOT NULL REFERENCES payments(id) ON DELETE CASCADE,
    project_id UUID NOT NULL REFERENCES projects(id) ON DELETE RESTRICT,
    wage_ledger_id UUID NOT NULL REFERENCES wage_ledger(id) ON DELETE RESTRICT,
    allocated_amount NUMERIC(12,2) NOT NULL CHECK (allocated_amount > 0),
    method allocation_method NOT NULL DEFAULT 'fifo',
    changed_by UUID REFERENCES profiles(id) ON DELETE SET NULL,
    changed_at TIMESTAMPTZ DEFAULT now(),
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- ক্লায়েন্ট পেমেন্ট রেকর্ড (Client Payments)
CREATE TABLE IF NOT EXISTS client_payments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    organization_id UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
    project_id UUID NOT NULL REFERENCES projects(id) ON DELETE RESTRICT,
    amount NUMERIC(14,2) NOT NULL CHECK (amount > 0),
    payment_date DATE NOT NULL DEFAULT CURRENT_DATE,
    note TEXT,
    created_by UUID NOT NULL REFERENCES profiles(id) ON DELETE RESTRICT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- শ্রমিক-বিল খতিয়ান স্ন্যাপশট (Bill Statements)
CREATE TABLE IF NOT EXISTS bill_statements (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    organization_id UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
    project_id UUID NOT NULL REFERENCES projects(id) ON DELETE RESTRICT,
    period_from DATE NOT NULL,
    period_to DATE NOT NULL,
    preset statement_preset NOT NULL DEFAULT 'custom',
    generated_by UUID NOT NULL REFERENCES profiles(id) ON DELETE RESTRICT,
    sent_to_client_at TIMESTAMPTZ,
    snapshot_json JSONB NOT NULL,
    file_url_pdf TEXT,
    file_url_xlsx TEXT,
    locked BOOLEAN NOT NULL DEFAULT false,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- ============================================================================
-- 6. MATERIALS & EXPENSES (মালামাল ও সাইট খরচ)
-- ============================================================================

-- মালামাল (Materials)
CREATE TABLE IF NOT EXISTS materials (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    organization_id UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
    project_id UUID NOT NULL REFERENCES projects(id) ON DELETE RESTRICT,
    name TEXT NOT NULL,
    unit TEXT NOT NULL,
    qty NUMERIC(12,2) NOT NULL CHECK (qty > 0),
    unit_price NUMERIC(12,2) NOT NULL CHECK (unit_price >= 0),
    total_price NUMERIC(14,2) GENERATED ALWAYS AS (qty * unit_price) STORED,
    purchase_date DATE NOT NULL DEFAULT CURRENT_DATE,
    receipt_url TEXT,
    added_by UUID NOT NULL REFERENCES profiles(id) ON DELETE RESTRICT,
    added_by_role user_role NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- সাইট খরচ (Site Expenses)
CREATE TABLE IF NOT EXISTS site_expenses (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    organization_id UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
    project_id UUID NOT NULL REFERENCES projects(id) ON DELETE RESTRICT,
    entry_id UUID REFERENCES daily_entries(id) ON DELETE SET NULL,
    category TEXT NOT NULL,
    amount NUMERIC(12,2) NOT NULL CHECK (amount > 0),
    expense_date DATE NOT NULL DEFAULT CURRENT_DATE,
    note TEXT,
    receipt_url TEXT,
    status expense_status NOT NULL DEFAULT 'pending',
    added_by UUID NOT NULL REFERENCES profiles(id) ON DELETE RESTRICT,
    decided_by UUID REFERENCES profiles(id) ON DELETE SET NULL,
    decision_reason TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- ============================================================================
-- 7. NOTIFICATIONS, AUDIT & FCM (নোটিফিকেশন, অডিট ও ডিভাইস টোকেন)
-- ============================================================================

-- নোটিফিকেশন (Notifications)
CREATE TABLE IF NOT EXISTS notifications (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    organization_id UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    type TEXT NOT NULL,
    title TEXT NOT NULL,
    body TEXT NOT NULL,
    is_read BOOLEAN NOT NULL DEFAULT false,
    data JSONB,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- অডিট লগ (Audit Logs: অপরিবর্তনীয় অডিট ট্রেইল)
CREATE TABLE IF NOT EXISTS audit_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    organization_id UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
    actor_id UUID REFERENCES profiles(id) ON DELETE SET NULL,
    actor_role user_role,
    action TEXT NOT NULL,
    table_name TEXT NOT NULL,
    record_id UUID,
    old_data JSONB,
    new_data JSONB,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- ডিভাইস টোকেন (Device Tokens for FCM)
CREATE TABLE IF NOT EXISTS device_tokens (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    fcm_token TEXT NOT NULL,
    platform TEXT NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    CONSTRAINT uq_user_fcm_token UNIQUE (user_id, fcm_token)
);

-- ============================================================================
-- 8. INDEXES FOR HIGH-PERFORMANCE QUERYING (ইনডেক্সসমূহ)
-- ============================================================================

CREATE INDEX IF NOT EXISTS idx_profiles_org ON profiles(organization_id);
CREATE INDEX IF NOT EXISTS idx_profiles_role ON profiles(organization_id, role);
CREATE INDEX IF NOT EXISTS idx_projects_org_status ON projects(organization_id, status);
CREATE INDEX IF NOT EXISTS idx_supervisor_assign_active ON supervisor_assignments(supervisor_id, unassigned_at);
CREATE INDEX IF NOT EXISTS idx_daily_entries_date ON daily_entries(project_id, entry_date);
CREATE INDEX IF NOT EXISTS idx_daily_entries_status ON daily_entries(organization_id, status);
CREATE INDEX IF NOT EXISTS idx_attendance_worker_date ON attendance(worker_id, entry_date);
CREATE INDEX IF NOT EXISTS idx_attendance_entry ON attendance(entry_id);
CREATE INDEX IF NOT EXISTS idx_attendance_location_approval ON attendance(organization_id, location_status, approval_status);
CREATE INDEX IF NOT EXISTS idx_wage_worker_date ON wage_ledger(worker_id, work_date);
CREATE INDEX IF NOT EXISTS idx_wage_project ON wage_ledger(project_id);
CREATE INDEX IF NOT EXISTS idx_payments_payee ON payments(organization_id, payee_id);
CREATE INDEX IF NOT EXISTS idx_payment_alloc_wage ON payment_allocations(wage_ledger_id);
CREATE INDEX IF NOT EXISTS idx_materials_project ON materials(project_id, purchase_date);
CREATE INDEX IF NOT EXISTS idx_site_expenses_status ON site_expenses(project_id, status);
CREATE INDEX IF NOT EXISTS idx_notifications_user_unread ON notifications(user_id, is_read);
CREATE INDEX IF NOT EXISTS idx_audit_logs_org_date ON audit_logs(organization_id, created_at DESC);
-- ============================================================================
-- Migration: 02_helper_functions.sql
-- Project: Project Khata (প্রজেক্ট খাতা) - Version 2.1
-- Description: Core Helper Functions, Role Checkers & Distance Utilities
-- ============================================================================

-- 1. Helper: বর্তমান ইউজারের প্রতিষ্ঠান আইডি (Organization ID)
CREATE OR REPLACE FUNCTION get_current_org_id()
RETURNS UUID
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT organization_id FROM profiles WHERE id = auth.uid() LIMIT 1;
$$;

-- 2. Helper: বর্তমান ইউজারের ভূমিকা (Role)
-- (PostgreSQL-এর সংরক্ষিত শব্দ এড়াতে PRD অনুযায়ী get_current_role নাম দেওয়া হয়েছে)
CREATE OR REPLACE FUNCTION get_current_role()
RETURNS user_role
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT role FROM profiles WHERE id = auth.uid() LIMIT 1;
$$;

-- 3. Helper: বর্তমান ইউজার সক্রিয় ঠিকাদার কি না
CREATE OR REPLACE FUNCTION is_contractor()
RETURNS BOOLEAN
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT EXISTS (
    SELECT 1 FROM profiles 
    WHERE id = auth.uid() 
      AND role = 'contractor' 
      AND status = 'active'
  );
$$;

-- 4. Helper: বর্তমান ইউজার সক্রিয় সুপারভাইজার কি না
CREATE OR REPLACE FUNCTION is_supervisor()
RETURNS BOOLEAN
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT EXISTS (
    SELECT 1 FROM profiles 
    WHERE id = auth.uid() 
      AND role = 'supervisor' 
      AND status = 'active'
  );
$$;

-- 5. Helper: নির্দিষ্ট প্রজেক্টে সুপারভাইজার বর্তমানে অ্যাসাইন আছে কি না
CREATE OR REPLACE FUNCTION is_assigned_supervisor(p_project_id UUID)
RETURNS BOOLEAN
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT EXISTS (
    SELECT 1 FROM supervisor_assignments 
    WHERE project_id = p_project_id 
      AND supervisor_id = auth.uid() 
      AND unassigned_at IS NULL
  );
$$;

-- 6. Helper: নির্দিষ্ট প্রজেক্টে বর্তমান ইউজার ক্লায়েন্ট হিসেবে যুক্ত কি না
CREATE OR REPLACE FUNCTION is_client_of_project(p_project_id UUID)
RETURNS BOOLEAN
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT EXISTS (
    SELECT 1 FROM project_clients 
    WHERE project_id = p_project_id 
      AND client_profile_id = auth.uid()
  );
$$;

-- 7. Helper: জিপিএস দূরত্ব পরিমাপ (Haversine Formula in Meters)
CREATE OR REPLACE FUNCTION calculate_distance_meters(
  lat1 DOUBLE PRECISION,
  lon1 DOUBLE PRECISION,
  lat2 DOUBLE PRECISION,
  lon2 DOUBLE PRECISION
)
RETURNS DOUBLE PRECISION
LANGUAGE plpgsql
IMMUTABLE
AS $$
DECLARE
  r CONSTANT DOUBLE PRECISION := 6371000; -- পৃথিবীর গড় ব্যাসার্ধ (মিটারে)
  phi1 DOUBLE PRECISION;
  phi2 DOUBLE PRECISION;
  delta_phi DOUBLE PRECISION;
  delta_lambda DOUBLE PRECISION;
  a DOUBLE PRECISION;
  c DOUBLE PRECISION;
BEGIN
  IF lat1 IS NULL OR lon1 IS NULL OR lat2 IS NULL OR lon2 IS NULL THEN
    RETURN NULL;
  END IF;
  
  phi1 := radians(lat1);
  phi2 := radians(lat2);
  delta_phi := radians(lat2 - lat1);
  delta_lambda := radians(lon2 - lon1);
  
  a := sin(delta_phi / 2.0)^2 + cos(phi1) * cos(phi2) * sin(delta_lambda / 2.0)^2;
  c := 2.0 * atan2(sqrt(a), sqrt(1.0 - a));
  
  RETURN r * c;
END;
$$;

-- 8. Trigger Function: updated_at সময় স্বয়ংক্রিয়ভাবে আপডেট করা
CREATE OR REPLACE FUNCTION set_updated_at()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$;

-- বিভিন্ন টেবিলে set_updated_at ট্রিগার যুক্ত করা
DROP TRIGGER IF EXISTS trg_org_updated_at ON organizations;
CREATE TRIGGER trg_org_updated_at BEFORE UPDATE ON organizations
FOR EACH ROW EXECUTE FUNCTION set_updated_at();

DROP TRIGGER IF EXISTS trg_profiles_updated_at ON profiles;
CREATE TRIGGER trg_profiles_updated_at BEFORE UPDATE ON profiles
FOR EACH ROW EXECUTE FUNCTION set_updated_at();

DROP TRIGGER IF EXISTS trg_designations_updated_at ON designations;
CREATE TRIGGER trg_designations_updated_at BEFORE UPDATE ON designations
FOR EACH ROW EXECUTE FUNCTION set_updated_at();

DROP TRIGGER IF EXISTS trg_projects_updated_at ON projects;
CREATE TRIGGER trg_projects_updated_at BEFORE UPDATE ON projects
FOR EACH ROW EXECUTE FUNCTION set_updated_at();

DROP TRIGGER IF EXISTS trg_daily_entries_updated_at ON daily_entries;
CREATE TRIGGER trg_daily_entries_updated_at BEFORE UPDATE ON daily_entries
FOR EACH ROW EXECUTE FUNCTION set_updated_at();

DROP TRIGGER IF EXISTS trg_attendance_updated_at ON attendance;
CREATE TRIGGER trg_attendance_updated_at BEFORE UPDATE ON attendance
FOR EACH ROW EXECUTE FUNCTION set_updated_at();

DROP TRIGGER IF EXISTS trg_materials_updated_at ON materials;
CREATE TRIGGER trg_materials_updated_at BEFORE UPDATE ON materials
FOR EACH ROW EXECUTE FUNCTION set_updated_at();

DROP TRIGGER IF EXISTS trg_site_expenses_updated_at ON site_expenses;
CREATE TRIGGER trg_site_expenses_updated_at BEFORE UPDATE ON site_expenses
FOR EACH ROW EXECUTE FUNCTION set_updated_at();
-- ============================================================================
-- Migration: 03_rls_policies.sql
-- Project: Project Khata (প্রজেক্ট খাতা) - Version 2.1
-- Description: Complete Row Level Security (RLS) Policies across all tables
-- ============================================================================

-- ----------------------------------------------------------------------------
-- 1. ORGANIZATIONS
-- ----------------------------------------------------------------------------
ALTER TABLE organizations ENABLE ROW LEVEL SECURITY;

CREATE POLICY "org_select_policy" ON organizations
FOR SELECT USING (
    id = get_current_org_id() OR owner_id = auth.uid()
);

CREATE POLICY "org_insert_policy" ON organizations
FOR INSERT WITH CHECK (
    owner_id = auth.uid()
);

CREATE POLICY "org_update_policy" ON organizations
FOR UPDATE USING (
    owner_id = auth.uid()
) WITH CHECK (
    owner_id = auth.uid()
);

-- ----------------------------------------------------------------------------
-- 2. PROFILES
-- ----------------------------------------------------------------------------
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;

CREATE POLICY "profiles_select_policy" ON profiles
FOR SELECT USING (
    organization_id = get_current_org_id() OR id = auth.uid()
);

CREATE POLICY "profiles_insert_policy" ON profiles
FOR INSERT WITH CHECK (
    is_contractor() OR id = auth.uid()
);

CREATE POLICY "profiles_update_policy" ON profiles
FOR UPDATE USING (
    id = auth.uid() OR (organization_id = get_current_org_id() AND is_contractor())
) WITH CHECK (
    id = auth.uid() OR (organization_id = get_current_org_id() AND is_contractor())
);

-- ----------------------------------------------------------------------------
-- 3. DESIGNATIONS
-- ----------------------------------------------------------------------------
ALTER TABLE designations ENABLE ROW LEVEL SECURITY;

CREATE POLICY "designations_select_policy" ON designations
FOR SELECT USING (
    organization_id = get_current_org_id()
);

CREATE POLICY "designations_contractor_all_policy" ON designations
FOR ALL USING (
    organization_id = get_current_org_id() AND is_contractor()
) WITH CHECK (
    organization_id = get_current_org_id() AND is_contractor()
);

-- ----------------------------------------------------------------------------
-- 4. PROJECTS
-- ----------------------------------------------------------------------------
ALTER TABLE projects ENABLE ROW LEVEL SECURITY;

CREATE POLICY "projects_select_policy" ON projects
FOR SELECT USING (
    (organization_id = get_current_org_id() AND is_contractor())
    OR (organization_id = get_current_org_id() AND is_assigned_supervisor(id))
    OR is_client_of_project(id)
    OR (organization_id = get_current_org_id() AND status = 'active') -- শ্রমিকের সক্রিয় প্রজেক্ট দেখার জন্য
);

CREATE POLICY "projects_contractor_modify_policy" ON projects
FOR ALL USING (
    organization_id = get_current_org_id() AND is_contractor()
) WITH CHECK (
    organization_id = get_current_org_id() AND is_contractor()
);

-- ----------------------------------------------------------------------------
-- 5. PROJECT CLIENTS
-- ----------------------------------------------------------------------------
ALTER TABLE project_clients ENABLE ROW LEVEL SECURITY;

CREATE POLICY "project_clients_select_policy" ON project_clients
FOR SELECT USING (
    client_profile_id = auth.uid() 
    OR is_contractor()
);

CREATE POLICY "project_clients_contractor_modify_policy" ON project_clients
FOR ALL USING (
    is_contractor()
) WITH CHECK (
    is_contractor()
);

-- ----------------------------------------------------------------------------
-- 6. SUPERVISOR ASSIGNMENTS
-- ----------------------------------------------------------------------------
ALTER TABLE supervisor_assignments ENABLE ROW LEVEL SECURITY;

CREATE POLICY "supervisor_assign_select_policy" ON supervisor_assignments
FOR SELECT USING (
    (organization_id = get_current_org_id() AND is_contractor())
    OR (supervisor_id = auth.uid())
);

CREATE POLICY "supervisor_assign_contractor_modify_policy" ON supervisor_assignments
FOR ALL USING (
    organization_id = get_current_org_id() AND is_contractor()
) WITH CHECK (
    organization_id = get_current_org_id() AND is_contractor()
);

-- ----------------------------------------------------------------------------
-- 7. DAILY ENTRIES
-- ----------------------------------------------------------------------------
ALTER TABLE daily_entries ENABLE ROW LEVEL SECURITY;

CREATE POLICY "daily_entries_select_policy" ON daily_entries
FOR SELECT USING (
    (organization_id = get_current_org_id() AND is_contractor())
    OR (organization_id = get_current_org_id() AND is_assigned_supervisor(project_id))
    OR (organization_id = get_current_org_id()) -- শ্রমিকের খোলা এন্ট্রি দেখার জন্য
);

CREATE POLICY "daily_entries_insert_policy" ON daily_entries
FOR INSERT WITH CHECK (
    (organization_id = get_current_org_id() AND is_contractor())
    OR (
        organization_id = get_current_org_id() 
        AND is_assigned_supervisor(project_id)
        AND EXISTS (SELECT 1 FROM projects WHERE id = project_id AND status = 'active')
    )
);

CREATE POLICY "daily_entries_update_policy" ON daily_entries
FOR UPDATE USING (
    (organization_id = get_current_org_id() AND is_contractor())
    OR (
        opened_by = auth.uid() 
        AND status = 'open' 
        AND is_assigned_supervisor(project_id)
    )
) WITH CHECK (
    (organization_id = get_current_org_id() AND is_contractor())
    OR (
        opened_by = auth.uid() 
        AND status IN ('open', 'submitted') 
        AND is_assigned_supervisor(project_id)
    )
);

-- ----------------------------------------------------------------------------
-- 8. ENTRY TEAMS
-- ----------------------------------------------------------------------------
ALTER TABLE entry_teams ENABLE ROW LEVEL SECURITY;

CREATE POLICY "entry_teams_select_policy" ON entry_teams
FOR SELECT USING (
    is_contractor() OR supervisor_id = auth.uid()
);

CREATE POLICY "entry_teams_insert_policy" ON entry_teams
FOR INSERT WITH CHECK (
    is_contractor() OR (
        supervisor_id = auth.uid() 
        AND EXISTS (
            SELECT 1 FROM daily_entries 
            WHERE id = entry_teams.entry_id AND status = 'open'
        )
    )
);

-- ----------------------------------------------------------------------------
-- 9. ATTENDANCE (হাজিরা - অত্যন্ত স্পর্শকাতর ও কঠোর গোপনীয়তা)
-- ----------------------------------------------------------------------------
ALTER TABLE attendance ENABLE ROW LEVEL SECURITY;

-- ক্লায়েন্টের জন্য কোনো SELECT পলিসি নেই (গোপনীয়তা রক্ষা)
CREATE POLICY "attendance_select_policy" ON attendance
FOR SELECT USING (
    (organization_id = get_current_org_id() AND is_contractor())
    OR (
        organization_id = get_current_org_id() 
        AND EXISTS (
            SELECT 1 FROM daily_entries 
            WHERE daily_entries.id = attendance.entry_id 
              AND is_assigned_supervisor(daily_entries.project_id)
        )
    )
    OR (worker_id = auth.uid()) -- শ্রমিক শুধু নিজের হাজিরা দেখবে
);

CREATE POLICY "attendance_insert_policy" ON attendance
FOR INSERT WITH CHECK (
    (organization_id = get_current_org_id() AND is_contractor())
    OR (
        -- সুপারভাইজার তার এন্ট্রির দলভুক্ত শ্রমিকের হাজিরা দেবে
        organization_id = get_current_org_id()
        AND EXISTS (
            SELECT 1 FROM daily_entries 
            WHERE daily_entries.id = attendance.entry_id 
              AND daily_entries.status = 'open'
              AND is_assigned_supervisor(daily_entries.project_id)
        )
    )
    OR (
        -- শ্রমিক নিজে হাজিরা দেবে যদি সেদিনের এন্ট্রি খোলা থাকে
        organization_id = get_current_org_id()
        AND worker_id = auth.uid()
        AND EXISTS (
            SELECT 1 FROM daily_entries 
            WHERE daily_entries.id = attendance.entry_id 
              AND daily_entries.status = 'open'
        )
    )
);

CREATE POLICY "attendance_update_policy" ON attendance
FOR UPDATE USING (
    (organization_id = get_current_org_id() AND is_contractor())
    OR (
        -- সুপারভাইজার শুধু খোলা এন্ট্রিতে হাজিরা বদলাতে পারবে
        organization_id = get_current_org_id()
        AND EXISTS (
            SELECT 1 FROM daily_entries 
            WHERE daily_entries.id = attendance.entry_id 
              AND daily_entries.status = 'open'
              AND is_assigned_supervisor(daily_entries.project_id)
        )
        AND approval_status != 'approved'
    )
) WITH CHECK (
    (organization_id = get_current_org_id() AND is_contractor())
    OR (
        organization_id = get_current_org_id()
        AND EXISTS (
            SELECT 1 FROM daily_entries 
            WHERE daily_entries.id = attendance.entry_id 
              AND daily_entries.status = 'open'
              AND is_assigned_supervisor(daily_entries.project_id)
        )
    )
);

-- ----------------------------------------------------------------------------
-- 10. WAGE LEDGER (মজুরি খতিয়ান)
-- ----------------------------------------------------------------------------
ALTER TABLE wage_ledger ENABLE ROW LEVEL SECURITY;

CREATE POLICY "wage_ledger_select_policy" ON wage_ledger
FOR SELECT USING (
    (organization_id = get_current_org_id() AND is_contractor())
    OR (worker_id = auth.uid()) -- শ্রমিক/সুপারভাইজার শুধু নিজের মজুরি দেখবে
);

CREATE POLICY "wage_ledger_contractor_modify_policy" ON wage_ledger
FOR ALL USING (
    organization_id = get_current_org_id() AND is_contractor()
) WITH CHECK (
    organization_id = get_current_org_id() AND is_contractor()
);

-- ----------------------------------------------------------------------------
-- 11. PAYMENTS (পেমেন্ট রেকর্ড)
-- ----------------------------------------------------------------------------
ALTER TABLE payments ENABLE ROW LEVEL SECURITY;

CREATE POLICY "payments_select_policy" ON payments
FOR SELECT USING (
    (organization_id = get_current_org_id() AND is_contractor())
    OR (payee_id = auth.uid())
);

CREATE POLICY "payments_contractor_modify_policy" ON payments
FOR ALL USING (
    organization_id = get_current_org_id() AND is_contractor()
) WITH CHECK (
    organization_id = get_current_org_id() AND is_contractor()
);

-- ----------------------------------------------------------------------------
-- 12. PAYMENT ALLOCATIONS (পেমেন্ট বরাদ্দ)
-- ----------------------------------------------------------------------------
ALTER TABLE payment_allocations ENABLE ROW LEVEL SECURITY;

CREATE POLICY "payment_alloc_select_policy" ON payment_allocations
FOR SELECT USING (
    is_contractor()
    OR EXISTS (
        SELECT 1 FROM payments 
        WHERE payments.id = payment_allocations.payment_id 
          AND payments.payee_id = auth.uid()
    )
);

CREATE POLICY "payment_alloc_contractor_modify_policy" ON payment_allocations
FOR ALL USING (
    is_contractor()
) WITH CHECK (
    is_contractor()
);

-- ----------------------------------------------------------------------------
-- 13. CLIENT PAYMENTS (ক্লায়েন্ট পেমেন্ট)
-- ----------------------------------------------------------------------------
ALTER TABLE client_payments ENABLE ROW LEVEL SECURITY;

CREATE POLICY "client_payments_select_policy" ON client_payments
FOR SELECT USING (
    (organization_id = get_current_org_id() AND is_contractor())
    OR is_client_of_project(project_id)
);

CREATE POLICY "client_payments_contractor_modify_policy" ON client_payments
FOR ALL USING (
    organization_id = get_current_org_id() AND is_contractor()
) WITH CHECK (
    organization_id = get_current_org_id() AND is_contractor()
);

-- ----------------------------------------------------------------------------
-- 14. BILL STATEMENTS (শ্রমিক-বিল খতিয়ান স্ন্যাপশট)
-- ----------------------------------------------------------------------------
ALTER TABLE bill_statements ENABLE ROW LEVEL SECURITY;

CREATE POLICY "bill_statements_select_policy" ON bill_statements
FOR SELECT USING (
    (organization_id = get_current_org_id() AND is_contractor())
    OR (is_client_of_project(project_id) AND sent_to_client_at IS NOT NULL)
);

CREATE POLICY "bill_statements_contractor_modify_policy" ON bill_statements
FOR ALL USING (
    organization_id = get_current_org_id() AND is_contractor()
) WITH CHECK (
    organization_id = get_current_org_id() AND is_contractor()
);

-- ----------------------------------------------------------------------------
-- 15. MATERIALS (মালামাল - ঠিকাদার ক্লায়েন্টের মালামাল মুছতে বা সম্পাদনা করতে পারবে না)
-- ----------------------------------------------------------------------------
ALTER TABLE materials ENABLE ROW LEVEL SECURITY;

CREATE POLICY "materials_select_policy" ON materials
FOR SELECT USING (
    (organization_id = get_current_org_id() AND is_contractor())
    OR is_assigned_supervisor(project_id)
    OR is_client_of_project(project_id)
);

CREATE POLICY "materials_insert_policy" ON materials
FOR INSERT WITH CHECK (
    (organization_id = get_current_org_id() AND is_contractor())
    OR is_assigned_supervisor(project_id)
    OR is_client_of_project(project_id)
);

-- ক্লায়েন্ট ও সুপারভাইজার শুধু নিজের মালামাল আপডেট করতে পারবে।
-- ঠিকাদার নিজের যোগ করা মালামাল আপডেট করতে পারবে, কিন্তু ক্লায়েন্টের মালামাল পারবে না।
CREATE POLICY "materials_update_policy" ON materials
FOR UPDATE USING (
    (added_by = auth.uid())
    OR (
        organization_id = get_current_org_id() 
        AND is_contractor() 
        AND added_by_role != 'client' -- PRD নিয়ম ৫৭
    )
) WITH CHECK (
    (added_by = auth.uid())
    OR (
        organization_id = get_current_org_id() 
        AND is_contractor() 
        AND added_by_role != 'client'
    )
);

CREATE POLICY "materials_delete_policy" ON materials
FOR DELETE USING (
    (added_by = auth.uid())
    OR (
        organization_id = get_current_org_id() 
        AND is_contractor() 
        AND added_by_role != 'client'
    )
);

-- ----------------------------------------------------------------------------
-- 16. SITE EXPENSES (সাইট খরচ)
-- ----------------------------------------------------------------------------
ALTER TABLE site_expenses ENABLE ROW LEVEL SECURITY;

CREATE POLICY "site_expenses_select_policy" ON site_expenses
FOR SELECT USING (
    (organization_id = get_current_org_id() AND is_contractor())
    OR is_assigned_supervisor(project_id)
);

CREATE POLICY "site_expenses_insert_policy" ON site_expenses
FOR INSERT WITH CHECK (
    is_assigned_supervisor(project_id)
);

CREATE POLICY "site_expenses_update_policy" ON site_expenses
FOR UPDATE USING (
    (organization_id = get_current_org_id() AND is_contractor())
    OR (added_by = auth.uid() AND status = 'pending')
) WITH CHECK (
    (organization_id = get_current_org_id() AND is_contractor())
    OR (added_by = auth.uid() AND status = 'pending')
);

CREATE POLICY "site_expenses_delete_policy" ON site_expenses
FOR DELETE USING (
    added_by = auth.uid() AND status = 'pending'
);

-- ----------------------------------------------------------------------------
-- 17. NOTIFICATIONS
-- ----------------------------------------------------------------------------
ALTER TABLE notifications ENABLE ROW LEVEL SECURITY;

CREATE POLICY "notifications_select_policy" ON notifications
FOR SELECT USING (
    user_id = auth.uid()
);

CREATE POLICY "notifications_update_policy" ON notifications
FOR UPDATE USING (
    user_id = auth.uid()
) WITH CHECK (
    user_id = auth.uid()
);

-- ----------------------------------------------------------------------------
-- 18. AUDIT LOGS (অডিট ট্রেইল - অপরিবর্তনীয় ও নিরাপদ)
-- ----------------------------------------------------------------------------
ALTER TABLE audit_logs ENABLE ROW LEVEL SECURITY;

CREATE POLICY "audit_logs_select_policy" ON audit_logs
FOR SELECT USING (
    organization_id = get_current_org_id() AND is_contractor()
);

CREATE POLICY "audit_logs_insert_policy" ON audit_logs
FOR INSERT WITH CHECK (
    organization_id = get_current_org_id()
);

-- কোনো UPDATE বা DELETE পলিসি থাকবে না, অডিট লগ অপরিবর্তনীয় থাকবে

-- ----------------------------------------------------------------------------
-- 19. DEVICE TOKENS (FCM)
-- ----------------------------------------------------------------------------
ALTER TABLE device_tokens ENABLE ROW LEVEL SECURITY;

CREATE POLICY "device_tokens_user_policy" ON device_tokens
FOR ALL USING (
    user_id = auth.uid()
) WITH CHECK (
    user_id = auth.uid()
);
-- ============================================================================
-- Migration: 04_triggers_and_rpcs.sql
-- Project: Project Khata (প্রজেক্ট খাতা) - Version 2.1
-- Description: Core Business Logic RPCs, Geofencing, Auto-Wage & FIFO Allocation
-- ============================================================================

-- ----------------------------------------------------------------------------
-- 1. RPC: প্রতিষ্ঠান সেটআপ (Create Organization)
-- ঠিকাদার প্রথম লগইনের পর প্রতিষ্ঠান তৈরি করে এবং ডিফল্ট পদ সেট করে
-- ----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION create_organization(
    org_name TEXT,
    org_address TEXT,
    org_phone TEXT,
    contractor_mobile TEXT,
    contractor_name TEXT DEFAULT NULL
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
    v_user_id UUID := auth.uid();
    v_org_id UUID;
    v_profile_name TEXT;
BEGIN
    IF v_user_id IS NULL THEN
        RAISE EXCEPTION 'লগইন করা আবশ্যক।';
    END IF;

    -- ১ জন ঠিকাদার একটিমাত্র প্রতিষ্ঠান চালাতে পারবে
    IF EXISTS (SELECT 1 FROM organizations WHERE owner_id = v_user_id) THEN
        RAISE EXCEPTION 'আপনার ইতোমধ্যে একটি নিবন্ধিত প্রতিষ্ঠান রয়েছে।';
    END IF;

    -- প্রতিষ্ঠান তৈরি
    INSERT INTO organizations (name, address, phone, owner_id)
    VALUES (org_name, org_address, org_phone, v_user_id)
    RETURNING id INTO v_org_id;

    SELECT COALESCE(contractor_name, name, 'ঠিকাদার') INTO v_profile_name 
    FROM profiles WHERE id = v_user_id;

    -- ঠিকাদারের প্রোফাইল আপডেট বা তৈরি
    INSERT INTO profiles (
        id, organization_id, role, name, mobile, email, status, must_change_password
    )
    VALUES (
        v_user_id,
        v_org_id,
        'contractor',
        COALESCE(v_profile_name, 'ঠিকাদার'),
        contractor_mobile,
        (SELECT email FROM auth.users WHERE id = v_user_id),
        'active',
        false
    )
    ON CONFLICT (id) DO UPDATE SET
        organization_id = v_org_id,
        role = 'contractor',
        mobile = contractor_mobile,
        status = 'active',
        must_change_password = false,
        updated_at = now();

    -- প্রতিষ্ঠানের জন্য প্রাথমিক ডিফল্ট পদ ও মজুরি হার যুক্ত করা
    INSERT INTO designations (organization_id, name, daily_rate, overtime_rate_per_hour)
    VALUES 
        (v_org_id, 'রাজমিস্ত্রি', 900.00, 120.00),
        (v_org_id, 'সহকারী মিস্ত্রি', 750.00, 100.00),
        (v_org_id, 'সাধারণ শ্রমিক', 600.00, 80.00),
        (v_org_id, 'সাইট সুপারভাইজার', 1000.00, 150.00);

    -- অডিট লগ
    INSERT INTO audit_logs (
        organization_id, actor_id, actor_role, action, table_name, record_id, new_data
    )
    VALUES (
        v_org_id,
        v_user_id,
        'contractor',
        'CREATE_ORGANIZATION',
        'organizations',
        v_org_id,
        jsonb_build_object('name', org_name, 'phone', org_phone)
    );

    RETURN jsonb_build_object(
        'success', true,
        'organization_id', v_org_id,
        'name', org_name
    );
END;
$$;

-- ----------------------------------------------------------------------------
-- 2. RPC: জিও-ফেন্স ও ব্যাকডেট যাচাইসহ হাজিরা প্রদান (Mark Attendance)
-- ----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION mark_attendance(
    p_entry_id UUID,
    p_worker_id UUID,
    p_status attendance_status,
    p_overtime_hours NUMERIC DEFAULT 0.00,
    p_lat DOUBLE PRECISION DEFAULT NULL,
    p_lng DOUBLE PRECISION DEFAULT NULL,
    p_accuracy DOUBLE PRECISION DEFAULT NULL,
    p_backdate_reason TEXT DEFAULT NULL
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
    v_user_id UUID := auth.uid();
    v_user_role user_role;
    v_org_id UUID;
    v_project_id UUID;
    v_entry_date DATE;
    v_entry_status entry_status;
    v_site_lat DOUBLE PRECISION;
    v_site_lng DOUBLE PRECISION;
    v_radius INTEGER;
    v_distance DOUBLE PRECISION;
    v_loc_status location_status := 'not_available';
    v_appr_status approval_status := 'auto';
    v_attendance_id UUID;
    v_days_diff INTEGER;
BEGIN
    IF v_user_id IS NULL THEN
        RAISE EXCEPTION 'অননুমোদিত অ্যাক্সেস।';
    END IF;

    -- ইউজারের ভূমিকা ও প্রতিষ্ঠান নেওয়া
    SELECT role, organization_id INTO v_user_role, v_org_id
    FROM profiles WHERE id = v_user_id;

    -- এন্ট্রি তথ্য আনা
    SELECT de.project_id, de.entry_date, de.status, p.lat, p.lng, p.geofence_radius_m
    INTO v_project_id, v_entry_date, v_entry_status, v_site_lat, v_site_lng, v_radius
    FROM daily_entries de
    JOIN projects p ON p.id = de.project_id
    WHERE de.id = p_entry_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'দৈনিক এন্ট্রি পাওয়া যায়নি।';
    END IF;

    -- এন্ট্রি খোলা আছে কি না
    IF v_entry_status != 'open' AND v_user_role != 'contractor' THEN
        RAISE EXCEPTION 'এই এন্ট্রিটি বন্ধ বা জমা দেওয়া হয়েছে। নতুন হাজিরা নেওয়া যাবে না।';
    END IF;

    -- ব্যাকডেটেড নিয়ম যাচাই
    v_days_diff := CURRENT_DATE - v_entry_date;

    IF v_user_role IN ('supervisor', 'worker') THEN
        IF v_days_diff > 1 THEN
            RAISE EXCEPTION 'শুধুমাত্র আজ ও গতকালের হাজিরা এন্ট্রি করা সম্ভব।';
        ELSIF v_days_diff = 1 AND (p_backdate_reason IS NULL OR trim(p_backdate_reason) = '') THEN
            RAISE EXCEPTION 'গতকালের ব্যাকডেটেড হাজিরার জন্য কারণ লেখা বাধ্যতামূলক।';
        END IF;
    ELSIF v_user_role = 'contractor' THEN
        IF v_days_diff > 7 THEN
            RAISE EXCEPTION 'ঠিকাদার সর্বোচ্চ ৭ দিন পর্যন্ত ব্যাকডেটেড এন্ট্রি করতে পারবেন।';
        END IF;
    END IF;

    -- একই দিনে অন্য প্রজেক্টে হাজিরা আছে কি না যাচাই (Rule 30)
    IF EXISTS (
        SELECT 1 FROM attendance 
        WHERE worker_id = p_worker_id 
          AND entry_date = v_entry_date 
          AND entry_id != p_entry_id
    ) THEN
        RAISE EXCEPTION 'এই শ্রমিক ইতোমধ্যে এই তারিখে অন্য একটি প্রজেক্টে হাজিরা দিয়েছেন।';
    END IF;

    -- GPS ও জিও-ফেন্স যাচাই
    IF p_lat IS NOT NULL AND p_lng IS NOT NULL AND v_site_lat IS NOT NULL AND v_site_lng IS NOT NULL THEN
        v_distance := calculate_distance_meters(p_lat, p_lng, v_site_lat, v_site_lng);
        IF v_distance <= v_radius THEN
            v_loc_status := 'verified';
            v_appr_status := 'auto';
        ELSE
            v_loc_status := 'outside_site';
            v_appr_status := 'pending'; -- ঠিকাদারের অনুমোদন আবশ্যক
        END IF;
    ELSE
        v_loc_status := 'not_available';
        -- শ্রমিক নিজে লোকেশন ছাড়া হাজিরা দিলে ঠিকাদারের অনুমোদন লাগবে
        IF v_user_role = 'worker' THEN
            v_appr_status := 'pending';
        END IF;
    END IF;

    -- হাজিরা ইনসার্ট বা আপডেট
    INSERT INTO attendance (
        organization_id, entry_id, worker_id, entry_date, status,
        overtime_hours, marked_by, marked_at, latitude, longitude,
        accuracy_m, distance_m, location_status, approval_status
    )
    VALUES (
        v_org_id, p_entry_id, p_worker_id, v_entry_date, p_status,
        COALESCE(p_overtime_hours, 0.00), v_user_id, now(), p_lat, p_lng,
        p_accuracy, v_distance, v_loc_status, v_appr_status
    )
    ON CONFLICT (entry_id, worker_id) DO UPDATE SET
        status = EXCLUDED.status,
        overtime_hours = EXCLUDED.overtime_hours,
        marked_by = EXCLUDED.marked_by,
        marked_at = now(),
        latitude = EXCLUDED.latitude,
        longitude = EXCLUDED.longitude,
        accuracy_m = EXCLUDED.accuracy_m,
        distance_m = EXCLUDED.distance_m,
        location_status = EXCLUDED.location_status,
        approval_status = EXCLUDED.approval_status,
        updated_at = now()
    RETURNING id INTO v_attendance_id;

    RETURN jsonb_build_object(
        'success', true,
        'attendance_id', v_attendance_id,
        'location_status', v_loc_status,
        'approval_status', v_appr_status,
        'distance_m', round(v_distance::numeric, 1)
    );
END;
$$;

-- ----------------------------------------------------------------------------
-- 3. TRIGGER & FUNCTION: স্বয়ংক্রিয় মজুরি খতিয়ান তৈরি (Wage Ledger Sync)
-- হাজিরা অনুমোদিত বা স্বয়ংক্রিয়ভাবে গৃহীত হলে মজুরি হিসেবে অন্তর্ভুক্ত হবে
-- ----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION sync_attendance_to_wage_ledger()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
    v_project_id UUID;
    v_designation_id UUID;
    v_daily_rate NUMERIC(12,2) := 0.00;
    v_overtime_rate NUMERIC(12,2) := 0.00;
    v_daily_amount NUMERIC(12,2) := 0.00;
    v_overtime_amount NUMERIC(12,2) := 0.00;
    v_total_amount NUMERIC(12,2) := 0.00;
BEGIN
    -- হাজিরা অনুমোদিত না হলে মজুরিতে আসবে না
    IF NEW.approval_status NOT IN ('auto', 'approved') THEN
        DELETE FROM wage_ledger WHERE attendance_id = NEW.id;
        RETURN NEW;
    END IF;

    -- প্রজেক্ট আইডি আনা
    SELECT project_id INTO v_project_id
    FROM daily_entries WHERE id = NEW.entry_id;

    -- শ্রমিকের পদ ও মজুরি হার আনা
    SELECT p.designation_id, COALESCE(d.daily_rate, 0.00), COALESCE(d.overtime_rate_per_hour, 0.00)
    INTO v_designation_id, v_daily_rate, v_overtime_rate
    FROM profiles p
    LEFT JOIN designations d ON d.id = p.designation_id
    WHERE p.id = NEW.worker_id;

    -- উপস্থিতির ধরন অনুযায়ী মূল মজুরি হিসাব
    IF NEW.status = 'present' THEN
        v_daily_amount := v_daily_rate;
    ELSIF NEW.status = 'half' THEN
        v_daily_amount := round(v_daily_rate / 2.0, 2);
    ELSIF NEW.status = 'overtime' THEN
        v_daily_amount := v_daily_rate;
    ELSE -- absent
        v_daily_amount := 0.00;
    END IF;

    -- ওভারটাইম মজুরি হিসাব
    v_overtime_amount := round(COALESCE(NEW.overtime_hours, 0.00) * v_overtime_rate, 2);
    v_total_amount := v_daily_amount + v_overtime_amount;

    -- মজুরি খতিয়ানে এন্ট্রি বা আপডেট
    INSERT INTO wage_ledger (
        organization_id, project_id, worker_id, work_date, attendance_id,
        designation_id, daily_amount, overtime_amount, total_amount
    )
    VALUES (
        NEW.organization_id, v_project_id, NEW.worker_id, NEW.entry_date, NEW.id,
        v_designation_id, v_daily_amount, v_overtime_amount, v_total_amount
    )
    ON CONFLICT (attendance_id) DO UPDATE SET
        project_id = EXCLUDED.project_id,
        work_date = EXCLUDED.work_date,
        designation_id = EXCLUDED.designation_id,
        daily_amount = EXCLUDED.daily_amount,
        overtime_amount = EXCLUDED.overtime_amount,
        total_amount = EXCLUDED.total_amount;

    RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_sync_attendance_wage ON attendance;
CREATE TRIGGER trg_sync_attendance_wage
AFTER INSERT OR UPDATE OF approval_status, status, overtime_hours
ON attendance
FOR EACH ROW EXECUTE FUNCTION sync_attendance_to_wage_ledger();

-- ----------------------------------------------------------------------------
-- 4. RPC: FIFO পদ্ধতিতে মজুরি পেমেন্ট বরাদ্দ (FIFO Payment Allocation)
-- ----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION allocate_payment_fifo(p_payment_id UUID)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
    v_payment RECORD;
    v_remaining_amount NUMERIC(14,2);
    v_wage RECORD;
    v_allocated_so_far NUMERIC(14,2);
    v_due_amount NUMERIC(14,2);
    v_alloc_amount NUMERIC(14,2);
    v_total_allocated NUMERIC(14,2) := 0.00;
BEGIN
    SELECT * INTO v_payment FROM payments WHERE id = p_payment_id;
    IF NOT FOUND THEN
        RAISE EXCEPTION 'পেমেন্ট রেকর্ড পাওয়া যায়নি।';
    END IF;

    v_remaining_amount := v_payment.amount;

    -- শ্রমিকের বকেয়া মজুরি রেকর্ডগুলো তারিখ অনুযায়ী (সবচেয়ে পুরোনো আগে) আনা
    FOR v_wage IN 
        SELECT wl.id, wl.project_id, wl.total_amount, wl.work_date
        FROM wage_ledger wl
        WHERE wl.worker_id = v_payment.payee_id
        ORDER BY wl.work_date ASC, wl.created_at ASC
    LOOP
        EXIT WHEN v_remaining_amount <= 0;

        -- এই মজুরির বিপরীতে ইতোমধ্যে কত বরাদ্দ হয়েছে
        SELECT COALESCE(SUM(allocated_amount), 0.00) INTO v_allocated_so_far
        FROM payment_allocations
        WHERE wage_ledger_id = v_wage.id;

        v_due_amount := v_wage.total_amount - v_allocated_so_far;

        IF v_due_amount > 0 THEN
            v_alloc_amount := LEAST(v_remaining_amount, v_due_amount);

            INSERT INTO payment_allocations (
                payment_id, project_id, wage_ledger_id, allocated_amount, method
            )
            VALUES (
                p_payment_id, v_wage.project_id, v_wage.id, v_alloc_amount, 'fifo'
            );

            v_remaining_amount := v_remaining_amount - v_alloc_amount;
            v_total_allocated := v_total_allocated + v_alloc_amount;
        END IF;
    END LOOP;

    RETURN jsonb_build_object(
        'success', true,
        'payment_id', p_payment_id,
        'total_allocated', v_total_allocated,
        'unallocated_advance', v_remaining_amount
    );
END;
$$;

-- ----------------------------------------------------------------------------
-- 5. TRIGGER: সুপারভাইজার অ্যাসাইনমেন্ট সরালে খোলা এন্ট্রি 'হস্তান্তর প্রয়োজন' করা
-- PRD নিয়ম ২০: "সরানোর সময় খোলা এন্ট্রিগুলো 'হস্তান্তর প্রয়োজন' অবস্থায় যাবে"
-- ----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION handle_supervisor_unassignment()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
    IF OLD.unassigned_at IS NULL AND NEW.unassigned_at IS NOT NULL THEN
        -- এই প্রজেক্টে সুপারভাইজারের খোলা এন্ট্রিগুলো handover_required করা
        UPDATE daily_entries
        SET status = 'handover_required', updated_at = now()
        WHERE project_id = NEW.project_id
          AND opened_by = NEW.supervisor_id
          AND status = 'open';

        -- ঠিকাদারকে নোটিফিকেশন পাঠানো
        INSERT INTO notifications (
            organization_id, user_id, type, title, body, data
        )
        SELECT 
            NEW.organization_id,
            o.owner_id,
            'HANDOVER_REQUIRED',
            'এন্ট্রি হস্তান্তর প্রয়োজন',
            'একজন সুপারভাইজারকে সরানোর কারণে তার খোলা এন্ট্রি হস্তান্তর তালিকায় রাখা হয়েছে।',
            jsonb_build_object('project_id', NEW.project_id, 'supervisor_id', NEW.supervisor_id)
        FROM organizations o
        WHERE o.id = NEW.organization_id;
    END IF;
    RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_supervisor_unassign ON supervisor_assignments;
CREATE TRIGGER trg_supervisor_unassign
AFTER UPDATE OF unassigned_at ON supervisor_assignments
FOR EACH ROW EXECUTE FUNCTION handle_supervisor_unassignment();
-- ============================================================================
-- Migration: 05_project_management_rpcs.sql
-- Project: Project Khata (প্রজেক্ট খাতা) - Version 2.1
-- Description: Project Creation with Client, Supervisor Assignments & Status Control
-- ============================================================================

-- ----------------------------------------------------------------------------
-- 1. RPC: ক্লায়েন্ট তথ্য ও সাইট লোকেশনসহ প্রজেক্ট তৈরি (Create Project with Client)
-- PRD সেকশন ৩.২ ও ৩.৩ অনুযায়ী:
-- - লোকেশন বাধ্যতামূলক (lat, lng NOT NULL)
-- - ক্লায়েন্ট আলাদা যোগ করার বাটন নেই; প্রজেক্ট তৈরির সময় নাম ও মোবাইল বাধ্যতামূলক
-- - মোবাইল আগে থাকলে বিদ্যমান ক্লায়েন্টের সাথে যুক্ত হবে, না থাকলে নতুন ক্লায়েন্ট তৈরি হবে
-- ----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION create_project_with_client(
    p_name TEXT,
    p_type project_type,
    p_address TEXT,
    p_lat DOUBLE PRECISION,
    p_lng DOUBLE PRECISION,
    p_geofence_radius_m INTEGER,
    p_budget NUMERIC,
    p_client_name TEXT,
    p_client_mobile TEXT,
    p_status project_status DEFAULT 'active'
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
    v_user_id UUID := auth.uid();
    v_org_id UUID;
    v_project_id UUID;
    v_client_id UUID;
    v_is_new_client BOOLEAN := false;
    v_clean_mobile TEXT;
    v_radius INTEGER;
BEGIN
    IF v_user_id IS NULL THEN
        RAISE EXCEPTION 'লগইন করা আবশ্যক।';
    END IF;

    -- ঠিকাদার যাচাই
    IF NOT is_contractor() THEN
        RAISE EXCEPTION 'শুধুমাত্র ঠিকাদার নতুন প্রজেক্ট তৈরি করতে পারবেন।';
    END IF;

    v_org_id := get_current_org_id();
    IF v_org_id IS NULL THEN
        RAISE EXCEPTION 'প্রতিষ্ঠানের তথ্য পাওয়া যায়নি। আগে প্রতিষ্ঠান সেটআপ সম্পন্ন করুন।';
    END IF;

    -- সাইট লোকেশন বাধ্যতামূলক যাচাই
    IF p_lat IS NULL OR p_lng IS NULL THEN
        RAISE EXCEPTION 'সাইট লোকেশন বাধ্যতামূলক। লোকেশন ছাড়া প্রজেক্ট সেভ হবে না।';
    END IF;

    -- জিও-ফেন্স সীমা যাচাই (১০০–২০০ মিটার)
    v_radius := COALESCE(p_geofence_radius_m, 150);
    IF v_radius < 100 OR v_radius > 200 THEN
        RAISE EXCEPTION 'জিও-ফেন্স রেডিয়াস ১০০ থেকে ২০০ মিটারের মধ্যে হতে হবে।';
    END IF;

    -- ক্লায়েন্ট মোবাইল যাচাই (বাংলাদেশি ফরম্যাট)
    v_clean_mobile := trim(p_client_mobile);
    IF v_clean_mobile !~ '^01[3-9][0-9]{8}$' THEN
        RAISE EXCEPTION 'সঠিক ১১ সংখ্যার বাংলাদেশি মোবাইল নম্বর দিন (০১৩–০১৯)।';
    END IF;

    -- ১. প্রজেক্ট ইনসার্ট
    INSERT INTO projects (
        organization_id, name, type, address, lat, lng,
        geofence_radius_m, status, budget
    )
    VALUES (
        v_org_id, trim(p_name), p_type, trim(p_address), p_lat, p_lng,
        v_radius, p_status, COALESCE(p_budget, 0.00)
    )
    RETURNING id INTO v_project_id;

    -- ২. ক্লায়েন্ট প্রোফাইল যাচাই বা তৈরি
    SELECT id INTO v_client_id
    FROM profiles
    WHERE organization_id = v_org_id AND mobile = v_clean_mobile;

    IF v_client_id IS NULL THEN
        -- নতুন ক্লায়েন্ট রেকর্ড তৈরি (auth.users এ ডেমো বা Edge Function দিয়ে তৈরি হবে, প্রোফাইলে রেকর্ড রাখা হচ্ছে)
        v_is_new_client := true;
        v_client_id := gen_random_uuid();

        INSERT INTO profiles (
            id, organization_id, role, name, mobile, must_change_password, status
        )
        VALUES (
            v_client_id, v_org_id, 'client', trim(p_client_name), v_clean_mobile, true, 'active'
        );
    END IF;

    -- ৩. প্রজেক্টের সাথে ক্লায়েন্ট সংযোগ (project_clients)
    INSERT INTO project_clients (project_id, client_profile_id)
    VALUES (v_project_id, v_client_id)
    ON CONFLICT (project_id, client_profile_id) DO NOTHING;

    -- ৪. অডিট লগ
    INSERT INTO audit_logs (
        organization_id, actor_id, actor_role, action, table_name, record_id, new_data
    )
    VALUES (
        v_org_id, v_user_id, 'contractor', 'CREATE_PROJECT', 'projects', v_project_id,
        jsonb_build_object(
            'project_name', p_name,
            'client_mobile', v_clean_mobile,
            'is_new_client', v_is_new_client
        )
    );

    RETURN jsonb_build_object(
        'success', true,
        'project_id', v_project_id,
        'client_id', v_client_id,
        'is_new_client', v_is_new_client,
        'client_mobile', v_clean_mobile
    );
END;
$$;

-- ----------------------------------------------------------------------------
-- 2. RPC: সুপারভাইজার অ্যাসাইনমেন্ট পরিবর্তন (Assign/Unassign Supervisors)
-- ----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION sync_project_supervisors(
    p_project_id UUID,
    p_supervisor_ids UUID[]
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
    v_user_id UUID := auth.uid();
    v_org_id UUID;
    v_sup_id UUID;
BEGIN
    IF NOT is_contractor() THEN
        RAISE EXCEPTION 'শুধুমাত্র ঠিকাদার সুপারভাইজার অ্যাসাইন করতে পারেন।';
    END IF;

    v_org_id := get_current_org_id();

    -- যেসব সুপারভাইজার তালিকায় নেই কিন্তু আগে সক্রিয় ছিল, তাদের unassigned_at সেট করা
    -- (এটি ট্রিগারের মাধ্যমে স্বয়ংক্রিয়ভাবে তাদের খোলা এন্ট্রিকে handover_required করবে)
    UPDATE supervisor_assignments
    SET unassigned_at = now()
    WHERE project_id = p_project_id
      AND unassigned_at IS NULL
      AND supervisor_id != ALL(p_supervisor_ids);

    -- নতুন সুপারভাইজারদের অ্যাসাইন করা
    IF p_supervisor_ids IS NOT NULL THEN
        FOREACH v_sup_id IN ARRAY p_supervisor_ids
        LOOP
            IF NOT EXISTS (
                SELECT 1 FROM supervisor_assignments
                WHERE project_id = p_project_id 
                  AND supervisor_id = v_sup_id 
                  AND unassigned_at IS NULL
            ) THEN
                INSERT INTO supervisor_assignments (
                    organization_id, project_id, supervisor_id, assigned_at
                )
                VALUES (
                    v_org_id, p_project_id, v_sup_id, now()
                );
            END IF;
        END LOOP;
    END IF;

    RETURN jsonb_build_object('success', true);
END;
$$;
-- ============================================================================
-- Migration: 06_daily_entry_and_attendance_rpcs.sql
-- Project: Project Khata (প্রজেক্ট খাতা) - Version 2.1
-- Description: Daily Entry Lifecycle, Team Formation, Approval Workflow & Handover
-- ============================================================================

-- ----------------------------------------------------------------------------
-- 1. RPC: দৈনিক এন্ট্রি খোলা (Open Daily Entry)
-- ----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION open_daily_entry(
    p_project_id UUID,
    p_entry_date DATE,
    p_backdate_reason TEXT DEFAULT NULL
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
    v_user_id UUID := auth.uid();
    v_user_role user_role;
    v_org_id UUID;
    v_project_status project_status;
    v_days_diff INTEGER;
    v_is_backdated BOOLEAN := false;
    v_entry_id UUID;
BEGIN
    IF v_user_id IS NULL THEN
        RAISE EXCEPTION 'লগইন করা আবশ্যক।';
    END IF;

    SELECT role, organization_id INTO v_user_role, v_org_id
    FROM profiles WHERE id = v_user_id;

    -- প্রজেক্ট স্ট্যাটাস যাচাই (শুধু 'চলমান' প্রজেক্টে এন্ট্রি খোলা যাবে)
    SELECT status INTO v_project_status
    FROM projects WHERE id = p_project_id;

    IF v_project_status != 'active' THEN
        RAISE EXCEPTION 'শুধুমাত্র "চলমান" প্রজেক্টে নতুন দৈনিক এন্ট্রি খোলা সম্ভব।';
    END IF;

    -- অনুমতি যাচাই (ঠিকাদার বা অ্যাসাইনকৃত সুপারভাইজার)
    IF v_user_role != 'contractor' AND NOT is_assigned_supervisor(p_project_id) THEN
        RAISE EXCEPTION 'আপনি এই প্রজেক্টে অ্যাসাইনকৃত নন। এন্ট্রি খুলতে পারবেন না।';
    END IF;

    -- ব্যাকডেটেড নিয়ম যাচাই
    v_days_diff := CURRENT_DATE - p_entry_date;
    IF v_days_diff < 0 THEN
        RAISE EXCEPTION 'ভবিষ্যতের তারিখে এন্ট্রি খোলা যাবে না।';
    END IF;

    IF v_days_diff > 0 THEN
        v_is_backdated := true;
        IF v_user_role = 'supervisor' THEN
            IF v_days_diff > 1 THEN
                RAISE EXCEPTION 'সুপারভাইজার শুধুমাত্র আজ ও গতকালের এন্ট্রি খুলতে পারেন।';
            ELSIF p_backdate_reason IS NULL OR trim(p_backdate_reason) = '' THEN
                RAISE EXCEPTION 'গতকালের ব্যাকডেটেড এন্ট্রির জন্য কারণ লেখা বাধ্যতামূলক।';
            END IF;
        ELSIF v_user_role = 'contractor' THEN
            IF v_days_diff > 7 THEN
                RAISE EXCEPTION 'ঠিকাদার সর্বোচ্চ ৭ দিন পর্যন্ত ব্যাকডেটেড এন্ট্রি করতে পারবেন।';
            END IF;
        END IF;
    END IF;

    -- একই প্রজেক্টে একই তারিখে একাধিক এন্ট্রি নয় (Rule 25)
    IF EXISTS (SELECT 1 FROM daily_entries WHERE project_id = p_project_id AND entry_date = p_entry_date) THEN
        RAISE EXCEPTION 'এই প্রজেক্টে এই তারিখে ইতোমধ্যে একটি এন্ট্রি খোলা রয়েছে।';
    END IF;

    -- দৈনিক এন্ট্রি তৈরি
    INSERT INTO daily_entries (
        organization_id, project_id, entry_date, status, opened_by,
        is_backdated, backdate_reason
    )
    VALUES (
        v_org_id, p_project_id, p_entry_date, 'open', v_user_id,
        v_is_backdated, p_backdate_reason
    )
    RETURNING id INTO v_entry_id;

    -- সেদিনের দল রেকর্ড তৈরি (সুপারভাইজার যুক্ত)
    INSERT INTO entry_teams (entry_id, supervisor_id, team_date)
    VALUES (v_entry_id, v_user_id, p_entry_date);

    -- অডিট লগ
    INSERT INTO audit_logs (
        organization_id, actor_id, actor_role, action, table_name, record_id, new_data
    )
    VALUES (
        v_org_id, v_user_id, v_user_role, 'OPEN_DAILY_ENTRY', 'daily_entries', v_entry_id,
        jsonb_build_object(
            'project_id', p_project_id,
            'entry_date', p_entry_date,
            'is_backdated', v_is_backdated
        )
    );

    RETURN jsonb_build_object(
        'success', true,
        'entry_id', v_entry_id,
        'entry_date', p_entry_date,
        'status', 'open'
    );
END;
$$;

-- ----------------------------------------------------------------------------
-- 2. RPC: দৈনিক এন্ট্রি জমা দেওয়া (Submit Daily Entry)
-- ----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION submit_daily_entry(p_entry_id UUID)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
    v_user_id UUID := auth.uid();
    v_org_id UUID;
    v_project_id UUID;
    v_opened_by UUID;
    v_status entry_status;
BEGIN
    SELECT organization_id, project_id, opened_by, status
    INTO v_org_id, v_project_id, v_opened_by, v_status
    FROM daily_entries WHERE id = p_entry_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'দৈনিক এন্ট্রি পাওয়া যায়নি।';
    END IF;

    IF v_status != 'open' THEN
        RAISE EXCEPTION 'শুধুমাত্র "খোলা" এন্ট্রি জমা দেওয়া সম্ভব।';
    END IF;

    IF NOT is_contractor() AND v_opened_by != v_user_id THEN
        RAISE EXCEPTION 'শুধুমাত্র যিনি এন্ট্রি খুলেছেন বা ঠিকাদার এটি জমা দিতে পারবেন।';
    END IF;

    UPDATE daily_entries
    SET status = 'submitted', submitted_at = now(), updated_at = now()
    WHERE id = p_entry_id;

    -- ঠিকাদারকে নোটিফিকেশন পাঠানো
    INSERT INTO notifications (
        organization_id, user_id, type, title, body, data
    )
    SELECT
        v_org_id,
        o.owner_id,
        'ENTRY_SUBMITTED',
        'দৈনিক এন্ট্রি জমা দেওয়া হয়েছে',
        'আজকের সাইট এন্ট্রি পর্যালোচনার জন্য জমা দেওয়া হয়েছে।',
        jsonb_build_object('entry_id', p_entry_id, 'project_id', v_project_id)
    FROM organizations o
    WHERE o.id = v_org_id;

    RETURN jsonb_build_object('success', true, 'status', 'submitted');
END;
$$;

-- ----------------------------------------------------------------------------
-- 3. RPC: এন্ট্রি অনুমোদন ও লক করা (Approve & Lock Daily Entry)
-- ----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION approve_daily_entry(p_entry_id UUID)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
    IF NOT is_contractor() THEN
        RAISE EXCEPTION 'শুধুমাত্র ঠিকাদার এন্ট্রি অনুমোদন করতে পারবেন।';
    END IF;

    UPDATE daily_entries
    SET status = 'locked', locked_at = now(), updated_at = now()
    WHERE id = p_entry_id;

    -- এন্ট্রির সব অপেক্ষমাণ হাজিরা অটো-অনুমোদিত করা
    UPDATE attendance
    SET approval_status = 'approved', approved_by = auth.uid(), updated_at = now()
    WHERE entry_id = p_entry_id AND approval_status = 'pending';

    RETURN jsonb_build_object('success', true, 'status', 'locked');
END;
$$;

-- ----------------------------------------------------------------------------
-- 4. RPC: সাইটের বাইরের বা ব্যাকডেটেড হাজিরা অনুমোদন / প্রত্যাখ্যান
-- ----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION decide_attendance_approval(
    p_attendance_id UUID,
    p_approved BOOLEAN,
    p_rejection_reason TEXT DEFAULT NULL
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
    v_status approval_status;
BEGIN
    IF NOT is_contractor() THEN
        RAISE EXCEPTION 'শুধুমাত্র ঠিকাদার হাজিরা অনুমোদন বা প্রত্যাখ্যান করতে পারবেন।';
    END IF;

    v_status := CASE WHEN p_approved THEN 'approved'::approval_status ELSE 'rejected'::approval_status END;

    UPDATE attendance
    SET 
        approval_status = v_status,
        approved_by = auth.uid(),
        updated_at = now()
    WHERE id = p_attendance_id;

    RETURN jsonb_build_object(
        'success', true,
        'attendance_id', p_attendance_id,
        'approval_status', v_status
    );
END;
$$;

-- ----------------------------------------------------------------------------
-- 5. RPC: হস্তান্তর প্রয়োজন এন্ট্রি সমাধান (Resolve Handover Entry)
-- ----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION resolve_handover_entry(
    p_entry_id UUID,
    p_action TEXT, -- 'close' অথবা 'reassign'
    p_new_supervisor_id UUID DEFAULT NULL
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
    IF NOT is_contractor() THEN
        RAISE EXCEPTION 'শুধুমাত্র ঠিকাদার হস্তান্তর এন্ট্রি সমাধান করতে পারবেন।';
    END IF;

    IF p_action = 'close' THEN
        UPDATE daily_entries
        SET status = 'submitted', updated_at = now()
        WHERE id = p_entry_id AND status = 'handover_required';
    ELSIF p_action = 'reassign' THEN
        IF p_new_supervisor_id IS NULL THEN
            RAISE EXCEPTION 'নতুন সুপারভাইজার নির্বাচন করা আবশ্যক।';
        END IF;

        UPDATE daily_entries
        SET 
            opened_by = p_new_supervisor_id,
            status = 'open',
            updated_at = now()
        WHERE id = p_entry_id AND status = 'handover_required';
    ELSE
        RAISE EXCEPTION 'অকার্যকর অ্যাকশন।';
    END IF;

    RETURN jsonb_build_object('success', true);
END;
$$;
-- ============================================================================
-- Migration: 07_accounting_and_billing_rpcs.sql
-- Project: Project Khata (প্রজেক্ট খাতা) - Version 2.1
-- Description: Financial Aggregation, Worker Payments, FIFO, Materials & Bill Statements
-- ============================================================================

-- ----------------------------------------------------------------------------
-- 1. RPC: শ্রমিক বা সুপারভাইজারকে পেমেন্ট ও স্বয়ংক্রিয় FIFO বরাদ্দ
-- ----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION record_worker_payment(
    p_payee_id UUID,
    p_amount NUMERIC,
    p_payment_date DATE,
    p_note TEXT DEFAULT NULL
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
    v_user_id UUID := auth.uid();
    v_org_id UUID;
    v_payee_role user_role;
    v_payment_id UUID;
    v_fifo_result JSONB;
BEGIN
    IF NOT is_contractor() THEN
        RAISE EXCEPTION 'শুধুমাত্র ঠিকাদার পেমেন্ট এন্ট্রি করতে পারবেন।';
    END IF;

    v_org_id := get_current_org_id();

    SELECT role INTO v_payee_role
    FROM profiles WHERE id = p_payee_id;

    IF v_payee_role IS NULL THEN
        RAISE EXCEPTION 'প্রাপক প্রোফাইল পাওয়া যায়নি।';
    END IF;

    -- পেমেন্ট রেকর্ড
    INSERT INTO payments (
        organization_id, payee_id, payee_role, amount, payment_date, note, created_by
    )
    VALUES (
        v_org_id, p_payee_id, v_payee_role, p_amount, COALESCE(p_payment_date, CURRENT_DATE), p_note, v_user_id
    )
    RETURNING id INTO v_payment_id;

    -- ডিফল্ট FIFO বরাদ্দ সম্পাদন
    v_fifo_result := allocate_payment_fifo(v_payment_id);

    -- অডিট লগ
    INSERT INTO audit_logs (
        organization_id, actor_id, actor_role, action, table_name, record_id, new_data
    )
    VALUES (
        v_org_id, v_user_id, 'contractor', 'RECORD_WORKER_PAYMENT', 'payments', v_payment_id,
        jsonb_build_object('payee_id', p_payee_id, 'amount', p_amount, 'fifo', v_fifo_result)
    );

    RETURN jsonb_build_object(
        'success', true,
        'payment_id', v_payment_id,
        'amount', p_amount,
        'allocation', v_fifo_result
    );
END;
$$;

-- ----------------------------------------------------------------------------
-- 2. RPC: ক্লায়েন্ট পেমেন্ট রেকর্ড
-- ----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION record_client_payment(
    p_project_id UUID,
    p_amount NUMERIC,
    p_payment_date DATE,
    p_note TEXT DEFAULT NULL
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
    v_user_id UUID := auth.uid();
    v_org_id UUID;
    v_payment_id UUID;
BEGIN
    IF NOT is_contractor() THEN
        RAISE EXCEPTION 'শুধুমাত্র ঠিকাদার ক্লায়েন্ট পেমেন্ট রেকর্ড করতে পারবেন।';
    END IF;

    v_org_id := get_current_org_id();

    INSERT INTO client_payments (
        organization_id, project_id, amount, payment_date, note, created_by
    )
    VALUES (
        v_org_id, p_project_id, p_amount, COALESCE(p_payment_date, CURRENT_DATE), p_note, v_user_id
    )
    RETURNING id INTO v_payment_id;

    -- অডিট লগ
    INSERT INTO audit_logs (
        organization_id, actor_id, actor_role, action, table_name, record_id, new_data
    )
    VALUES (
        v_org_id, v_user_id, 'contractor', 'RECORD_CLIENT_PAYMENT', 'client_payments', v_payment_id,
        jsonb_build_object('project_id', p_project_id, 'amount', p_amount)
    );

    RETURN jsonb_build_object(
        'success', true,
        'payment_id', v_payment_id,
        'amount', p_amount
    );
END;
$$;

-- ----------------------------------------------------------------------------
-- 3. RPC: সাইট খরচ অনুমোদন বা প্রত্যাখ্যান
-- ----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION decide_site_expense(
    p_expense_id UUID,
    p_status expense_status,
    p_reason TEXT DEFAULT NULL
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
    IF NOT is_contractor() THEN
        RAISE EXCEPTION 'শুধুমাত্র ঠিকাদার সাইট খরচ অনুমোদন করতে পারবেন।';
    END IF;

    IF p_status = 'rejected' AND (p_reason IS NULL OR trim(p_reason) = '') THEN
        RAISE EXCEPTION 'সাইট খরচ প্রত্যাখ্যানে কারণ লেখা বাধ্যতামূলক।';
    END IF;

    UPDATE site_expenses
    SET 
        status = p_status,
        decided_by = auth.uid(),
        decision_reason = p_reason,
        updated_at = now()
    WHERE id = p_expense_id;

    RETURN jsonb_build_object('success', true, 'status', p_status);
END;
$$;

-- ----------------------------------------------------------------------------
-- 4. RPC: শ্রমিক-বিল খতিয়ান তৈরি, স্ন্যাপশট লক ও ক্লায়েন্টকে পাঠানো
-- ----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION generate_and_send_bill_statement(
    p_project_id UUID,
    p_period_from DATE,
    p_period_to DATE,
    p_preset statement_preset DEFAULT 'monthly'
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
    v_user_id UUID := auth.uid();
    v_org_id UUID;
    v_total_wage NUMERIC(14,2) := 0.00;
    v_total_material NUMERIC(14,2) := 0.00;
    v_total_expense NUMERIC(14,2) := 0.00;
    v_total_client_paid NUMERIC(14,2) := 0.00;
    v_total_days INTEGER := 0;
    v_snapshot JSONB;
    v_statement_id UUID;
    v_client_id UUID;
BEGIN
    IF NOT is_contractor() THEN
        RAISE EXCEPTION 'শুধুমাত্র ঠিকাদার বিল খতিয়ান পাঠাতে পারবেন।';
    END IF;

    v_org_id := get_current_org_id();

    -- সময়কালের মধ্যে মোট মজুরি ও কর্মদিবস হিসাব
    SELECT 
        COALESCE(SUM(total_amount), 0.00),
        COUNT(DISTINCT work_date)
    INTO v_total_wage, v_total_days
    FROM wage_ledger
    WHERE project_id = p_project_id 
      AND work_date BETWEEN p_period_from AND p_period_to;

    -- মালামাল খরচ
    SELECT COALESCE(SUM(total_price), 0.00) INTO v_total_material
    FROM materials
    WHERE project_id = p_project_id 
      AND purchase_date BETWEEN p_period_from AND p_period_to;

    -- সাইট খরচ (অনুমোদিত)
    SELECT COALESCE(SUM(amount), 0.00) INTO v_total_expense
    FROM site_expenses
    WHERE project_id = p_project_id 
      AND status = 'approved'
      AND expense_date BETWEEN p_period_from AND p_period_to;

    -- ক্লায়েন্ট কর্তৃক পরিশোধিত অর্থ
    SELECT COALESCE(SUM(amount), 0.00) INTO v_total_client_paid
    FROM client_payments
    WHERE project_id = p_project_id 
      AND payment_date BETWEEN p_period_from AND p_period_to;

    -- অপরিবর্তনীয় স্ন্যাপশট JSON তৈরি (PRD Rule 54)
    v_snapshot := jsonb_build_object(
        'project_id', p_project_id,
        'period_from', p_period_from,
        'period_to', p_period_to,
        'total_working_days', v_total_days,
        'total_wage', v_total_wage,
        'total_material', v_total_material,
        'total_site_expense', v_total_expense,
        'total_billed', (v_total_wage + v_total_material + v_total_expense),
        'total_client_paid', v_total_client_paid,
        'net_due', ((v_total_wage + v_total_material + v_total_expense) - v_total_client_paid),
        'generated_at', now()
    );

    -- খতিয়ান সংরক্ষণ (locked = true)
    INSERT INTO bill_statements (
        organization_id, project_id, period_from, period_to, preset,
        generated_by, sent_to_client_at, snapshot_json, locked
    )
    VALUES (
        v_org_id, p_project_id, p_period_from, p_period_to, p_preset,
        v_user_id, now(), v_snapshot, true
    )
    RETURNING id INTO v_statement_id;

    -- ক্লায়েন্টকে নোটিফিকেশন প্রেরণ
    SELECT client_profile_id INTO v_client_id
    FROM project_clients
    WHERE project_id = p_project_id LIMIT 1;

    IF v_client_id IS NOT NULL THEN
        INSERT INTO notifications (
            organization_id, user_id, type, title, body, data
        )
        VALUES (
            v_org_id,
            v_client_id,
            'NEW_BILL_STATEMENT',
            'নতুন শ্রমিক-বিল খতিয়ান এসেছে',
            'আপনার প্রজেক্টের নির্ধারিত সময়কালের শ্রমিক-বিল খতিয়ান অনুমোদিত ও পাঠানো হয়েছে।',
            jsonb_build_object('statement_id', v_statement_id, 'project_id', p_project_id)
        );
    END IF;

    RETURN jsonb_build_object(
        'success', true,
        'statement_id', v_statement_id,
        'snapshot', v_snapshot
    );
END;
$$;
