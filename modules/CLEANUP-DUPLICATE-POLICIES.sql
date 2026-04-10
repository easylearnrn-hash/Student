-- ============================================
-- CLEANUP DUPLICATE AND WEAK POLICIES
-- Remove all conflicting policies and keep ONLY the secure ones
-- ============================================

BEGIN;

-- ============================================
-- STUDENTS TABLE - REMOVE ALL DUPLICATES
-- ============================================

-- Drop ALL policies first
DROP POLICY IF EXISTS "Admins have full access to students" ON students;
DROP POLICY IF EXISTS "Allow test suite access to students" ON students;
DROP POLICY IF EXISTS "students_admin_all" ON students;
DROP POLICY IF EXISTS "Auth students can view own data" ON students;
DROP POLICY IF EXISTS "Auth students can update own data" ON students;
DROP POLICY IF EXISTS "Students can view own profile" ON students;
DROP POLICY IF EXISTS "Students can view own record" ON students;

-- Create ONLY 3 clean policies
-- 1. Students can view their own record
CREATE POLICY "Auth students can view own data"
ON students FOR SELECT
TO authenticated
USING (
  auth.uid() = auth_user_id
  AND NOT is_arnoma_admin()
);

-- 2. Students can update their own non-critical fields
CREATE POLICY "Auth students can update own data"
ON students FOR UPDATE
TO authenticated
USING (auth.uid() = auth_user_id AND NOT is_arnoma_admin())
WITH CHECK (auth.uid() = auth_user_id AND NOT is_arnoma_admin());

-- 3. Admins have full access
CREATE POLICY "Admins have full access to students"
ON students FOR ALL
TO authenticated
USING (is_arnoma_admin());

-- ============================================
-- VERIFICATION
-- ============================================

-- Check students table policies (should see exactly 3)
SELECT 
  tablename,
  policyname,
  roles,
  cmd
FROM pg_policies
WHERE schemaname = 'public'
  AND tablename = 'students'
ORDER BY policyname;

-- Verify NO anon access on critical tables
SELECT 
  tablename,
  policyname,
  roles
FROM pg_policies
WHERE schemaname = 'public'
  AND tablename IN ('students', 'payments', 'payment_records', 'sent_emails')
  AND roles::text ILIKE '%anon%'
ORDER BY tablename;

-- This query should return ZERO rows!

COMMIT;

-- ============================================
-- EXPECTED FINAL STATE
-- ============================================

/*
STUDENTS table should have EXACTLY 3 policies:
1. "Admins have full access to students" → {authenticated} → ALL
2. "Auth students can update own data" → {authenticated} → UPDATE
3. "Auth students can view own data" → {authenticated} → SELECT

NO {anon} roles!
NO duplicate admin policies!
NO duplicate student view policies!
*/
