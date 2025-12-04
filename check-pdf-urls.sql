-- Check what's stored in pdf_url for the new Cardiovascular notes

SELECT 
  id,
  title,
  pdf_url,
  file_name,
  created_at
FROM student_notes
WHERE group_name = 'Cardiovascular System'
  AND deleted = false
ORDER BY created_at DESC
LIMIT 5;
