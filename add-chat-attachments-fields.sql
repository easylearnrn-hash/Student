-- =====================================================
-- ADD ATTACHMENT FIELDS TO CHAT MESSAGES
-- =====================================================
-- Adds support for file attachments in chat messages
-- Allows students and admins to share files (images, PDFs, etc.)
-- =====================================================

-- Add attachment columns to chat_messages table
ALTER TABLE chat_messages 
ADD COLUMN IF NOT EXISTS attachment_url TEXT,
ADD COLUMN IF NOT EXISTS attachment_name TEXT,
ADD COLUMN IF NOT EXISTS attachment_size BIGINT;

-- Add indexes for attachment queries
CREATE INDEX IF NOT EXISTS idx_chat_messages_has_attachment 
ON chat_messages(id) 
WHERE attachment_url IS NOT NULL;

-- Add comments for documentation
COMMENT ON COLUMN chat_messages.attachment_url IS 'Storage URL for uploaded file attachments (images, PDFs, etc.)';
COMMENT ON COLUMN chat_messages.attachment_name IS 'Original filename of the attachment';
COMMENT ON COLUMN chat_messages.attachment_size IS 'File size in bytes';

-- Verification query
-- SELECT column_name, data_type, is_nullable 
-- FROM information_schema.columns 
-- WHERE table_name = 'chat_messages' 
-- AND column_name IN ('attachment_url', 'attachment_name', 'attachment_size')
-- ORDER BY column_name;
