-- Delete all Cardiovascular System notes that have missing files in storage
-- Run this in Supabase SQL Editor, then re-upload the PDFs through Notes Manager

-- Step 1: Check how many will be deleted
SELECT COUNT(*) as total_to_delete
FROM student_notes
WHERE group_name = 'Cardiovascular System';

-- Step 2: See what will be deleted
SELECT id, title, pdf_url, file_name, created_at
FROM student_notes
WHERE group_name = 'Cardiovascular System'
ORDER BY created_at DESC;

-- Step 3: Delete associated permissions first (foreign key constraint)
DELETE FROM student_note_permissions
WHERE note_id IN (
  SELECT id FROM student_notes WHERE group_name = 'Cardiovascular System'
);

-- Step 4: Delete the notes
DELETE FROM student_notes
WHERE group_name = 'Cardiovascular System';

-- Step 5: Verify deletion
SELECT COUNT(*) as remaining_cardiovascular_notes
FROM student_notes
WHERE group_name = 'Cardiovascular System';

-- Expected result: 0 remaining notes
-- Next step: Go to Notes Manager and re-upload all Cardiovascular PDFs
