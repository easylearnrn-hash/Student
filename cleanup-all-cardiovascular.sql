-- COMPLETE CLEANUP: Delete all cardiovascular notes (database + permissions)
-- Run this in Supabase SQL Editor, then re-upload with fixed code

-- Step 1: See what will be deleted
SELECT 
  id,
  title,
  pdf_url,
  class_date,
  created_at
FROM student_notes
WHERE group_name = 'Cardiovascular System'
ORDER BY created_at DESC;

-- Step 2: Delete permissions first (foreign key constraint)
DELETE FROM student_note_permissions
WHERE note_id IN (
  SELECT id FROM student_notes
  WHERE group_name = 'Cardiovascular System'
);

-- Step 3: Delete all cardiovascular notes from database
DELETE FROM student_notes
WHERE group_name = 'Cardiovascular System';

-- Step 4: Verify deletion
SELECT COUNT(*) as remaining_cardiovascular_notes
FROM student_notes
WHERE group_name = 'Cardiovascular System';

-- Should return 0

-- Step 5: Verify storage is clean (optional - run in Storage browser)
-- Go to Supabase → Storage → student-notes → Cardiovascular-System folder
-- Delete any files if they exist
