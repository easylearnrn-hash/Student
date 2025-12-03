-- Check the actual paths of cardiovascular notes in the database
-- This will show if they have spaces or not

SELECT 
  id,
  title,
  pdf_url,
  class_date,
  CASE 
    WHEN pdf_url LIKE '% %' THEN '❌ HAS SPACES'
    ELSE '✅ NO SPACES'
  END as path_status
FROM student_notes
WHERE group_name = 'Cardiovascular System'
  AND deleted = false
ORDER BY class_date DESC, id DESC
LIMIT 30;
