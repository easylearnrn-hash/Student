-- Check if any Group C students have INDIVIDUAL note access
-- Individual access might override or conflict with group access

SELECT 
    s.id,
    s.name,
    s.group_name,
    nfa.access_type,
    COUNT(DISTINCT nfa.note_id) as note_count,
    STRING_AGG(DISTINCT nfa.note_id::text, ', ' ORDER BY nfa.note_id::text) as note_ids
FROM students s
LEFT JOIN note_free_access nfa ON nfa.student_id = s.id
WHERE s.group_name = 'C'
GROUP BY s.id, s.name, s.group_name, nfa.access_type
ORDER BY s.name, nfa.access_type;

-- Also check what Group C has access to
SELECT 
    access_type,
    group_letter,
    COUNT(DISTINCT note_id) as note_count
FROM note_free_access
WHERE group_letter = 'C'
GROUP BY access_type, group_letter;
