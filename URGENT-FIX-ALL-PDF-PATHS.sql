-- GOOD NEWS: The database paths are already correct!
-- The path shows: "Cardiovascular-System/Cardiovascular System_2025-12-06_1765014631561.pdf"
--                                        ^^ SPACE (correct!) ^^

-- The PDF viewer is working correctly with signed URLs.
-- If PDFs still don't load, the issue is that the files don't exist in Supabase Storage.

-- Check what files actually exist in storage by going to:
-- Supabase Dashboard → Storage → student-notes bucket → Cardiovascular-System folder

-- Verify all cardiovascular notes have correct paths:
SELECT 
  id, 
  title, 
  pdf_url,
  file_name,
  group_name,
  created_at
FROM student_notes
WHERE pdf_url LIKE 'Cardiovascular-System/%'
ORDER BY created_at DESC;

-- If the files don't exist in storage, you need to re-upload them through Notes Manager
