-- Debug: Compare Group C students to find differences
-- One sees carousel, one doesn't

-- First, see all Group C students
SELECT 
    id,
    name,
    group_name,
    show_in_grid,
    auth_user_id,
    email
FROM students
WHERE group_name = 'C'
ORDER BY name;

-- Check if any Group C students have individual note access (might override group access)
SELECT 
    s.id,
    s.name,
    s.group_name,
    COUNT(DISTINCT nfa.note_id) as individual_note_count,
    STRING_AGG(DISTINCT nfa.note_id::text, ', ' ORDER BY nfa.note_id::text) as note_ids
FROM students s
LEFT JOIN note_free_access nfa ON nfa.student_id = s.id AND nfa.access_type = 'individual'
WHERE s.group_name = 'C'
GROUP BY s.id, s.name, s.group_name
ORDER BY s.name;

-- Check auth status for Group C students
SELECT 
    s.id,
    s.name,
    s.group_name,
    s.auth_user_id,
    CASE 
        WHEN s.auth_user_id IS NULL THEN 'No auth account'
        ELSE 'Has auth account'
    END as auth_status,
    s.email
FROM students s
WHERE s.group_name = 'C'
ORDER BY s.name;

-- Check if there are any blocked/denied access entries for Group C students
SELECT 
    nfa.student_id,
    s.name,
    nfa.note_id,
    nfa.access_type,
    nfa.group_letter
FROM note_free_access nfa
JOIN students s ON s.id = nfa.student_id
WHERE s.group_name = 'C' 
    AND nfa.access_type IN ('deny', 'blocked')
ORDER BY s.name;
