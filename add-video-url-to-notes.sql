-- ============================================================
-- ADD VIDEO URL SUPPORT TO STUDENT NOTES
-- Adds protected YouTube video capability to notes
-- ============================================================

-- Add video_url column to student_notes table
ALTER TABLE student_notes 
ADD COLUMN IF NOT EXISTS video_url TEXT;

-- Add comment
COMMENT ON COLUMN student_notes.video_url IS 'Protected YouTube video URL (only displayed in iframe, never exposed to students)';

-- Verify the column was added
SELECT column_name, data_type, is_nullable
FROM information_schema.columns
WHERE table_name = 'student_notes' AND column_name = 'video_url';
