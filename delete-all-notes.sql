-- Delete all PDF notes from student_notes table
-- This will remove all 46 notes but keep the table structure

-- 1. First, let's see what we're about to delete
SELECT COUNT(*) as total_notes_to_delete
FROM student_notes
WHERE deleted = false;

-- 2. Soft delete all notes (set deleted = true instead of hard delete)
-- This is safer - you can restore if needed
UPDATE student_notes
SET deleted = true,
    updated_at = NOW()
WHERE deleted = false;

-- 3. Verify the soft delete worked
SELECT COUNT(*) as remaining_non_deleted_notes
FROM student_notes
WHERE deleted = false;

-- 4. If you want to PERMANENTLY delete (hard delete), uncomment this:
-- DELETE FROM student_notes WHERE deleted = true;

-- Note: I'm using soft delete (deleted = true) so you can restore if needed.
-- If you want permanent deletion, run the DELETE command above after verifying.
