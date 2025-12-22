-- ================================================================
-- CRITICAL FIX: Remove Group C access to Group E-only notes
-- ================================================================
-- Problem: Notes posted ONLY to Group E on Dec 21 are showing for Group C
-- Solution: Delete the incorrect note_free_access grants for Group C
-- ================================================================

-- STEP 1: Find notes posted to Group E on Dec 21-22 that also have Group C grants
SELECT 
    nfa.note_id,
    sn.title,
    STRING_AGG(DISTINCT nfa.group_letter, ', ' ORDER BY nfa.group_letter) as groups_with_access,
    MAX(CASE WHEN nfa.group_letter = 'E' THEN nfa.created_at::date END) as group_e_date,
    MAX(CASE WHEN nfa.group_letter = 'C' THEN nfa.created_at::date END) as group_c_date
FROM note_free_access nfa
JOIN student_notes sn ON sn.id = nfa.note_id
WHERE nfa.access_type = 'group'
  AND EXISTS (
    SELECT 1 FROM note_free_access nfa2
    WHERE nfa2.note_id = nfa.note_id
      AND nfa2.group_letter = 'E'
      AND nfa2.created_at::date >= '2025-12-21'
  )
GROUP BY nfa.note_id, sn.title
HAVING COUNT(DISTINCT nfa.group_letter) > 1
ORDER BY nfa.note_id DESC;

-- ================================================================
-- STEP 2: REMOVE Group C access to notes that were ONLY posted to Group E
-- ================================================================

-- First, let's see which notes Group C should NOT have
-- (Notes that were posted to Group E on Dec 21-22 but Group C's grant is from an earlier bulk operation)

-- DELETE Group C grants for notes posted to Group E on Dec 21-22
-- WHERE Group C's date is ALSO Dec 21-22 (indicating it was incorrectly added during bulk post)
DELETE FROM note_free_access
WHERE access_type = 'group'
  AND group_letter = 'C'
  AND note_id IN (
    SELECT DISTINCT nfa.note_id
    FROM note_free_access nfa
    WHERE nfa.access_type = 'group'
      AND nfa.group_letter = 'E'
      AND nfa.created_at::date >= '2025-12-21'
  )
  AND created_at::date >= '2025-12-21';  -- Only remove C's recent grants, not old ones

-- ================================================================
-- STEP 3: Verify Group C no longer has access to Group E's Dec 21 notes
-- ================================================================
SELECT 
    nfa.note_id,
    sn.title,
    nfa.group_letter,
    nfa.created_at::date as post_date
FROM note_free_access nfa
JOIN student_notes sn ON sn.id = nfa.note_id
WHERE nfa.access_type = 'group'
  AND nfa.note_id IN (
    SELECT note_id FROM note_free_access
    WHERE group_letter = 'E' AND created_at::date >= '2025-12-21'
  )
ORDER BY nfa.note_id, nfa.group_letter;

-- Expected: Should only show Group E for recent notes (Dec 21-22)
