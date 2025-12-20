-- Allow NULL student_id and student_name in forum_messages for admin messages
-- Run this in Supabase SQL Editor

ALTER TABLE forum_messages 
ALTER COLUMN student_id DROP NOT NULL;

ALTER TABLE forum_messages 
ALTER COLUMN student_name DROP NOT NULL;

ALTER TABLE forum_messages 
ALTER COLUMN student_email DROP NOT NULL;

-- Success message
SELECT 'student_id, student_name, and student_email can now be NULL for admin messages' AS result;
