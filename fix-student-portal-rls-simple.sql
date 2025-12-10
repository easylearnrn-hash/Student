-- Simplified RLS for Student Portal
-- This allows ANON users to see everything (for student portal access)
-- Admins still have full control

-- ============================================================================
-- 1. STUDENT_NOTES - Simple policy for student access
-- ============================================================================

-- Drop the complex policy
DROP POLICY IF EXISTS "Students can view accessible notes" ON student_notes;

-- Create SIMPLE policy: Anon can see all non-deleted notes
-- (Access control happens in the app layer via permissions tables)
CREATE POLICY "Anon can view non-deleted notes"
ON student_notes
FOR SELECT
TO anon, authenticated
USING (deleted = false);

-- ============================================================================
-- 2. NOTE_FOLDERS - Already working, but ensure it's correct
-- ============================================================================

-- This should already exist and work
-- DROP POLICY IF EXISTS "Students can view all note folders" ON note_folders;

-- CREATE POLICY "Students can view all note folders"
-- ON note_folders
-- FOR SELECT
-- TO anon, authenticated
-- USING (deleted_at IS NULL);

-- ============================================================================
-- 3. STUDENT_NOTE_PERMISSIONS - Ensure visible to anon
-- ============================================================================

-- Already has policy "Students can view their permissions" allowing true

-- ============================================================================
-- 4. NOTE_FREE_ACCESS - Ensure visible to anon
-- ============================================================================

-- Already has policy "Students can view free access" allowing true

-- ============================================================================
-- 5. STUDENTS - Allow anon to read student records
-- ============================================================================

-- Already has policy "Students can view own record" with "OR true"

-- ============================================================================
-- Verify setup
-- ============================================================================

SELECT 
  tablename,
  policyname,
  roles,
  cmd,
  CASE 
    WHEN qual LIKE '%true%' THEN 'PERMISSIVE (allows access)'
    WHEN qual LIKE '%deleted%' THEN 'Filters deleted records'
    ELSE LEFT(qual, 100)
  END as policy_summary
FROM pg_policies
WHERE tablename IN (
  'note_folders',
  'student_notes',
  'student_note_permissions',
  'note_free_access',
  'students'
)
AND policyname IN (
  'Students can view all note folders',
  'Anon can view non-deleted notes',
  'Allow anon read for student portal',
  'Students can view their permissions',
  'Students can view free access',
  'Students can view own record'
)
ORDER BY tablename, policyname;
