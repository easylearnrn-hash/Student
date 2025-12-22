-- FIRST: Check how many permissions exist RIGHT NOW
SELECT COUNT(*) as total_count FROM student_note_permissions;

-- Show ALL permissions grouped by type
SELECT 
  CASE WHEN student_id IS NULL THEN 'GROUP' ELSE 'INDIVIDUAL' END as type,
  group_name,
  granted_by,
  COUNT(*) as count
FROM student_note_permissions
GROUP BY 
  CASE WHEN student_id IS NULL THEN 'GROUP' ELSE 'INDIVIDUAL' END,
  group_name,
  granted_by
ORDER BY granted_by DESC;

-- Show the most recent 50 permissions
SELECT 
  id,
  note_id,
  student_id,
  group_name,
  granted_by,
  granted_at
FROM student_note_permissions
ORDER BY granted_at DESC
LIMIT 50;
