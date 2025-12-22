-- ============================================================
-- URGENT: DEBUG WHY ALL GROUPS SEE GROUP E NOTES
-- Run this in Supabase SQL Editor RIGHT NOW
-- ============================================================

-- 1. Show the 3 notes posted today for Group E
SELECT 
  nfa.id,
  nfa.note_id,
  nfa.access_type,
  nfa.group_letter,
  nfa.student_id,
  nfa.created_at,
  nfa.created_by,
  sn.title as note_title,
  sn.system_category
FROM note_free_access nfa
LEFT JOIN student_notes sn ON sn.id = nfa.note_id
WHERE nfa.created_at::date = CURRENT_DATE
ORDER BY nfa.created_at DESC;

-- Expected: Should ONLY show group_letter = 'E'
-- If you see A, B, C, D, or F, that's the bug!

-- 2. Check if there are duplicate entries for the same note
SELECT 
  note_id,
  COUNT(*) as grant_count,
  ARRAY_AGG(DISTINCT group_letter) as groups,
  ARRAY_AGG(DISTINCT created_by) as creators
FROM note_free_access
WHERE created_at::date = CURRENT_DATE
GROUP BY note_id
HAVING COUNT(*) > 1;

-- Expected: Empty result (each note should have ONE group)
-- If you see multiple groups, we found the bug!

-- 3. Show ALL grants for the problematic notes
SELECT 
  nfa.*,
  sn.title
FROM note_free_access nfa
LEFT JOIN student_notes sn ON sn.id = nfa.note_id
WHERE nfa.note_id IN (
  SELECT note_id 
  FROM note_free_access 
  WHERE created_at::date = CURRENT_DATE
)
ORDER BY nfa.note_id, nfa.group_letter;

-- This will show EVERY grant for today's notes
