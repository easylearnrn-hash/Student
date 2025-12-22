-- ================================================================
-- FIX GROUP A DATES: Use Original Note Creation Date
-- ================================================================
-- Problem: Group A's note_free_access dates show Dec 12 for many notes
--          but those notes were originally created on Dec 6-9
-- Solution: Update Group A's created_at to match note's original created_at
-- ================================================================

-- STEP 1: View the mismatch
SELECT 
    nfa.note_id,
    sn.title,
    nfa.created_at::date as group_a_current_date,
    sn.created_at::date as note_original_date,
    CASE 
        WHEN nfa.created_at::date != sn.created_at::date THEN '❌ MISMATCH'
        ELSE '✅ OK'
    END as status
FROM note_free_access nfa
JOIN student_notes sn ON sn.id = nfa.note_id
WHERE nfa.access_type = 'group'
  AND nfa.group_letter = 'A'
  AND nfa.note_id >= 292
ORDER BY nfa.note_id DESC;

-- ================================================================
-- STEP 2: Fix all Group A dates to match original note creation
-- ================================================================

-- Update Group A's note_free_access.created_at to match student_notes.created_at
UPDATE note_free_access nfa
SET created_at = sn.created_at
FROM student_notes sn
WHERE nfa.note_id = sn.id
  AND nfa.access_type = 'group'
  AND nfa.group_letter = 'A'
  AND nfa.created_at::date != sn.created_at::date;  -- Only update mismatched dates

-- ================================================================
-- STEP 3: Verify the fix
-- ================================================================
SELECT 
    nfa.note_id,
    sn.title,
    nfa.group_letter,
    nfa.created_at::date as post_date_for_group,
    sn.created_at::date as note_original_date,
    CASE 
        WHEN nfa.created_at::date = sn.created_at::date THEN '✅ FIXED'
        ELSE '❌ STILL WRONG'
    END as status
FROM note_free_access nfa
JOIN student_notes sn ON sn.id = nfa.note_id
WHERE nfa.access_type = 'group'
  AND nfa.group_letter = 'A'
  AND nfa.note_id >= 292
ORDER BY nfa.note_id DESC;

-- Expected: All Group A notes should show original creation date (Dec 6-9)
