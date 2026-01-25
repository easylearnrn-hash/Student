-- ============================================================================
-- 🔧 FIX RLS TYPE CASTING ERROR - student_id TEXT vs BIGINT
-- ============================================================================
-- ERROR: operator does not exist: text = bigint
-- CAUSE: student_id columns are TEXT but id columns are BIGINT
-- FIX: Add ::bigint type casting to all comparisons

-- =============================================================================
-- STEP 1: Drop ALL existing policies (clean slate)
-- =============================================================================

DROP POLICY IF EXISTS "admin_select_payments" ON payments;
DROP POLICY IF EXISTS "admin_insert_payments" ON payments;
DROP POLICY IF EXISTS "admin_update_payments" ON payments;
DROP POLICY IF EXISTS "admin_delete_payments" ON payments;

DROP POLICY IF EXISTS "student_select_payments" ON payments;
DROP POLICY IF EXISTS "student_insert_payments" ON payments;
DROP POLICY IF EXISTS "student_update_payments" ON payments;
DROP POLICY IF EXISTS "student_delete_payments" ON payments;

DROP POLICY IF EXISTS "admin_select_payment_records" ON payment_records;
DROP POLICY IF EXISTS "admin_insert_payment_records" ON payment_records;
DROP POLICY IF EXISTS "admin_update_payment_records" ON payment_records;
DROP POLICY IF EXISTS "admin_delete_payment_records" ON payment_records;

DROP POLICY IF EXISTS "student_select_payment_records" ON payment_records;
DROP POLICY IF EXISTS "student_insert_payment_records" ON payment_records;
DROP POLICY IF EXISTS "student_update_payment_records" ON payment_records;
DROP POLICY IF EXISTS "student_delete_payment_records" ON payment_records;

DROP POLICY IF EXISTS "admin_select_credit_payments" ON credit_payments;
DROP POLICY IF EXISTS "admin_insert_credit_payments" ON credit_payments;
DROP POLICY IF EXISTS "admin_update_credit_payments" ON credit_payments;
DROP POLICY IF EXISTS "admin_delete_credit_payments" ON credit_payments;

DROP POLICY IF EXISTS "student_select_credit_payments" ON credit_payments;
DROP POLICY IF EXISTS "student_insert_credit_payments" ON credit_payments;
DROP POLICY IF EXISTS "student_update_credit_payments" ON credit_payments;
DROP POLICY IF EXISTS "student_delete_credit_payments" ON credit_payments;

-- Drop any other leftover policies
DROP POLICY IF EXISTS "anon_read_payments" ON payments;
DROP POLICY IF EXISTS "allow_anon_read_payments" ON payments;
DROP POLICY IF EXISTS "anon_insert_payments" ON payments;
DROP POLICY IF EXISTS "anon_update_payments_gmail" ON payments;

-- =============================================================================
-- STEP 2: Recreate policies with PROPER TYPE CASTING
-- =============================================================================

-- ============================================
-- PAYMENTS TABLE POLICIES
-- ============================================

-- SELECT: Admin sees all, students see only their records
CREATE POLICY "admin_select_payments"
ON payments FOR SELECT
TO authenticated
USING (
  is_arnoma_admin()
  OR
  (student_id IS NOT NULL AND student_id::bigint IN (
    SELECT id FROM students WHERE auth_user_id = auth.uid()
  ))
  OR
  (linked_student_id IS NOT NULL AND linked_student_id::bigint IN (
    SELECT id FROM students WHERE auth_user_id = auth.uid()
  ))
);

-- INSERT: Admin can insert, anon can insert (for automated imports)
CREATE POLICY "admin_insert_payments"
ON payments FOR INSERT
TO authenticated, anon
WITH CHECK (
  is_arnoma_admin()
  OR
  gmail_id IS NOT NULL -- Allow automated imports
);

-- UPDATE: Admin can update all, anon can update with gmail_id
CREATE POLICY "admin_update_payments"
ON payments FOR UPDATE
TO authenticated, anon
USING (
  is_arnoma_admin()
  OR
  gmail_id IS NOT NULL
);

-- DELETE: Admin only
CREATE POLICY "admin_delete_payments"
ON payments FOR DELETE
TO authenticated
USING (is_arnoma_admin());

-- ============================================
-- PAYMENT_RECORDS TABLE POLICIES
-- ============================================

-- SELECT: Admin sees all, students see only their records
CREATE POLICY "admin_select_payment_records"
ON payment_records FOR SELECT
TO authenticated
USING (
  is_arnoma_admin()
  OR
  (student_id IS NOT NULL AND student_id::bigint IN (
    SELECT id FROM students WHERE auth_user_id = auth.uid()
  ))
);

-- INSERT: Admin only
CREATE POLICY "admin_insert_payment_records"
ON payment_records FOR INSERT
TO authenticated
WITH CHECK (is_arnoma_admin());

-- UPDATE: Admin only
CREATE POLICY "admin_update_payment_records"
ON payment_records FOR UPDATE
TO authenticated
USING (is_arnoma_admin());

-- DELETE: Admin only
CREATE POLICY "admin_delete_payment_records"
ON payment_records FOR DELETE
TO authenticated
USING (is_arnoma_admin());

-- ============================================
-- CREDIT_PAYMENTS TABLE POLICIES
-- ============================================

-- SELECT: Admin sees all, students see only their records
CREATE POLICY "admin_select_credit_payments"
ON credit_payments FOR SELECT
TO authenticated
USING (
  is_arnoma_admin()
  OR
  (student_id IS NOT NULL AND student_id::bigint IN (
    SELECT id FROM students WHERE auth_user_id = auth.uid()
  ))
);

-- INSERT: Admin only
CREATE POLICY "admin_insert_credit_payments"
ON credit_payments FOR INSERT
TO authenticated
WITH CHECK (is_arnoma_admin());

-- UPDATE: Admin only
CREATE POLICY "admin_update_credit_payments"
ON credit_payments FOR UPDATE
TO authenticated
USING (is_arnoma_admin());

-- DELETE: Admin only
CREATE POLICY "admin_delete_credit_payments"
ON credit_payments FOR DELETE
TO authenticated
USING (is_arnoma_admin());

-- =============================================================================
-- STEP 3: Verify RLS is enabled
-- =============================================================================

ALTER TABLE payments ENABLE ROW LEVEL SECURITY;
ALTER TABLE payment_records ENABLE ROW LEVEL SECURITY;
ALTER TABLE credit_payments ENABLE ROW LEVEL SECURITY;

-- =============================================================================
-- STEP 4: Verify policies were created
-- =============================================================================

SELECT 
  '=== VERIFICATION: Policy Count ===' as "Status",
  tablename as "Table",
  COUNT(*) as "Total Policies"
FROM pg_policies 
WHERE schemaname = 'public' 
  AND tablename IN ('payments', 'payment_records', 'credit_payments')
GROUP BY tablename
ORDER BY tablename;

-- Expected: 4 policies per table (12 total)

SELECT 
  '=== VERIFICATION: Type Casting ===' as "Status",
  tablename as "Table",
  policyname as "Policy",
  CASE 
    WHEN qual::text LIKE '%student_id::bigint%' THEN '✅ Type-safe'
    WHEN qual::text LIKE '%linked_student_id::bigint%' THEN '✅ Type-safe'
    WHEN qual::text NOT LIKE '%student_id%' THEN '✅ No student_id'
    ELSE '⚠️ Missing ::bigint'
  END as "Type Safety"
FROM pg_policies 
WHERE schemaname = 'public' 
  AND tablename IN ('payments', 'payment_records', 'credit_payments')
ORDER BY tablename, policyname;

-- =============================================================================
-- FINAL STATUS
-- =============================================================================

SELECT 
  CASE 
    WHEN (
      SELECT COUNT(*) FROM pg_policies 
      WHERE schemaname = 'public' 
      AND tablename IN ('payments', 'payment_records', 'credit_payments')
    ) = 12
    THEN '✅✅✅ TYPE CASTING FIX COMPLETE

All policies recreated with proper ::bigint casting:
- student_id::bigint (TEXT to BIGINT)
- linked_student_id::bigint (TEXT to BIGINT)

Policy count: 12 (4 per table)
RLS enabled: TRUE on all 3 tables

Students can now query their own payments without errors.
Admin can see everything via is_arnoma_admin().'
    ELSE '❌ Policy creation incomplete - check errors above'
  END as "🔧 TYPE CASTING FIX STATUS 🔧";
