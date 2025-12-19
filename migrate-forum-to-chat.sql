-- =====================================================
-- MIGRATE FORUM MESSAGES TO CHAT MESSAGES
-- =====================================================
-- Transfers all messages from old forum_messages table
-- to new chat_messages table with proper field mapping
-- =====================================================

-- Step 1: Insert all forum messages into chat_messages
INSERT INTO chat_messages (
  student_id,
  sender_name,
  sender_college,
  message,
  sender_type,
  is_private,
  is_read,
  created_at,
  updated_at,
  attachment_url,
  attachment_name,
  attachment_size
)
SELECT 
  fm.student_id,
  fm.student_name as sender_name,
  s.college as sender_college,
  fm.message,
  'student' as sender_type,
  COALESCE(fm.is_private, false) as is_private,
  false as is_read,
  fm.created_at,
  fm.created_at as updated_at,
  fm.attachment_url,
  -- Extract filename from URL if attachment exists
  CASE 
    WHEN fm.attachment_url IS NOT NULL THEN 
      substring(fm.attachment_url from '[^/]+$')
    ELSE NULL
  END as attachment_name,
  -- We don't have size in old table, set to NULL
  NULL as attachment_size
FROM forum_messages fm
LEFT JOIN students s ON fm.student_id = s.id
WHERE fm.student_id IS NOT NULL  -- Only migrate messages with valid student_id
ORDER BY fm.created_at ASC;

-- Step 2: Verification query
-- Run this to check the migration results
SELECT 
  'forum_messages' as source_table,
  COUNT(*) as total_messages,
  COUNT(DISTINCT student_id) as unique_students,
  COUNT(CASE WHEN attachment_url IS NOT NULL THEN 1 END) as messages_with_attachments,
  COUNT(CASE WHEN is_private = true THEN 1 END) as private_messages,
  MIN(created_at) as oldest_message,
  MAX(created_at) as newest_message
FROM forum_messages
WHERE student_id IS NOT NULL

UNION ALL

SELECT 
  'chat_messages' as source_table,
  COUNT(*) as total_messages,
  COUNT(DISTINCT student_id) as unique_students,
  COUNT(CASE WHEN attachment_url IS NOT NULL THEN 1 END) as messages_with_attachments,
  COUNT(CASE WHEN is_private = true THEN 1 END) as private_messages,
  MIN(created_at) as oldest_message,
  MAX(created_at) as newest_message
FROM chat_messages
WHERE student_id IS NOT NULL;

-- Step 3: Optional - Archive old forum_messages table
-- UNCOMMENT ONLY AFTER VERIFYING MIGRATION SUCCESS
-- ALTER TABLE forum_messages RENAME TO forum_messages_archived;

COMMENT ON TABLE chat_messages IS 'Migrated from forum_messages on 2025-12-19. Contains all student chat messages with attachment support.';
