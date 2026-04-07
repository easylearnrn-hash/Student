-- ============================================
-- FIX STUDENT NOTES RLS - OVERRRIDE EMERGENCY LOCKDOWN
-- The group_name field in student_notes stores the SYSTEM NAME ("Maternal Health")
-- NOT the student group letter ("Group E").
-- The EMERGENCY-RLS-LOCKDOWN accidentally requires them to match literally.
-- We must point access control towards the permission tables instead.
-- ============================================

BEGIN;

DROP POLICY IF EXISTS "Auth students can view own notes" ON student_notes;
DROP POLICY IF EXISTS "Admins have full access to notes" ON student_notes;
DROP POLICY IF EXISTS "Students can view accessible notes" ON student_notes;
DROP POLICY IF EXISTS "allow_anon_read_non_deleted" ON student_notes;
DROP POLICY IF EXISTS "Admin full access to notes" ON student_notes;

-- STUDENTS: Can view notes they have permission for (via note_free_access OR student_note_permissions)
CREATE POLICY "Students can view accessible notes"
ON student_notes FOR SELECT
TO public
USING (
  deleted = false
  AND (
    -- Check 1: Note is in note_free_access for this student's group OR individually
    id IN (
      SELECT nfa.note_id
      FROM note_free_access nfa
      LEFT JOIN students s ON s.auth_user_id = auth.uid()
      WHERE (
        (nfa.access_type = 'individual' AND nfa.student_id = s.id)
        OR
        (nfa.access_type = 'group' AND nfa.group_letter = REPLACE(REPLACE(s.group_name, 'Group ', ''), 'group ', ''))
      )
    )
    OR
    -- Check 2: Note is in student_note_permissions for this student or this student's group
    id IN (
      SELECT snp.note_id
      FROM student_note_permissions snp
      LEFT JOIN students s ON s.auth_user_id = auth.uid()
      WHERE snp.is_accessible = true
        AND (
          snp.student_id = s.id
          OR
          (snp.student_id IS NULL AND (
             snp.group_name = s.group_name 
             OR snp.group_name = REPLACE(s.group_name, 'Group ', '') 
             OR snp.group_name = 'Group ' || REPLACE(s.group_name, 'Group ', '')
          ))
        )
    )
    OR 
    is_arnoma_admin()
  )
);

-- ADMINS: Full access to all notes
CREATE POLICY "Admins have full access to notes"
ON student_notes FOR ALL
TO authenticated
USING (is_arnoma_admin())
WITH CHECK (is_arnoma_admin());

COMMIT;
