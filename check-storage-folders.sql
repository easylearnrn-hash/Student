-- Check what folder names exist in Supabase Storage
-- by looking at existing pdf_url paths

SELECT DISTINCT
  SPLIT_PART(pdf_url, '/', 1) as folder_name,
  COUNT(*) as note_count
FROM student_notes
WHERE deleted = false
GROUP BY SPLIT_PART(pdf_url, '/', 1)
ORDER BY note_count DESC;
