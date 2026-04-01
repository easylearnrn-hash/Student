-- ============================================================
-- FIX: student_note_permissions RLS blocks group-wide rows
-- ============================================================
-- PROBLEM:
--   Group-wide permission rows have student_id = NULL.
--   The existing policy checks:
--     student_id IN (SELECT id FROM students WHERE auth_user_id = auth.uid())
--   NULL IN (...) is never TRUE in SQL → group-wide rows are
--   invisible to real (non-admin) students.
--
-- RESULT: Admin impersonation shows notes (admin bypasses RLS
--   via is_arnoma_admin()), but the real student sees nothing.
--
-- FIX:
--   Rewrite the SELECT policy to ALSO allow rows where
--   student_id IS NULL AND group_name matches the student's group.
-- ============================================================

BEGIN;

-- ============================================================
-- 1. FIX student_note_permissions
-- ============================================================

DROP POLICY IF EXISTS "Students can read own permissions" ON student_note_permissions;

CREATE POLICY "Students can read own permissions"
ON student_note_permissions FOR SELECT
TO authenticated
USING (
  -- Individual rows assigned to this specific student
  student_id IN (
    SELECT id FROM students WHERE auth_user_id = auth.uid()
  )
  OR
  -- Group-wide rows (student_id IS NULL) for this student's group
  (
    student_id IS NULL
    AND group_name IN (
      SELECT group_name FROM students WHERE auth_user_id = auth.uid()
    )
  )
  OR
  -- Admins see everything
  is_arnoma_admin()
);

-- ============================================================
-- 2. FIX note_free_access (same pattern for individual rows)
-- ============================================================
-- The existing policy already handles group_letter correctly,
-- but individual rows (access_type = 'individual', student_id set)
-- need the same auth_user_id match. Re-apply to be safe.

DROP POLICY IF EXISTS "Students can view free access" ON note_free_access;

CREATE POLICY "Students can view free access"
ON note_free_access FOR SELECT
TO public
USING (
  -- Individual access for this specific student
  student_id IN (
    SELECT id FROM students WHERE auth_user_id = auth.uid()
  )
  OR
  -- Group access: row has access_type='group' and group_letter matches
  (
    access_type = 'group'
    AND group_letter IN (
      SELECT REPLACE(REPLACE(group_name, 'Group ', ''), 'group ', '')
      FROM students
      WHERE auth_user_id = auth.uid()
    )
  )
  OR
  is_arnoma_admin()
);

-- ============================================================
-- VERIFICATION QUERIES (run manually to check)
-- ============================================================

-- How many group-wide rows exist in student_note_permissions?
-- SELECT COUNT(*) FROM student_note_permissions WHERE student_id IS NULL;

-- How many group-wide rows exist in note_free_access?
-- SELECT COUNT(*) FROM note_free_access WHERE access_type = 'group';

-- Check policies were created:
SELECT tablename, policyname, roles, cmd
FROM pg_policies
WHERE schemaname = 'public'
  AND tablename IN ('student_note_permissions', 'note_free_access')
ORDER BY tablename, policyname;

COMMIT;

-- ============================================================
-- SUMMARY OF CHANGES
-- ============================================================
-- student_note_permissions SELECT policy:
--   BEFORE: student_id IN (... auth.uid() match) OR is_arnoma_admin()
--   AFTER:  student_id IN (... auth.uid() match)
--           OR (student_id IS NULL AND group_name IN (student's group))
--           OR is_arnoma_admin()
--
-- note_free_access SELECT policy: unchanged in logic, re-applied
-- for consistency. Group access already worked correctly here
-- because group_letter IS NOT NULL in those rows.
-- ============================================================
