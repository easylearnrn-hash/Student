-- Restore cardiovascular notes that were marked as deleted
-- Use this if you ran the wrong delete script

-- See what can be restored
SELECT 
  id,
  title,
  pdf_url,
  class_date,
  file_size,
  deleted
FROM student_notes
WHERE group_name = 'Cardiovascular System'
  AND deleted = true
ORDER BY class_date DESC;

-- Restore them by setting deleted = false
UPDATE student_notes
SET deleted = false
WHERE group_name = 'Cardiovascular System'
  AND deleted = true;

-- Verify restoration
SELECT COUNT(*) as restored_cardiovascular_notes
FROM student_notes
WHERE group_name = 'Cardiovascular System'
  AND deleted = false;
