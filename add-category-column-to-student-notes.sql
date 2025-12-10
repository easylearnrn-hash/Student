-- ===================================================================
-- ADD CATEGORY COLUMN TO STUDENT_NOTES TABLE
-- This will store the system/category name for each note
-- ===================================================================

-- 1. Add the category column
ALTER TABLE student_notes 
ADD COLUMN IF NOT EXISTS category TEXT;

-- 2. Create an index for better query performance
CREATE INDEX IF NOT EXISTS idx_student_notes_category 
ON student_notes(category);

-- 3. OPTIONAL: Populate category from existing data if you have it elsewhere
-- If you have a way to determine the category from existing notes, add it here
-- For example, if you track it in another table or can infer from folder structure

-- 4. Verify the column was added
SELECT column_name, data_type 
FROM information_schema.columns 
WHERE table_name = 'student_notes' 
  AND column_name = 'category';

-- 5. Show sample of notes to verify
SELECT id, title, category, class_date
FROM student_notes
ORDER BY created_at DESC
LIMIT 10;
