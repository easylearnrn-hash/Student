-- ========================================
-- EMERGENCY FIX: Restore Student Portal Access
-- ========================================

-- We accidentally removed policies that students need to view their own data!
-- This broke the student portal.

-- ============================================================
-- RESTORE STUDENT ACCESS POLICIES
-- ============================================================

-- Students need to view their own profile
CREATE POLICY "Students can view own profile"
ON students
FOR SELECT
TO authenticated
USING (auth_user_id = auth.uid());

-- Students need to view their own record (for portal)
CREATE POLICY "Students can view own record"
ON students
FOR SELECT
TO anon, authenticated
USING (
  (id = (((current_setting('request.jwt.claims'::text, true))::json ->> 'student_id'::text))::bigint) 
  OR true
);

-- ============================================================
-- VERIFY ALL POLICIES ON STUDENTS TABLE
-- ============================================================
SELECT 
  policyname,
  cmd,
  roles,
  qual::text
FROM pg_policies
WHERE tablename = 'students'
ORDER BY cmd, policyname;

-- Expected result:
-- students_admin_all (ALL) - for admin access
-- Students can view own profile (SELECT) - for authenticated students
-- Students can view own record (SELECT) - for student portal
