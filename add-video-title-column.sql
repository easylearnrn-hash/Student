-- Add video_title column to student_notes table
-- This allows admins to set a custom name for the video (separate from PDF title)

ALTER TABLE student_notes 
ADD COLUMN IF NOT EXISTS video_title TEXT;

COMMENT ON COLUMN student_notes.video_title IS 'Custom title for the video (optional - if null, uses note title)';

-- Example usage:
-- When admin uploads video with custom name "Cardiovascular System Overview"
-- UPDATE student_notes SET video_title = 'Cardiovascular System Overview' WHERE id = 123;
