-- ============================================================================
-- 🔧 COMPLETE RLS FIX - Type Casting + Admin Function + Policies
-- ============================================================================
-- This script will:
-- 1. Create/recreate the is_arnoma_admin() function
-- 2. Drop all existing policies
-- 3. Create new policies with proper type casting
-- 4. Verify everything works

-- =============================================================================
-- STEP 1: Create or Replace the is_arnoma_admin() function
-- =============================================================================

CREATE OR REPLACE FUNCTION is_arnoma_admin()
RETURNS BOOLEAN AS $$
BEGIN
  RETURN EXISTS (
    SELECT 1 
    FROM admin_accounts 
    WHERE auth_user_id = auth.uid()
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Grant execute permission
GRANT EXECUTE ON FUNCTION is_arnoma_admin() TO authenticated, anon;

-- =============================================================================
-- STEP 2: Drop ALL existing policies on payment tables
-- =============================================================================

DO $$ 
DECLARE
    r RECORD;
BEGIN
    -- Drop all policies on payments table
    FOR r IN (
        SELECT policyname 
        FROM pg_policies 
        WHERE schemaname = 'public' 
        AND tablename = 'payments'
    ) LOOP
        EXECUTE 'DROP POLICY IF EXISTS ' || quote_ident(r.policyname) || ' ON payments';
    END LOOP;
    
    -- Drop all policies on payment_records table
    FOR r IN (
        SELECT policyname 
        FROM pg_policies 
        WHERE schemaname = 'public' 
        AND tablename = 'payment_records'
    ) LOOP
        EXECUTE 'DROP POLICY IF EXISTS ' || quote_ident(r.policyname) || ' ON payment_records';
    END LOOP;
    
    -- Drop all policies on credit_payments table
    FOR r IN (
        SELECT policyname 
        FROM pg_policies 
        WHERE schemaname = 'public' 
        AND tablename = 'credit_payments'
    ) LOOP
        EXECUTE 'DROP POLICY IF EXISTS ' || quote_ident(r.policyname) || ' ON credit_payments';
    END LOOP;
END $$;

-- =============================================================================
-- STEP 3: Enable RLS on all payment tables
-- =============================================================================

ALTER TABLE payments ENABLE ROW LEVEL SECURITY;
ALTER TABLE payment_records ENABLE ROW LEVEL SECURITY;
ALTER TABLE credit_payments ENABLE ROW LEVEL SECURITY;

-- =============================================================================
-- STEP 4: Create PAYMENTS table policies with type casting
-- =============================================================================

-- SELECT: Admins see all, students see only their own
CREATE POLICY "payments_select_policy"
ON payments FOR SELECT
USING (
  -- Admin can see everything
  is_arnoma_admin()
  OR
  -- Student can see records where student_id matches their account
  (
    student_id IS NOT NULL 
    AND student_id::bigint IN (
      SELECT id FROM students WHERE auth_user_id = auth.uid()
    )
  )
  OR
  -- Student can see records where linked_student_id matches
  (
    linked_student_id IS NOT NULL 
    AND linked_student_id::bigint IN (
      SELECT id FROM students WHERE auth_user_id = auth.uid()
    )
  )
);

-- INSERT: Admins and automated imports (anon with gmail_id)
CREATE POLICY "payments_insert_policy"
ON payments FOR INSERT
WITH CHECK (
  is_arnoma_admin()
  OR
  (gmail_id IS NOT NULL) -- Allow automated payment imports
);

-- UPDATE: Admins and automated imports
CREATE POLICY "payments_update_policy"
ON payments FOR UPDATE
USING (
  is_arnoma_admin()
  OR
  (gmail_id IS NOT NULL)
);

-- DELETE: Admins only
CREATE POLICY "payments_delete_policy"
ON payments FOR DELETE
USING (is_arnoma_admin());

-- =============================================================================
-- STEP 5: Create PAYMENT_RECORDS table policies with type casting
-- =============================================================================

-- SELECT: Admins see all, students see only their own
CREATE POLICY "payment_records_select_policy"
ON payment_records FOR SELECT
USING (
  is_arnoma_admin()
  OR
  (
    student_id IS NOT NULL 
    AND student_id::bigint IN (
      SELECT id FROM students WHERE auth_user_id = auth.uid()
    )
  )
);

-- INSERT: Admins only
CREATE POLICY "payment_records_insert_policy"
ON payment_records FOR INSERT
WITH CHECK (is_arnoma_admin());

-- UPDATE: Admins only
CREATE POLICY "payment_records_update_policy"
ON payment_records FOR UPDATE
USING (is_arnoma_admin());

-- DELETE: Admins only
CREATE POLICY "payment_records_delete_policy"
ON payment_records FOR DELETE
USING (is_arnoma_admin());

-- =============================================================================
-- STEP 6: Create CREDIT_PAYMENTS table policies with type casting
-- =============================================================================

-- SELECT: Admins see all, students see only their own
CREATE POLICY "credit_payments_select_policy"
ON credit_payments FOR SELECT
USING (
  is_arnoma_admin()
  OR
  (
    student_id IS NOT NULL 
    AND student_id::bigint IN (
      SELECT id FROM students WHERE auth_user_id = auth.uid()
    )
  )
);

-- INSERT: Admins only
CREATE POLICY "credit_payments_insert_policy"
ON credit_payments FOR INSERT
WITH CHECK (is_arnoma_admin());

-- UPDATE: Admins only
CREATE POLICY "credit_payments_update_policy"
ON credit_payments FOR UPDATE
USING (is_arnoma_admin());

-- DELETE: Admins only
CREATE POLICY "credit_payments_delete_policy"
ON credit_payments FOR DELETE
USING (is_arnoma_admin());

-- =============================================================================
-- STEP 7: Verification Queries
-- =============================================================================

-- Check that RLS is enabled
SELECT 
  '=== RLS STATUS ===' as "Check",
  tablename as "Table",
  rowsecurity as "RLS Enabled"
FROM pg_tables 
WHERE schemaname = 'public' 
  AND tablename IN ('payments', 'payment_records', 'credit_payments')
ORDER BY tablename;

-- Count policies per table
SELECT 
  '=== POLICY COUNT ===' as "Check",
  tablename as "Table",
  COUNT(*) as "Total Policies"
FROM pg_policies 
WHERE schemaname = 'public' 
  AND tablename IN ('payments', 'payment_records', 'credit_payments')
GROUP BY tablename
ORDER BY tablename;

-- List all policies
SELECT 
  '=== ALL POLICIES ===' as "Check",
  tablename as "Table",
  policyname as "Policy Name",
  cmd as "Command"
FROM pg_policies 
WHERE schemaname = 'public' 
  AND tablename IN ('payments', 'payment_records', 'credit_payments')
ORDER BY tablename, cmd, policyname;

-- Verify admin function exists
SELECT 
  '=== ADMIN FUNCTION ===' as "Check",
  proname as "Function Name",
  CASE 
    WHEN proname = 'is_arnoma_admin' THEN '✅ EXISTS'
    ELSE 'Unknown'
  END as "Status"
FROM pg_proc
WHERE proname = 'is_arnoma_admin';

-- Final status check
SELECT 
  CASE 
    WHEN (
      -- RLS enabled on all tables
      (SELECT COUNT(*) FROM pg_tables 
       WHERE schemaname = 'public' 
       AND tablename IN ('payments', 'payment_records', 'credit_payments')
       AND rowsecurity = true) = 3
      AND
      -- Exactly 12 policies (4 per table)
      (SELECT COUNT(*) FROM pg_policies 
       WHERE schemaname = 'public' 
       AND tablename IN ('payments', 'payment_records', 'credit_payments')) = 12
      AND
      -- Admin function exists
      EXISTS (SELECT 1 FROM pg_proc WHERE proname = 'is_arnoma_admin')
    )
    THEN '✅✅✅ RLS SETUP COMPLETE

Function: is_arnoma_admin() ✅
RLS Enabled: All 3 tables ✅
Policies: 12 total (4 per table) ✅
Type Casting: student_id::bigint ✅

STUDENTS CAN ONLY SEE:
- Their own payments (student_id match)
- Their own records (auth.uid() match)

ADMINS CAN SEE:
- Everything (is_arnoma_admin() = true)

Ready for production!'
    ELSE '❌ SETUP INCOMPLETE

Check the verification queries above to see what failed.'
  END as "🔧 FINAL RLS SETUP STATUS 🔧";
