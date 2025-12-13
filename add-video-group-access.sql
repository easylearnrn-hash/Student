-- ============================================================
-- ADD GROUP-SPECIFIC VIDEO ACCESS
-- Allows videos to be restricted to specific groups
-- ============================================================

-- Add allowed_groups column to student_notes
ALTER TABLE student_notes 
ADD COLUMN IF NOT EXISTS video_allowed_groups TEXT[];

-- Add comment
COMMENT ON COLUMN student_notes.video_allowed_groups IS 'Array of group letters (A-F) that can view the video. NULL = all groups can see it';

-- Example usage:
-- To allow only groups A and C to see video:
-- UPDATE student_notes SET video_allowed_groups = ARRAY['A', 'C'] WHERE id = 123;

-- To allow all groups (remove restriction):
-- UPDATE student_notes SET video_allowed_groups = NULL WHERE id = 123;

-- Verify the column was added
SELECT column_name, data_type, is_nullable
FROM information_schema.columns
WHERE table_name = 'student_notes' AND column_name = 'video_allowed_groups';
