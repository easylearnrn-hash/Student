-- Check all FREE access grants in the database
SELECT 
  nfa.id,
  nfa.note_id,
  sn.title as note_title,
  nfa.access_type,
  nfa.group_letter,
  nfa.student_id,
  s.name as student_name,
  nfa.created_at,
  nfa.created_by
FROM note_free_access nfa
LEFT JOIN student_notes sn ON sn.id = nfa.note_id
LEFT JOIN students s ON s.id = nfa.student_id
ORDER BY nfa.created_at DESC;

-- Count by access type
SELECT 
  access_type,
  COUNT(*) as total_grants
FROM note_free_access
GROUP BY access_type;
