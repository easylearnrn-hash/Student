-- ============================================================
-- VERIFY NOTE_FREE_ACCESS RLS POLICY
-- Check if the policy correctly uses students.group_name
-- ============================================================

-- 1. Check current RLS policies on note_free_access table
SELECT 
  schemaname,
  tablename,
  policyname,
  permissive,
  roles,
  cmd,
  qual,
  with_check
FROM pg_policies 
WHERE tablename = 'note_free_access'
ORDER BY policyname;

-- 2. Check if students table has group_name column (should exist)
SELECT column_name, data_type, is_nullable
FROM information_schema.columns
WHERE table_name = 'students' 
  AND column_name IN ('group_name', 'group_letter')
ORDER BY column_name;

-- 3. Check if note_free_access table has group_letter column (should exist)
SELECT column_name, data_type, is_nullable
FROM information_schema.columns
WHERE table_name = 'note_free_access' 
  AND column_name IN ('group_name', 'group_letter')
ORDER BY column_name;

-- 4. Sample data check - verify students have group_name values
SELECT 
  id,
  name,
  group_name,
  show_in_grid,
  email
FROM students
WHERE group_name IS NOT NULL
LIMIT 5;

-- 5. Sample data check - verify note_free_access has group_letter values
SELECT 
  id,
  note_id,
  access_type,
  group_letter,
  student_id,
  created_at
FROM note_free_access
WHERE access_type = 'group'
LIMIT 5;

-- 6. TEST QUERY: Simulate the RLS policy logic
-- This should match students in Group C with free access notes for Group C
SELECT 
  s.id as student_id,
  s.name as student_name,
  s.group_name as student_group,
  nfa.id as free_access_id,
  nfa.note_id,
  nfa.group_letter as free_access_group,
  nfa.access_type
FROM students s
LEFT JOIN note_free_access nfa ON (
  -- Group access match
  nfa.access_type = 'group' 
  AND nfa.group_letter = s.group_name
)
WHERE s.group_name = 'C'
  AND s.show_in_grid = true
LIMIT 10;

-- 7. Check for any mismatches (students with group_name that don't match any note_free_access.group_letter)
SELECT DISTINCT
  s.group_name as student_group,
  COUNT(DISTINCT s.id) as student_count,
  COUNT(DISTINCT nfa.id) as free_access_count
FROM students s
LEFT JOIN note_free_access nfa ON (
  nfa.access_type = 'group' 
  AND nfa.group_letter = s.group_name
)
WHERE s.show_in_grid = true
  AND s.group_name IS NOT NULL
GROUP BY s.group_name
ORDER BY s.group_name;

-- ============================================================
-- EXPECTED RESULTS:
-- ============================================================
-- Query 1: Should show policies including one that checks group access
-- Query 2: Should show ONLY 'group_name' column (group_letter should NOT exist)
-- Query 3: Should show ONLY 'group_letter' column (group_name should NOT exist)
-- Query 4: Should show students with group_name = 'A', 'B', 'C', 'D', 'E', etc.
-- Query 5: Should show free access records with group_letter = 'A', 'B', 'C', etc.
-- Query 6: Should show matches between students.group_name and note_free_access.group_letter
-- Query 7: Should show each group with student count and free access count
-- ============================================================

-- ============================================================
-- IF THE RLS POLICY IS WRONG (using students.group_letter):
-- You'll need to DROP and RECREATE the policy:
-- ============================================================
/*
-- First, drop the incorrect policy
DROP POLICY IF EXISTS "Allow anon read for impersonation" ON note_free_access;

-- Then create the correct policy
CREATE POLICY "Allow anon read for impersonation"
ON note_free_access
FOR SELECT
TO anon
USING (
  -- Check if student has free access via group
  (
    access_type = 'group'
    AND group_letter = (
      SELECT group_name FROM students  -- CORRECT: use group_name
      WHERE auth_user_id = auth.uid()
    )
  )
  OR
  -- Check if student has individual free access
  (
    access_type = 'individual'
    AND student_id IN (
      SELECT id FROM students
      WHERE auth_user_id = auth.uid()
    )
  )
);
*/
