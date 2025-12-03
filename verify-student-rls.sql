-- Verify Student RLS Policies
-- Run this in Supabase SQL Editor to check RLS configuration

-- =====================================================
-- 1. CHECK IF RLS IS ENABLED ON students TABLE
-- =====================================================
SELECT 
  schemaname,
  tablename,
  rowsecurity as rls_enabled
FROM pg_tables
WHERE schemaname = 'public' 
  AND tablename = 'students';

-- Expected: rls_enabled = true

-- =====================================================
-- 2. LIST ALL RLS POLICIES ON students TABLE
-- =====================================================
SELECT 
  policyname as policy_name,
  cmd as command,
  qual as using_expression,
  with_check as with_check_expression,
  roles
FROM pg_policies
WHERE schemaname = 'public'
  AND tablename = 'students'
ORDER BY policyname;

-- Expected policies:
-- - Allow students to read their own record
-- - Allow admins to read/update all students
-- - Service role full access

-- =====================================================
-- 3. CHECK student_sessions RLS POLICIES
-- =====================================================
SELECT 
  policyname as policy_name,
  cmd as command,
  qual as using_expression,
  with_check as with_check_expression
FROM pg_policies
WHERE schemaname = 'public'
  AND tablename = 'student_sessions'
ORDER BY policyname;

-- Expected:
-- - Students can view/update their own sessions
-- - Admins can view all sessions
-- - No delete policies (audit trail)

-- =====================================================
-- 4. VERIFY ADMIN ACCESS (admin_accounts TABLE)
-- =====================================================
SELECT 
  auth_user_id,
  email
FROM admin_accounts
ORDER BY email;

-- Check that admin emails are listed here
-- Note: admin_accounts table only has auth_user_id and email columns

-- =====================================================
-- 5. TEST STUDENT ACCESS (Replace with actual auth_user_id)
-- =====================================================
-- Uncomment and replace 'your-auth-user-id' with actual UUID from auth.users
/*
SET LOCAL role TO authenticated;
SET LOCAL request.jwt.claims TO '{"sub": "your-auth-user-id"}';

SELECT id, name, email, group_name
FROM students
WHERE auth_user_id = 'your-auth-user-id';

-- Should return exactly 1 row (the student's own record)
*/

-- =====================================================
-- 6. CHECK FOR STUDENTS WITHOUT AUTH
-- =====================================================
SELECT 
  id,
  name,
  email,
  auth_user_id,
  CASE 
    WHEN auth_user_id IS NULL THEN '❌ No Auth'
    ELSE '✅ Has Auth'
  END as auth_status
FROM students
ORDER BY auth_user_id NULLS FIRST
LIMIT 20;

-- Students with NULL auth_user_id cannot login

-- =====================================================
-- 7. VERIFY RLS ENFORCEMENT
-- =====================================================
-- Check if RLS is actually enforced (should be true for production)
SHOW row_security;

-- Expected: row_security = on

-- =====================================================
-- 8. RECOMMENDED RLS POLICIES
-- =====================================================
/*
If policies are missing, run these:

-- Enable RLS on students table
ALTER TABLE students ENABLE ROW LEVEL SECURITY;

-- Policy 1: Students can read their own record
CREATE POLICY "Students can view their own record"
ON students
FOR SELECT
USING (auth.uid() = auth_user_id);

-- Policy 2: Admins can read all students
CREATE POLICY "Admins can view all students"
ON students
FOR SELECT
USING (
  EXISTS (
    SELECT 1 FROM admin_accounts
    WHERE admin_accounts.email = auth.email()
  )
);

-- Policy 3: Admins can update all students
CREATE POLICY "Admins can update all students"
ON students
FOR UPDATE
USING (
  EXISTS (
    SELECT 1 FROM admin_accounts
    WHERE admin_accounts.email = auth.email()
  )
);

-- Policy 4: Service role has full access
CREATE POLICY "Service role has full access"
ON students
FOR ALL
USING (auth.role() = 'service_role');
*/
