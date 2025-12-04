-- Add college field to students table
ALTER TABLE students
ADD COLUMN IF NOT EXISTS college TEXT;

-- Add comment to document the field
COMMENT ON COLUMN students.college IS 'Name of the college/university the student is currently attending';

-- Add college and group fields to forum_messages table
ALTER TABLE forum_messages
ADD COLUMN IF NOT EXISTS student_group TEXT,
ADD COLUMN IF NOT EXISTS student_college TEXT;

-- Add comments
COMMENT ON COLUMN forum_messages.student_group IS 'Group code (A-F) of the student who posted';
COMMENT ON COLUMN forum_messages.student_college IS 'College name of the student who posted';

-- Add college and group fields to forum_replies table
ALTER TABLE forum_replies
ADD COLUMN IF NOT EXISTS student_group TEXT,
ADD COLUMN IF NOT EXISTS student_college TEXT;

-- Add comments
COMMENT ON COLUMN forum_replies.student_group IS 'Group code (A-F) of the student who replied';
COMMENT ON COLUMN forum_replies.student_college IS 'College name of the student who replied';
