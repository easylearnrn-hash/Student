-- Fix cardiovascular notes missing .pdf extension
-- Run this to add .pdf to the end of all cardiovascular paths

-- Preview the changes first
SELECT 
  id,
  title,
  pdf_url as old_path,
  CONCAT(pdf_url, '.pdf') as new_path
FROM student_notes
WHERE group_name = 'Cardiovascular System'
  AND deleted = false
  AND pdf_url NOT LIKE '%.pdf'
ORDER BY id DESC;

-- Apply the fix
UPDATE student_notes
SET pdf_url = CONCAT(pdf_url, '.pdf')
WHERE group_name = 'Cardiovascular System'
  AND deleted = false
  AND pdf_url NOT LIKE '%.pdf';

-- Verify the fix
SELECT 
  id,
  title,
  pdf_url,
  CASE 
    WHEN pdf_url LIKE '%.pdf' THEN '✅ HAS .pdf'
    ELSE '❌ MISSING .pdf'
  END as extension_status
FROM student_notes
WHERE group_name = 'Cardiovascular System'
  AND deleted = false
ORDER BY id DESC
LIMIT 5;
