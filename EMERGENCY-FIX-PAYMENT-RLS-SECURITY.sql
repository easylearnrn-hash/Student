-- ============================================================================
-- 🚨 EMERGENCY FIX: STUDENTS CAN SEE ALL PAYMENTS - CRITICAL SECURITY BREACH
-- ============================================================================
-- Run this SQL in Supabase SQL Editor IMMEDIATELY
-- This fixes the RLS policies to ensure students ONLY see their own payments

-- Step 1: Check current RLS status
SELECT 
  schemaname, 
  tablename, 
  rowsecurity as "RLS Enabled"
FROM pg_tables 
WHERE tablename IN ('payments', 'payment_records', 'credit_payments');

-- Step 2: Check existing policies
SELECT 
  schemaname,
  tablename,
  policyname,
  permissive,
  roles,
  cmd,
  qual
FROM pg_policies 
WHERE tablename IN ('payments', 'payment_records', 'credit_payments')
ORDER BY tablename, policyname;

-- Step 3: DROP ALL EXISTING POLICIES (clean slate)
DROP POLICY IF EXISTS "payments_select_admin_or_owner" ON payments;
DROP POLICY IF EXISTS "payments_select_own" ON payments;
DROP POLICY IF EXISTS "payments_insert_anon" ON payments;
DROP POLICY IF EXISTS "payments_update_gmail_id" ON payments;
DROP POLICY IF EXISTS "Enable read access for all users" ON payments;
DROP POLICY IF EXISTS "Allow public read access" ON payments;
DROP POLICY IF EXISTS "Allow anonymous inserts" ON payments;

DROP POLICY IF EXISTS "payment_records_select_admin_or_owner" ON payment_records;
DROP POLICY IF EXISTS "payment_records_select_own" ON payment_records;
DROP POLICY IF EXISTS "Enable read access for all users" ON payment_records;

DROP POLICY IF EXISTS "credit_payments_select_admin_or_owner" ON credit_payments;
DROP POLICY IF EXISTS "credit_payments_select_own" ON credit_payments;

-- Step 4: ENABLE RLS (force it on)
ALTER TABLE payments ENABLE ROW LEVEL SECURITY;
ALTER TABLE payment_records ENABLE ROW LEVEL SECURITY;
ALTER TABLE credit_payments ENABLE ROW LEVEL SECURITY;

-- Step 5: CREATE SECURE POLICIES

-- =============================================================================
-- PAYMENTS TABLE (Zelle/Venmo imports)
-- =============================================================================

-- SELECT: Admin OR student can ONLY see payments linked to their student_id
CREATE POLICY "payments_select_secure"
ON payments
FOR SELECT
TO authenticated
USING (
  -- Admin can see all
  is_arnoma_admin()
  OR
  -- Student can ONLY see payments where linked_student_id matches their student record
  linked_student_id::bigint IN (
    SELECT id FROM students WHERE auth_user_id = auth.uid()
  )
  OR
  -- Student can ONLY see payments where student_id matches their student record
  student_id::bigint IN (
    SELECT id FROM students WHERE auth_user_id = auth.uid()
  )
);

-- INSERT: Only anon (for automated Gmail imports) and admins
CREATE POLICY "payments_insert_anon_or_admin"
ON payments
FOR INSERT
TO anon, authenticated
WITH CHECK (
  -- Anon can insert (for Gmail automation)
  auth.role() = 'anon'
  OR
  -- Admin can insert
  is_arnoma_admin()
);

-- UPDATE: Only admins OR update gmail_id field (for automation)
CREATE POLICY "payments_update_admin_or_gmail"
ON payments
FOR UPDATE
TO authenticated
USING (is_arnoma_admin())
WITH CHECK (is_arnoma_admin());

-- DELETE: Admin only
CREATE POLICY "payments_delete_admin"
ON payments
FOR DELETE
TO authenticated
USING (is_arnoma_admin());

-- =============================================================================
-- PAYMENT_RECORDS TABLE (Manual entries)
-- =============================================================================

-- SELECT: Admin OR student can ONLY see their own records
CREATE POLICY "payment_records_select_secure"
ON payment_records
FOR SELECT
TO authenticated
USING (
  -- Admin can see all
  is_arnoma_admin()
  OR
  -- Student can ONLY see records where student_id matches their student record
  student_id::bigint IN (
    SELECT id FROM students WHERE auth_user_id = auth.uid()
  )
);

-- INSERT/UPDATE/DELETE: Admin only
CREATE POLICY "payment_records_insert_admin"
ON payment_records
FOR INSERT
TO authenticated
WITH CHECK (is_arnoma_admin());

CREATE POLICY "payment_records_update_admin"
ON payment_records
FOR UPDATE
TO authenticated
USING (is_arnoma_admin())
WITH CHECK (is_arnoma_admin());

CREATE POLICY "payment_records_delete_admin"
ON payment_records
FOR DELETE
TO authenticated
USING (is_arnoma_admin());

-- =============================================================================
-- CREDIT_PAYMENTS TABLE (Credit-based payments)
-- =============================================================================

-- SELECT: Admin OR student can ONLY see their own credit payments
CREATE POLICY "credit_payments_select_secure"
ON credit_payments
FOR SELECT
TO authenticated
USING (
  -- Admin can see all
  is_arnoma_admin()
  OR
  -- Student can ONLY see credit payments where student_id matches
  student_id::bigint IN (
    SELECT id FROM students WHERE auth_user_id = auth.uid()
  )
);

-- INSERT/UPDATE/DELETE: Admin only
CREATE POLICY "credit_payments_insert_admin"
ON credit_payments
FOR INSERT
TO authenticated
WITH CHECK (is_arnoma_admin());

CREATE POLICY "credit_payments_update_admin"
ON credit_payments
FOR UPDATE
TO authenticated
USING (is_arnoma_admin())
WITH CHECK (is_arnoma_admin());

CREATE POLICY "credit_payments_delete_admin"
ON credit_payments
FOR DELETE
TO authenticated
USING (is_arnoma_admin());

-- =============================================================================
-- VERIFICATION QUERIES
-- =============================================================================

-- Test 1: Verify RLS is enabled
SELECT 
  tablename, 
  CASE WHEN rowsecurity THEN '✅ ENABLED' ELSE '❌ DISABLED' END as "RLS Status"
FROM pg_tables 
WHERE tablename IN ('payments', 'payment_records', 'credit_payments');

-- Test 2: Verify policies exist
SELECT 
  tablename,
  COUNT(*) as "Policy Count",
  string_agg(policyname, ', ') as "Policies"
FROM pg_policies 
WHERE tablename IN ('payments', 'payment_records', 'credit_payments')
GROUP BY tablename;

-- Test 3: Check for any overly permissive policies
SELECT 
  tablename,
  policyname,
  cmd,
  CASE 
    WHEN qual::text LIKE '%true%' THEN '⚠️ OVERLY PERMISSIVE'
    WHEN qual::text LIKE '%is_arnoma_admin()%' THEN '✅ Admin protected'
    WHEN qual::text LIKE '%auth.uid()%' THEN '✅ User protected'
    ELSE '❓ Check manually'
  END as "Security Level"
FROM pg_policies 
WHERE tablename IN ('payments', 'payment_records', 'credit_payments')
ORDER BY tablename, cmd;

-- =============================================================================
-- AFTER RUNNING THIS:
-- 1. Hard refresh student portal (Cmd+Shift+R)
-- 2. Login as a student
-- 3. Check browser console - should only see their own payments
-- 4. Verify no other student data appears
-- =============================================================================
