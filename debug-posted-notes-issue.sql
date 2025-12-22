-- Check what's in student_note_permissions to see why notes aren't showing as posted
-- This will help debug why the UI shows notes as "unposted" when they should be "posted"

SELECT 
  id,
  note_id,
  student_id,
  group_name,
  is_accessible,
  granted_at
FROM student_note_permissions
ORDER BY granted_at DESC
LIMIT 50;

-- Also check the group names used
SELECT DISTINCT group_name 
FROM student_note_permissions 
ORDER BY group_name;

-- Check if there are any notes without permissions
SELECT 
  sn.id,
  sn.title,
  sn.system_category,
  COUNT(snp.id) as permission_count
FROM student_notes sn
LEFT JOIN student_note_permissions snp ON sn.id = snp.note_id
WHERE sn.is_system_note = true
GROUP BY sn.id, sn.title, sn.system_category
HAVING COUNT(snp.id) = 0
LIMIT 20;
