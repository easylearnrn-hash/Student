-- ============================================
-- FIX STUDENT NOTES RLS - USE PERMISSION TABLES
-- The group_name field in student_notes is the SYSTEM NAME (like "Cardiovascular")
-- NOT the student group letter (A, B, C, etc.)
-- Must use note_free_access and student_note_permissions instead!
-- ============================================

BEGIN;

-- Drop the broken policies
DROP POLICY IF EXISTS "Students can view their group notes" ON student_notes;
DROP POLICY IF EXISTS "Admins have full access to notes" ON student_notes;

-- ============================================
-- NEW POLICY: Use Permission Tables
-- ============================================

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
        -- Individual access for this student
        (nfa.access_type = 'individual' AND nfa.student_id = s.id)
        OR
        -- Group access for this student's group letter
        (nfa.access_type = 'group' AND nfa.group_letter = REPLACE(REPLACE(s.group_name, 'Group ', ''), 'group ', ''))
      )
    )
    OR
    -- Check 2: Note is in student_note_permissions for this student
    id IN (
      SELECT snp.note_id
      FROM student_note_permissions snp
      LEFT JOIN students s ON s.auth_user_id = auth.uid()
      WHERE snp.is_accessible = true
        AND (
          snp.student_id = s.id
          OR
          (snp.group_name = s.group_name AND snp.student_id IS NULL)
        )
    )
  )
);

-- ADMINS: Full access to all notes
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

-- Test: What notes can a Group A student see?
-- This should return notes from note_free_access + student_note_permissions
SELECT 
  COUNT(*) as notes_accessible_to_group_a_students
FROM student_notes sn
WHERE sn.deleted = false
  AND (
    -- Notes with free access for Group A
    sn.id IN (
      SELECT note_id FROM note_free_access
      WHERE access_type = 'group' AND group_letter = 'A'
    )
    OR
    -- Notes with permissions for Group A
    sn.id IN (
      SELECT note_id FROM student_note_permissions
      WHERE group_name LIKE '%A%' AND is_accessible = true
    )
  );

COMMIT;

-- ============================================
-- EXPECTED RESULTS
-- ============================================

/*
After running this:

1. Students in Group A should see:
   - 71 notes from note_free_access (group access)
   - Any additional notes from student_note_permissions

2. Students in Group C should see:
   - 217 notes from note_free_access (group access)
   - Any additional notes from student_note_permissions

3. The policy now correctly uses:
   - note_free_access table (for group-wide free notes)
   - student_note_permissions table (for individual/paid access)

4. group_name in student_notes remains as SYSTEM NAME (e.g., "Cardiovascular")
   - This is correct! It's not meant to match student group letters

KEY INSIGHT:
The notes are organized by MEDICAL SYSTEM (Cardio, GI, Mental Health, etc.)
The access is controlled by STUDENT GROUP (A, B, C, D, E, F)
Two different concepts - must use permission tables to bridge them!
*/
