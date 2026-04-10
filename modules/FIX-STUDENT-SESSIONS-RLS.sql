-- ============================================
-- FIX STUDENT_SESSIONS RLS POLICIES
-- Students getting "access control checks" error
-- ============================================

BEGIN;

-- ============================================
-- DROP ALL EXISTING POLICIES
-- ============================================

DROP POLICY IF EXISTS "Admins full access to student_sessions" ON student_sessions;
DROP POLICY IF EXISTS "Students can create own sessions" ON student_sessions;
DROP POLICY IF EXISTS "Students can insert own sessions" ON student_sessions;
DROP POLICY IF EXISTS "Students can update own sessions" ON student_sessions;
DROP POLICY IF EXISTS "Students can view own sessions" ON student_sessions;

-- ============================================
-- CREATE CLEAN POLICIES
-- ============================================

-- STUDENTS: Can view their own sessions (by student_id OR by session id if they own it)
CREATE POLICY "Students can view own sessions"
ON student_sessions FOR SELECT
TO authenticated
USING (
  student_id IN (
    SELECT id FROM students WHERE auth_user_id = auth.uid()
  )
  AND NOT is_arnoma_admin()
);

-- STUDENTS: Can create their own sessions
CREATE POLICY "Students can create own sessions"
ON student_sessions FOR INSERT
TO authenticated
WITH CHECK (
  student_id IN (
    SELECT id FROM students WHERE auth_user_id = auth.uid()
  )
  AND NOT is_arnoma_admin()
);

-- STUDENTS: Can update their own sessions
CREATE POLICY "Students can update own sessions"
ON student_sessions FOR UPDATE
TO authenticated
USING (
  student_id IN (
    SELECT id FROM students WHERE auth_user_id = auth.uid()
  )
  AND NOT is_arnoma_admin()
)
WITH CHECK (
  student_id IN (
    SELECT id FROM students WHERE auth_user_id = auth.uid()
  )
  AND NOT is_arnoma_admin()
);

-- ADMINS: Full access to all sessions
CREATE POLICY "Admins full access to student_sessions"
ON student_sessions FOR ALL
TO authenticated
USING (is_arnoma_admin())
WITH CHECK (is_arnoma_admin());

-- ============================================
-- VERIFICATION
-- ============================================

-- Check the new policies
SELECT 
  policyname,
  roles,
  cmd
FROM pg_policies
WHERE schemaname = 'public'
  AND tablename = 'student_sessions'
ORDER BY policyname;

COMMIT;

-- ============================================
-- EXPECTED RESULTS
-- ============================================

/*
After running this:

STUDENTS should be able to:
✅ SELECT their own sessions (by student_id → auth_user_id match)
✅ INSERT new sessions for themselves
✅ UPDATE their own sessions

ADMINS should be able to:
✅ Full access to all sessions

POLICIES should be:
1. "Admins full access to student_sessions" → {authenticated} → ALL
2. "Students can create own sessions" → {authenticated} → INSERT
3. "Students can update own sessions" → {authenticated} → UPDATE
4. "Students can view own sessions" → {authenticated} → SELECT

KEY FIX:
- Removed broken admin policy with email check + is_active condition
- Changed to use auth.uid() for student matching (more secure)
- Added is_arnoma_admin() checks to prevent conflicts
*/
