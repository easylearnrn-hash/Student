-- Add question/answer functionality to student_alerts table
-- Run this in Supabase SQL Editor after creating the base table

-- Add columns for yes/no questions and flexible answer options
ALTER TABLE student_alerts 
ADD COLUMN IF NOT EXISTS has_question BOOLEAN DEFAULT FALSE,
ADD COLUMN IF NOT EXISTS question_text TEXT,
ADD COLUMN IF NOT EXISTS answer_option_1 TEXT DEFAULT 'Yes',
ADD COLUMN IF NOT EXISTS answer_option_2 TEXT DEFAULT 'No',
ADD COLUMN IF NOT EXISTS student_answer TEXT,
ADD COLUMN IF NOT EXISTS answered_at TIMESTAMP WITH TIME ZONE,
ADD COLUMN IF NOT EXISTS scheduled_for TIMESTAMP WITH TIME ZONE,
ADD COLUMN IF NOT EXISTS is_one_time BOOLEAN DEFAULT FALSE,
ADD COLUMN IF NOT EXISTS show_on_open BOOLEAN DEFAULT FALSE;

-- Drop the old constraint if it exists
ALTER TABLE student_alerts 
DROP CONSTRAINT IF EXISTS valid_answer;

-- Create index for faster queries on answered alerts
CREATE INDEX IF NOT EXISTS idx_student_alerts_has_question ON student_alerts(has_question);
CREATE INDEX IF NOT EXISTS idx_student_alerts_answered ON student_alerts(student_answer) WHERE student_answer IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_student_alerts_scheduled ON student_alerts(scheduled_for) WHERE scheduled_for IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_student_alerts_show_on_open ON student_alerts(show_on_open) WHERE show_on_open = TRUE;
