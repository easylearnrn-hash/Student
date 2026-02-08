-- ============================================
-- FIX STUDENT NOTES ACCESS - CRITICAL
-- Students can't access their notes - fix RLS policies
-- ============================================

BEGIN;

-- ============================================
-- DROP ALL CONFLICTING POLICIES
-- ============================================

DROP POLICY IF EXISTS "Auth students can view own notes" ON student_notes;
DROP POLICY IF EXISTS "Students view their group notes" ON student_notes;
DROP POLICY IF EXISTS "Admins have full access to notes" ON student_notes;
DROP POLICY IF EXISTS "admin_full_access" ON student_notes;
DROP POLICY IF EXISTS "Admin full access to notes" ON student_notes;

-- ============================================
-- CREATE CLEAN POLICIES
-- ============================================

-- 1. STUDENTS: Can view non-deleted notes for their group
-- This policy works for BOTH authenticated and public (for impersonation)
CREATE POLICY "Students can view their group notes"
ON student_notes FOR SELECT
TO public
USING (
  deleted = false
  AND (
    -- Authenticated students: match by auth_user_id
    group_name IN (
      SELECT group_name 
      FROM students 
      WHERE auth_user_id = auth.uid()
    )
    OR
    -- Public access: match by email from JWT (for impersonation mode)
    group_name IN (
      SELECT group_name 
      FROM students 
      WHERE email = (auth.jwt() ->> 'email')
    )
  )
);

-- 2. ADMINS: Full access to all notes
CREATE POLICY "Admins have full access to notes"
ON student_notes FOR ALL
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
  AND tablename = 'student_notes'
ORDER BY policyname;

-- Test query: Show what a student in Group A would see
-- Replace 'A' with actual group letter to test
SELECT 
  id,
  title,
  group_name,
  deleted,
  requires_payment,
  created_at
FROM student_notes
WHERE group_name = 'A'  -- Change this to test different groups
  AND deleted = false
ORDER BY created_at DESC
LIMIT 5;

COMMIT;

-- ============================================
-- EXPECTED RESULTS
-- ============================================

/*
After running this:

1. Students should see ONLY:
   - Notes for their group (matching students.group_name)
   - Non-deleted notes (deleted = false)
   - Works in both authenticated AND public/impersonation mode

2. Admins should see:
   - ALL notes (regardless of group or deleted status)

3. Policy count should be exactly 2:
   - "Students can view their group notes" → {public} → SELECT
   - "Admins have full access to notes" → {authenticated} → ALL

CRITICAL: The {public} role allows BOTH authenticated and anonymous users,
which is required for impersonation mode where admin views as student.
*/
