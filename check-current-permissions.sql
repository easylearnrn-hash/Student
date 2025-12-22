-- Check what's actually in the table RIGHT NOW
SELECT 
  snp.id,
  snp.note_id,
  sn.title,
  sn.system_category,
  snp.student_id,
  s.name as student_name,
  snp.group_name,
  snp.granted_by,
  snp.granted_at
FROM student_note_permissions snp
JOIN student_notes sn ON snp.note_id = sn.id
LEFT JOIN students s ON snp.student_id = s.id
ORDER BY snp.granted_at DESC;

-- Count what we have
SELECT 
  CASE 
    WHEN student_id IS NULL THEN 'Group Permission'
    ELSE 'Individual Permission'
  END as permission_type,
  COUNT(*) as count
FROM student_note_permissions
GROUP BY permission_type;
