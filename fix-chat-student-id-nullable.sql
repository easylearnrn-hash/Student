-- =====================================================
-- FIX: Make student_id nullable for admin announcements
-- =====================================================
-- Admin messages to the group don't have a student context
-- This allows admins to send broadcast messages
-- =====================================================

-- Make student_id nullable (if not already)
ALTER TABLE chat_messages 
ALTER COLUMN student_id DROP NOT NULL;

-- Update the foreign key constraint to allow NULL
-- (The existing constraint already allows CASCADE on delete)

-- Verification query to confirm nullable:
-- SELECT column_name, data_type, is_nullable 
-- FROM information_schema.columns 
-- WHERE table_name = 'chat_messages' AND column_name = 'student_id';

COMMENT ON COLUMN chat_messages.student_id IS 'Student who sent the message. NULL for admin announcements/broadcasts.';
