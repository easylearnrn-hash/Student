-- Check all Group A note dates to see what needs fixing
SELECT 
    nfa.note_id,
    sn.title,
    nfa.group_letter,
    nfa.created_at::date as current_post_date,
    sn.created_at::date as note_original_creation
FROM note_free_access nfa
JOIN student_notes sn ON sn.id = nfa.note_id
WHERE nfa.access_type = 'group'
  AND nfa.group_letter = 'A'
ORDER BY nfa.note_id DESC
LIMIT 50;
