-- Diagnose why notes show 46 instead of 23
-- Likely counting duplicates or not filtering correctly

-- 0. First, check what columns actually exist in student_notes
SELECT column_name, data_type 
FROM information_schema.columns 
WHERE table_name = 'student_notes'
ORDER BY ordinal_position;

-- 1. Total notes in student_notes table
SELECT COUNT(*) as total_notes
FROM student_notes;

-- 2. How many are NOT deleted?
SELECT COUNT(*) as non_deleted_notes
FROM student_notes
WHERE deleted = false;

-- 3. How many ARE deleted?
SELECT COUNT(*) as deleted_notes
FROM student_notes
WHERE deleted = true;

-- 4. Check if deleted column has NULL values (would fail the deleted = false check)
SELECT COUNT(*) as null_deleted_column
FROM student_notes
WHERE deleted IS NULL;

-- 5. Show first 10 notes to see structure
SELECT *
FROM student_notes
LIMIT 10;
