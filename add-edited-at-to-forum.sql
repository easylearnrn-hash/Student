-- Add edited_at column to forum_messages table
-- Run this in Supabase SQL Editor

ALTER TABLE forum_messages 
ADD COLUMN IF NOT EXISTS edited_at TIMESTAMPTZ;

-- Add index for faster queries on edited messages
CREATE INDEX IF NOT EXISTS idx_forum_messages_edited_at 
ON forum_messages(edited_at) 
WHERE edited_at IS NOT NULL;

-- Success message
SELECT 'edited_at column added successfully to forum_messages' AS result;
