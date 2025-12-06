-- Add show_on_open column to student_alerts table
-- Run this in Supabase SQL Editor

ALTER TABLE student_alerts 
ADD COLUMN IF NOT EXISTS show_on_open BOOLEAN DEFAULT FALSE;

-- Create index for faster queries
CREATE INDEX IF NOT EXISTS idx_student_alerts_show_on_open 
ON student_alerts(show_on_open) 
WHERE show_on_open = TRUE;
