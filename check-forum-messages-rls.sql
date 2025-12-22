-- Check RLS policies on forum_messages table
SELECT 
  schemaname,
  tablename,
  policyname,
  permissive,
  roles,
  cmd,
  qual
FROM pg_policies 
WHERE tablename = 'forum_messages'
ORDER BY policyname;

-- Check if admin has proper access
-- Test query as admin
SELECT 
  id,
  student_id,
  student_name,
  message,
  created_at,
  is_pinned
FROM forum_messages
ORDER BY created_at DESC
LIMIT 20;

-- Count total messages
SELECT COUNT(*) as total_messages FROM forum_messages;

-- Count by role
SELECT 
  CASE 
    WHEN student_id IS NULL THEN 'Admin'
    ELSE 'Student'
  END as role,
  COUNT(*) as message_count
FROM forum_messages
GROUP BY CASE WHEN student_id IS NULL THEN 'Admin' ELSE 'Student' END;
