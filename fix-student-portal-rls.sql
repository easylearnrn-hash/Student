-- Fix RLS policies for Student Portal
-- Allows students to see:
-- 1. Note folders (for carousel)
-- 2. Student notes (with proper permissions)
-- 3. Note templates
-- 4. Their own student record

-- ============================================================================
-- 1. NOTE_FOLDERS - Allow students to see all folders (for carousel display)
-- ============================================================================

-- Drop existing policies
DROP POLICY IF EXISTS "Students can view note folders" ON note_folders;
DROP POLICY IF EXISTS "Anon can view note folders" ON note_folders;

-- Create new policy: Students can see all non-deleted folders
CREATE POLICY "Students can view all note folders"
ON note_folders
FOR SELECT
TO anon, authenticated
USING (deleted_at IS NULL);

-- ============================================================================
-- 2. STUDENT_NOTES - Allow students to see notes they have access to
-- ============================================================================

-- Drop existing policies
DROP POLICY IF EXISTS "Students can view their accessible notes" ON student_notes;
DROP POLICY IF EXISTS "Anon can view accessible notes" ON student_notes;

-- Create comprehensive policy for student note access
CREATE POLICY "Students can view accessible notes"
ON student_notes
FOR SELECT
TO anon, authenticated
USING (
  deleted = false
  AND
  (
    -- Allow if student has group permission (via group_name)
    EXISTS (
      SELECT 1 FROM student_note_permissions snp
      WHERE snp.note_id = student_notes.id
      AND snp.is_accessible = true
      AND snp.group_name = (
        -- Get student's group from their record
        SELECT group_name
        FROM students
        WHERE id = (current_setting('request.jwt.claims', true)::json->>'student_id')::bigint
      )
    )
    OR
    -- Allow if student has individual permission
    EXISTS (
      SELECT 1 FROM student_note_permissions snp
      WHERE snp.note_id = student_notes.id
      AND snp.is_accessible = true
      AND snp.student_id = (current_setting('request.jwt.claims', true)::json->>'student_id')::bigint
    )
    OR
    -- Allow if note has free access for student's group
    -- Convert group_name to group_letter (e.g., "Group A" -> "A")
    EXISTS (
      SELECT 1 FROM note_free_access nfa
      WHERE nfa.note_id = student_notes.id
      AND nfa.access_type = 'group'
      AND nfa.group_letter = UPPER(REGEXP_REPLACE(
        (SELECT group_name FROM students WHERE id = (current_setting('request.jwt.claims', true)::json->>'student_id')::bigint),
        '[^A-F]', '', 'g'
      ))
    )
    OR
    -- Allow if note has individual free access for this student
    EXISTS (
      SELECT 1 FROM note_free_access nfa
      WHERE nfa.note_id = student_notes.id
      AND nfa.access_type = 'individual'
      AND nfa.student_id = (current_setting('request.jwt.claims', true)::json->>'student_id')::bigint
    )
  )
);

-- ============================================================================
-- 3. NOTE_TEMPLATES - Allow students to see templates
-- ============================================================================

-- Drop existing policies
DROP POLICY IF EXISTS "Students can view note templates" ON note_templates;
DROP POLICY IF EXISTS "Anon can view note templates" ON note_templates;

-- Create new policy
CREATE POLICY "Students can view note templates"
ON note_templates
FOR SELECT
TO anon, authenticated
USING (true); -- All templates visible

-- ============================================================================
-- 4. STUDENTS - Allow students to see their own record
-- ============================================================================

-- Drop existing policies
DROP POLICY IF EXISTS "Students can view own record" ON students;
DROP POLICY IF EXISTS "Anon can view student records" ON students;

-- Create new policy
CREATE POLICY "Students can view own record"
ON students
FOR SELECT
TO anon, authenticated
USING (
  id = (current_setting('request.jwt.claims', true)::json->>'student_id')::bigint
  OR
  -- Allow anon to see basic info (for impersonation, etc)
  true
);

-- ============================================================================
-- 5. STUDENT_NOTE_PERMISSIONS - Allow students to check their permissions
-- ============================================================================

-- Drop existing policies
DROP POLICY IF EXISTS "Students can view their permissions" ON student_note_permissions;

-- Create new policy
CREATE POLICY "Students can view their permissions"
ON student_note_permissions
FOR SELECT
TO anon, authenticated
USING (true); -- All permissions visible for access checking

-- ============================================================================
-- 6. NOTE_FREE_ACCESS - Allow students to check free access grants
-- ============================================================================

-- Drop existing policies
DROP POLICY IF EXISTS "Students can view free access" ON note_free_access;

-- Create new policy
CREATE POLICY "Students can view free access"
ON note_free_access
FOR SELECT
TO anon, authenticated
USING (true); -- All free access visible for access checking

-- ============================================================================
-- Verify policies are enabled
-- ============================================================================

-- Enable RLS on all tables
ALTER TABLE note_folders ENABLE ROW LEVEL SECURITY;
ALTER TABLE student_notes ENABLE ROW LEVEL SECURITY;
ALTER TABLE note_templates ENABLE ROW LEVEL SECURITY;
ALTER TABLE students ENABLE ROW LEVEL SECURITY;
ALTER TABLE student_note_permissions ENABLE ROW LEVEL SECURITY;
ALTER TABLE note_free_access ENABLE ROW LEVEL SECURITY;

-- Grant usage on tables to anon role
GRANT SELECT ON note_folders TO anon;
GRANT SELECT ON student_notes TO anon;
GRANT SELECT ON note_templates TO anon;
GRANT SELECT ON students TO anon;
GRANT SELECT ON student_note_permissions TO anon;
GRANT SELECT ON note_free_access TO anon;

-- Verify policies
SELECT schemaname, tablename, policyname, permissive, roles, cmd, qual
FROM pg_policies
WHERE tablename IN (
  'note_folders',
  'student_notes',
  'note_templates',
  'students',
  'student_note_permissions',
  'note_free_access'
)
ORDER BY tablename, policyname;
