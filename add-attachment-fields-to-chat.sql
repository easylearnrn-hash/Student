-- Add attachment fields to chat_messages table
-- Run this in Supabase SQL Editor

ALTER TABLE chat_messages
ADD COLUMN IF NOT EXISTS attachment_url TEXT,
ADD COLUMN IF NOT EXISTS attachment_name TEXT,
ADD COLUMN IF NOT EXISTS attachment_size BIGINT;

-- Add index for faster queries on messages with attachments
CREATE INDEX IF NOT EXISTS idx_chat_messages_attachment_url 
ON chat_messages(attachment_url) 
WHERE attachment_url IS NOT NULL;

-- Add comment for documentation
COMMENT ON COLUMN chat_messages.attachment_url IS 'Public URL to the uploaded file in Supabase Storage';
COMMENT ON COLUMN chat_messages.attachment_name IS 'Original filename of the uploaded file';
COMMENT ON COLUMN chat_messages.attachment_size IS 'File size in bytes';
