-- ================================================================
-- FIX NOTE POST DATES: Restore Historical Post Dates Per Group
-- ================================================================
-- Problem: All note_free_access.created_at timestamps show recent dates
--          because they were created during bulk posting operations
-- Solution: Update created_at to match the ACTUAL date each note was 
--          posted to each specific group
-- ================================================================

-- STEP 1: View current state (all notes posted "today")
SELECT 
    nfa.note_id,
    sn.title,
    nfa.group_letter,
    nfa.created_at::date as current_date,
    sn.class_date::date as note_class_date
FROM note_free_access nfa
JOIN student_notes sn ON sn.id = nfa.note_id
WHERE nfa.access_type = 'group'
  AND nfa.created_at::date >= '2024-12-09'
ORDER BY nfa.note_id, nfa.group_letter;

-- ================================================================
-- STEP 2: Fix the dates based on historical post patterns
-- ================================================================

-- Update Group A notes (posted December 9, 2024 at 11:04 AM)
UPDATE note_free_access
SET created_at = '2024-12-09 11:04:00+00'::timestamptz
WHERE access_type = 'group'
  AND group_letter = 'A'
  AND note_id IN (
    SELECT id FROM student_notes 
    WHERE created_at::date >= '2024-12-09'
    AND created_at::date <= '2024-12-09'
  );

-- Update Group C notes (posted December 9, 2024 at 3:46 PM)
UPDATE note_free_access
SET created_at = '2024-12-09 15:46:00+00'::timestamptz
WHERE access_type = 'group'
  AND group_letter = 'C'
  AND note_id IN (
    SELECT id FROM student_notes 
    WHERE created_at::date >= '2024-12-09'
    AND created_at::date <= '2024-12-09'
  );

-- Update Group D notes (posted December 14, 2024 at 7:29 PM)
UPDATE note_free_access
SET created_at = '2024-12-14 19:29:00+00'::timestamptz
WHERE access_type = 'group'
  AND group_letter = 'D'
  AND note_id IN (
    SELECT id FROM student_notes 
    WHERE created_at::date >= '2024-12-09'
    AND created_at::date <= '2024-12-14'
  );

-- Update Group E notes (posted December 22, 2024 at 12:39 AM)
UPDATE note_free_access
SET created_at = '2024-12-22 00:39:00+00'::timestamptz
WHERE access_type = 'group'
  AND group_letter = 'E'
  AND note_id IN (
    SELECT id FROM student_notes 
    WHERE created_at::date >= '2024-12-09'
    AND created_at::date <= '2024-12-22'
  );

-- ================================================================
-- STEP 3: Verify the fix
-- ================================================================
SELECT 
    nfa.note_id,
    sn.title,
    nfa.group_letter,
    nfa.created_at::date as post_date_for_group,
    sn.class_date::date as global_class_date
FROM note_free_access nfa
JOIN student_notes sn ON sn.id = nfa.note_id
WHERE nfa.access_type = 'group'
  AND nfa.note_id BETWEEN 312 AND 324
ORDER BY nfa.note_id, nfa.group_letter;

-- Expected Result:
-- Note 312 "🍭Diabetes Mellitus":
--   Group A: 2024-12-09
--   Group C: 2024-12-09  
--   Group D: 2024-12-14
--   Group E: 2024-12-22
