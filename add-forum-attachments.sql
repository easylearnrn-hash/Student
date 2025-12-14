-- Add attachment columns to forum_messages table
-- This enables file uploads in the student chat/forum

ALTER TABLE forum_messages 
ADD COLUMN IF NOT EXISTS attachment_url TEXT,
ADD COLUMN IF NOT EXISTS attachment_name TEXT,
ADD COLUMN IF NOT EXISTS attachment_type TEXT;

-- Add comment for documentation
COMMENT ON COLUMN forum_messages.attachment_url IS 'Public URL to the uploaded file in Supabase storage';
COMMENT ON COLUMN forum_messages.attachment_name IS 'Original filename of the uploaded document';
COMMENT ON COLUMN forum_messages.attachment_type IS 'MIME type of the uploaded file (e.g., application/pdf, image/jpeg)';

-- Create index for faster queries on messages with attachments
CREATE INDEX IF NOT EXISTS idx_forum_messages_with_attachments 
ON forum_messages(id) 
WHERE attachment_url IS NOT NULL;
