-- Add video_controls column to student_notes table
-- This stores which video controls are enabled for each note's video
-- Stores as JSONB: {settings: true, play: true, mute: true, fullscreen: true}

ALTER TABLE student_notes
ADD COLUMN IF NOT EXISTS video_controls JSONB DEFAULT NULL;

COMMENT ON COLUMN student_notes.video_controls IS 'Video player controls configuration: {settings, play, mute, fullscreen}';

-- Example of what the data looks like:
-- {
--   "settings": true,    -- Settings menu (quality, speed, subtitles)
--   "play": true,        -- Play/Pause button
--   "mute": true,        -- Mute/Unmute button
--   "fullscreen": true   -- Fullscreen toggle
-- }
