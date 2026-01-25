-- ============================================================================
-- 🚨 NUCLEAR OPTION: DELETE ALL PAYMENT POLICIES AND START FRESH
-- ============================================================================
-- This script removes ALL existing policies and creates ONLY secure ones
-- Run this in Supabase SQL Editor IMMEDIATELY

-- =============================================================================
-- STEP 1: DROP ALL EXISTING POLICIES (NUCLEAR CLEAN)
-- =============================================================================

-- PAYMENTS table - drop ALL policies
DROP POLICY IF EXISTS "payments_select_secure" ON payments;
DROP POLICY IF EXISTS "payments_select_admin_or_owner" ON payments;
DROP POLICY IF EXISTS "payments_select_own" ON payments;
DROP POLICY IF EXISTS "payments_insert_anon_or_admin" ON payments;
DROP POLICY IF EXISTS "payments_insert_anon" ON payments;
DROP POLICY IF EXISTS "payments_update_admin_or_gmail" ON payments;
DROP POLICY IF EXISTS "payments_update_gmail_id" ON payments;
DROP POLICY IF EXISTS "payments_delete_admin" ON payments;
DROP POLICY IF EXISTS "Enable read access for all users" ON payments;
DROP POLICY IF EXISTS "Allow public read access" ON payments;
DROP POLICY IF EXISTS "Allow anonymous inserts" ON payments;
DROP POLICY IF EXISTS "allow_anon_read_payments" ON payments;
DROP POLICY IF EXISTS "anon_read_payments" ON payments;
DROP POLICY IF EXISTS "allow_anon_insert_payments" ON payments;
DROP POLICY IF EXISTS "allow_anon_update_payments" ON payments;
DROP POLICY IF EXISTS "admin_can_select_payments" ON payments;
DROP POLICY IF EXISTS "admin_can_modify_payments" ON payments;
DROP POLICY IF EXISTS "admin_can_delete_payments" ON payments;

-- PAYMENT_RECORDS table - drop ALL policies
DROP POLICY IF EXISTS "payment_records_select_secure" ON payment_records;
DROP POLICY IF EXISTS "payment_records_select_admin_or_owner" ON payment_records;
DROP POLICY IF EXISTS "payment_records_select_own" ON payment_records;
DROP POLICY IF EXISTS "payment_records_insert_admin" ON payment_records;
DROP POLICY IF EXISTS "payment_records_update_admin" ON payment_records;
DROP POLICY IF EXISTS "payment_records_delete_admin" ON payment_records;
DROP POLICY IF EXISTS "payment_records_write_admin_only" ON payment_records;
DROP POLICY IF EXISTS "Enable read access for all users" ON payment_records;
DROP POLICY IF EXISTS "anon_read_payment_records" ON payment_records;
DROP POLICY IF EXISTS "Allow test suite access to payment_records" ON payment_records;

-- CREDIT_PAYMENTS table - drop ALL policies
DROP POLICY IF EXISTS "credit_payments_select_secure" ON credit_payments;
DROP POLICY IF EXISTS "credit_payments_select_admin_or_owner" ON credit_payments;
DROP POLICY IF EXISTS "credit_payments_select_own" ON credit_payments;
DROP POLICY IF EXISTS "credit_payments_insert_admin" ON credit_payments;
DROP POLICY IF EXISTS "credit_payments_update_admin" ON credit_payments;
DROP POLICY IF EXISTS "credit_payments_delete_admin" ON credit_payments;
DROP POLICY IF EXISTS "credit_payments_write_admin_only" ON credit_payments;
DROP POLICY IF EXISTS "anon_read_credit_payments" ON credit_payments;
DROP POLICY IF EXISTS "auth_only_credit_payments" ON credit_payments;

-- =============================================================================
-- STEP 2: FORCE ENABLE RLS (no exceptions)
-- =============================================================================

ALTER TABLE payments ENABLE ROW LEVEL SECURITY;
ALTER TABLE payment_records ENABLE ROW LEVEL SECURITY;
ALTER TABLE credit_payments ENABLE ROW LEVEL SECURITY;

-- Force RLS even for table owner
ALTER TABLE payments FORCE ROW LEVEL SECURITY;
ALTER TABLE payment_records FORCE ROW LEVEL SECURITY;
ALTER TABLE credit_payments FORCE ROW LEVEL SECURITY;

-- =============================================================================
-- STEP 3: CREATE MINIMAL SECURE POLICIES
-- =============================================================================

-- -----------------------------------------------------------------------------
-- PAYMENTS TABLE (Zelle/Venmo imports)
-- -----------------------------------------------------------------------------

-- SELECT: Students see ONLY their own payments, Admins see all
CREATE POLICY "payments_select_student_own_or_admin"
ON payments
FOR SELECT
TO authenticated
USING (
  -- Admin can see everything
  is_arnoma_admin()
  OR
  -- Students can ONLY see payments linked to their student_id
  (
    linked_student_id::bigint IN (
      SELECT id FROM students WHERE auth_user_id = auth.uid()
    )
    OR
    student_id::bigint IN (
      SELECT id FROM students WHERE auth_user_id = auth.uid()
    )
  )
);

-- INSERT: Only for automated Gmail imports (anon) - NO student access
CREATE POLICY "payments_insert_automation_only"
ON payments
FOR INSERT
TO anon, authenticated
WITH CHECK (
  -- Anonymous role (Gmail automation)
  auth.role() = 'anon'
  OR
  -- Admin only
  is_arnoma_admin()
);

-- UPDATE: Admin only
CREATE POLICY "payments_update_admin_only"
ON payments
FOR UPDATE
TO authenticated
USING (is_arnoma_admin())
WITH CHECK (is_arnoma_admin());

-- DELETE: Admin only
CREATE POLICY "payments_delete_admin_only"
ON payments
FOR DELETE
TO authenticated
USING (is_arnoma_admin());

-- -----------------------------------------------------------------------------
-- PAYMENT_RECORDS TABLE (Manual entries)
-- -----------------------------------------------------------------------------

-- SELECT: Students see ONLY their own records, Admins see all
CREATE POLICY "payment_records_select_student_own_or_admin"
ON payment_records
FOR SELECT
TO authenticated
USING (
  -- Admin can see everything
  is_arnoma_admin()
  OR
  -- Students can ONLY see their own records
  student_id::bigint IN (
    SELECT id FROM students WHERE auth_user_id = auth.uid()
  )
);

-- INSERT: Admin only - NO student access
CREATE POLICY "payment_records_insert_admin_only"
ON payment_records
FOR INSERT
TO authenticated
WITH CHECK (is_arnoma_admin());

-- UPDATE: Admin only
CREATE POLICY "payment_records_update_admin_only"
ON payment_records
FOR UPDATE
TO authenticated
USING (is_arnoma_admin())
WITH CHECK (is_arnoma_admin());

-- DELETE: Admin only
CREATE POLICY "payment_records_delete_admin_only"
ON payment_records
FOR DELETE
TO authenticated
USING (is_arnoma_admin());

-- -----------------------------------------------------------------------------
-- CREDIT_PAYMENTS TABLE
-- -----------------------------------------------------------------------------

-- SELECT: Students see ONLY their own credit payments, Admins see all
CREATE POLICY "credit_payments_select_student_own_or_admin"
ON credit_payments
FOR SELECT
TO authenticated
USING (
  -- Admin can see everything
  is_arnoma_admin()
  OR
  -- Students can ONLY see their own credit payments
  student_id::bigint IN (
    SELECT id FROM students WHERE auth_user_id = auth.uid()
  )
);

-- INSERT: Admin only - NO student access
CREATE POLICY "credit_payments_insert_admin_only"
ON credit_payments
FOR INSERT
TO authenticated
WITH CHECK (is_arnoma_admin());

-- UPDATE: Admin only
CREATE POLICY "credit_payments_update_admin_only"
ON credit_payments
FOR UPDATE
TO authenticated
USING (is_arnoma_admin())
WITH CHECK (is_arnoma_admin());

-- DELETE: Admin only
CREATE POLICY "credit_payments_delete_admin_only"
ON credit_payments
FOR DELETE
TO authenticated
USING (is_arnoma_admin());

-- =============================================================================
-- STEP 4: VERIFICATION
-- =============================================================================

-- Check RLS is enabled (should show ENABLED for all)
SELECT 
  tablename,
  CASE WHEN rowsecurity THEN '✅ ENABLED' ELSE '❌ DISABLED' END as "RLS Status"
FROM pg_tables 
WHERE tablename IN ('payments', 'payment_records', 'credit_payments')
ORDER BY tablename;

-- Count policies per table (should be exactly 4 each: SELECT, INSERT, UPDATE, DELETE)
SELECT 
  tablename,
  COUNT(*) as "Policy Count"
FROM pg_policies 
WHERE tablename IN ('payments', 'payment_records', 'credit_payments')
GROUP BY tablename
ORDER BY tablename;

-- List all policies (verify ONLY the ones we just created exist)
SELECT 
  tablename,
  policyname,
  cmd as "Operation",
  roles as "Roles"
FROM pg_policies 
WHERE tablename IN ('payments', 'payment_records', 'credit_payments')
ORDER BY tablename, cmd;

-- =============================================================================
-- EXPECTED OUTPUT:
-- - RLS Status: ✅ ENABLED for all 3 tables
-- - Policy Count: 4 for each table (SELECT, INSERT, UPDATE, DELETE)
-- - Total: 12 policies, NO overly permissive ones
-- =============================================================================

-- =============================================================================
-- AFTER RUNNING THIS:
-- 1. All students should ONLY see their own payments
-- 2. Admins see everything
-- 3. Hard refresh student portal (Cmd+Shift+R)
-- 4. Test with a student account - verify they can't see other students' data
-- =============================================================================
