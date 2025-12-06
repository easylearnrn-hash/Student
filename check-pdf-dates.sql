-- Check what dates are in the pdf_url paths
SELECT 
  id,
  title,
  pdf_url,
  SUBSTRING(pdf_url FROM '\d{4}-\d{2}-\d{2}') as extracted_date
FROM student_notes
WHERE pdf_url LIKE 'Cardiovascular-System/%'
ORDER BY id;
