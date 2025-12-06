-- COMPREHENSIVE DIAGNOSTIC: Check what's in database vs what's in storage
-- Run this in Supabase SQL Editor

-- 1. What does the database think the path should be?
SELECT 
  id,
  title,
  pdf_url as database_path,
  file_name,
  created_at
FROM student_notes
WHERE group_name = 'Cardiovascular System'
ORDER BY created_at DESC
LIMIT 5;

-- 2. List ALL files actually in the student-notes bucket
-- Go to: Supabase Dashboard → Storage → student-notes bucket
-- Look in the Cardiovascular-System folder
-- Do the filenames match EXACTLY what the database says?

-- 3. Common issues:
--    - Database: "Cardiovascular-System/Cardiovascular-System_2025..."
--    - Storage:  "Cardiovascular-System/Cardiovascular System_2025..." (space instead of hyphen)
--    
--    OR
--    
--    - Database has path but file doesn't exist in storage at all

-- 4. If you see files in storage, copy the EXACT filename here and we'll update the database
