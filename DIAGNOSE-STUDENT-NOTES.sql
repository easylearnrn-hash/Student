-- ============================================
-- DIAGNOSE STUDENT NOTES ACCESS ISSUE
-- Check if student_note_permissions table has data
-- ============================================

-- Test 1: Check if student_note_permissions table exists and has data
SELECT 
  COUNT(*) as total_permissions,
  COUNT(DISTINCT note_id) as unique_notes,
  COUNT(DISTINCT student_id) as unique_students,
  COUNT(DISTINCT group_name) as unique_groups
FROM student_note_permissions
WHERE is_accessible = true;

-- Test 2: Check note_free_access table
SELECT 
  COUNT(*) as total_free_access,
  COUNT(DISTINCT note_id) as unique_notes,
  access_type,
  group_letter
FROM note_free_access
GROUP BY access_type, group_letter
ORDER BY access_type, group_letter;

-- Test 3: Check if students can directly query student_notes with their group
-- Replace 'A' with actual student group
SELECT 
  COUNT(*) as accessible_notes_for_group_A
FROM student_notes
WHERE deleted = false
  AND group_name = 'A';  -- Change this to test different groups

-- Test 4: Check what groups exist in student_notes
SELECT 
  group_name,
  COUNT(*) as note_count,
  COUNT(CASE WHEN deleted = false THEN 1 END) as active_notes
FROM student_notes
GROUP BY group_name
ORDER BY group_name;

-- Test 5: Sample of students and their groups
SELECT 
  id,
  name,
  group_name,
  email
FROM students
WHERE id IN (SELECT DISTINCT student_id FROM student_note_permissions WHERE student_id IS NOT NULL)
LIMIT 5;

-- ============================================
-- DIAGNOSTIC RESULTS INTERPRETATION
-- ============================================

/*
PROBLEM SCENARIOS:

1. If student_note_permissions is EMPTY:
   → Students have NO permission records
   → Portal tries to fetch notes with empty ID list
   → Result: NO NOTES SHOWN
   
   FIX: Either populate student_note_permissions OR change portal to query student_notes directly

2. If note_free_access has data BUT student_note_permissions doesn't:
   → Free access system works
   → Permission system broken
   
   FIX: Portal should use note_free_access OR query student_notes directly by group

3. If student_notes.group_name doesn't match students.group_name:
   → RLS policy works but group mismatch
   → Result: NO NOTES SHOWN
   
   FIX: Normalize group names in both tables

RECOMMENDED SOLUTION:
Change student-portal.html to query student_notes DIRECTLY by group_name,
instead of going through student_note_permissions table.
*/
