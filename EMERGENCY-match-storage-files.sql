-- EMERGENCY FIX: Update database to match what's actually in storage
-- The storage has files like: Cardiovascular-System/Cardiovascular_System_2025-12-02_...
-- But database has: Cardiovascular-System/Cardiovascular-System_2025-12-06_...

-- Option 1: Delete NEW database records (Dec 6) and keep OLD files (Dec 2)
DELETE FROM student_note_permissions
WHERE note_id IN (
  SELECT id FROM student_notes 
  WHERE group_name = 'Cardiovascular System'
  AND created_at >= '2025-12-06'
);

DELETE FROM student_notes
WHERE group_name = 'Cardiovascular System'
AND created_at >= '2025-12-06';

-- Option 2: Update the Dec 6 record to point to a Dec 2 file (TEMPORARY HACK)
-- Find a Dec 2 file in storage and update the database record to use it:
UPDATE student_notes
SET pdf_url = 'Cardiovascular-System/Cardiovascular_System_2025-12-02_1764718909474.pdf'
WHERE id = 281;

-- After running one of the above, test if PDF viewer works with the Dec 2 file
