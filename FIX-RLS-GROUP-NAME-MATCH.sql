BEGIN;

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
  -- Group-wide rows (student_id IS NULL) for this student's group.
  -- Compare 'Group A' with 'Group ' || 'A'
  (
    student_id IS NULL
    AND REPLACE(group_name, 'Group ', '') IN (
      SELECT REPLACE(group_name, 'Group ', '') FROM students WHERE auth_user_id = auth.uid()
    )
  )
  OR
  -- Admins see everything
  is_arnoma_admin()
);

COMMIT;
