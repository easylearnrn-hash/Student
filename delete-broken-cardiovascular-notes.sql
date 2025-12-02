-- Delete cardiovascular notes with spaces in filenames
-- Run this in Supabase SQL Editor before re-uploading

-- First, let's see what we're deleting
SELECT 
  id,
  title,
  pdf_url,
  class_date,
  file_size
FROM student_notes
WHERE group_name = 'Cardiovascular System'
  AND pdf_url LIKE '%Cardiovascular System%';  -- Has spaces in filename

-- Delete permissions first (foreign key constraint)
DELETE FROM student_note_permissions
WHERE note_id IN (
  SELECT id FROM student_notes
  WHERE group_name = 'Cardiovascular System'
    AND pdf_url LIKE '%Cardiovascular System%'
);

-- Now delete the broken notes completely
DELETE FROM student_notes
WHERE group_name = 'Cardiovascular System'
  AND pdf_url LIKE '%Cardiovascular System%';  -- Has spaces in filename

-- Verify deletion
SELECT COUNT(*) as remaining_cardiovascular_notes
FROM student_notes
WHERE group_name = 'Cardiovascular System';
