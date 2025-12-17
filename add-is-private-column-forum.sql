-- Add is_private column to forum_messages table for student-initiated private messages
-- This allows students to send messages that are only visible to the administrator

-- Add the column if it doesn't exist
ALTER TABLE forum_messages 
ADD COLUMN IF NOT EXISTS is_private BOOLEAN DEFAULT false;

-- Add comment to document the column purpose
COMMENT ON COLUMN forum_messages.is_private IS 'When true, message is only visible to the sender and administrator';

-- Create index for performance when filtering private messages
CREATE INDEX IF NOT EXISTS idx_forum_messages_is_private 
ON forum_messages (is_private) 
WHERE is_private = true;

-- Update RLS policies to respect is_private flag
-- Students can only see private messages if they are the sender
-- Admin sees all messages

-- Drop existing select policy if it exists
DROP POLICY IF EXISTS "Students can view forum messages" ON forum_messages;

-- Recreate with privacy logic
CREATE POLICY "Students can view forum messages" ON forum_messages
FOR SELECT
USING (
  -- Admin sees everything
  is_arnoma_admin() OR
  
  -- Public messages (is_private = false or null)
  (is_private IS NOT TRUE) OR
  
  -- Private messages: only sender and admin can see
  (is_private = true AND student_id IN (
    SELECT id FROM students WHERE auth_user_id = auth.uid()
  ))
);
