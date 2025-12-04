-- Check if there's a way to distinguish folders from actual PDF notes
-- Look for patterns that indicate folder vs file

-- 1. Check ALL columns in student_notes table
SELECT column_name, data_type 
FROM information_schema.columns 
WHERE table_name = 'student_notes'
ORDER BY ordinal_position;

-- 2. Check if file_name or pdf_url patterns differ for Cardiovascular vs others
SELECT 
  id,
  title,
  group_name,
  file_name,
  pdf_url,
  CASE 
    WHEN file_name LIKE '%.pdf' THEN 'PDF File'
    ELSE 'Not PDF'
  END as entry_type
FROM student_notes
WHERE deleted = false
ORDER BY group_name, id
LIMIT 30;

-- 3. Count by whether it's a PDF or not
SELECT 
  CASE 
    WHEN file_name LIKE '%.pdf' THEN 'PDF File'
    ELSE 'Not PDF'
  END as entry_type,
  COUNT(*) as count
FROM student_notes
WHERE deleted = false
GROUP BY entry_type;
