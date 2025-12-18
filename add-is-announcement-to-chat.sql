-- =====================================================
-- ADD IS_ANNOUNCEMENT COLUMN TO CHAT_MESSAGES
-- =====================================================
-- Allows admin to post announcements (red bubble messages)
-- that appear to all students in a group
-- =====================================================

-- Add is_announcement column to chat_messages
ALTER TABLE chat_messages 
ADD COLUMN IF NOT EXISTS is_announcement BOOLEAN NOT NULL DEFAULT FALSE;

-- Create index for performance when filtering announcements
CREATE INDEX IF NOT EXISTS idx_chat_messages_is_announcement 
ON chat_messages(is_announcement) 
WHERE is_announcement = true;

-- Add comment for documentation
COMMENT ON COLUMN chat_messages.is_announcement IS 'True if message is an admin announcement (red bubble) visible to all students in group';

-- =====================================================
-- VERIFICATION
-- =====================================================
-- Run this to verify the column was added:
-- SELECT column_name, data_type, is_nullable, column_default
-- FROM information_schema.columns
-- WHERE table_name = 'chat_messages' AND column_name = 'is_announcement';
