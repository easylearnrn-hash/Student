-- Add start_date column to students table
-- Run in Supabase SQL Editor

ALTER TABLE students
ADD COLUMN IF NOT EXISTS start_date DATE;

-- Backfill existing students with today's date (so note date-filter doesn't hide all notes for them)
-- UPDATE students SET start_date = CURRENT_DATE WHERE start_date IS NULL;

-- Verify
SELECT id, name, group_name, start_date FROM students ORDER BY name LIMIT 20;
