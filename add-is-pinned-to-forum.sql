-- Add is_pinned column to forum_messages table
-- Run this in Supabase SQL Editor

ALTER TABLE forum_messages 
ADD COLUMN IF NOT EXISTS is_pinned BOOLEAN DEFAULT false;

-- Add index for faster queries on pinned messages
CREATE INDEX IF NOT EXISTS idx_forum_messages_pinned 
ON forum_messages(is_pinned) 
WHERE is_pinned = true;

-- Success message
SELECT 'is_pinned column added successfully to forum_messages' AS result;
