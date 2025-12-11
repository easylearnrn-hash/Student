-- ============================================================================
-- SCHEMA DIAGNOSIS QUERIES
-- Run these in Supabase SQL Editor to understand current state
-- ============================================================================

-- 1. Check actual notifications table structure
SELECT 
  column_name, 
  data_type, 
  is_nullable,
  column_default
FROM information_schema.columns
WHERE table_name = 'notifications'
ORDER BY ordinal_position;

-- 2. Check actual sent_emails table structure  
SELECT 
  column_name, 
  data_type, 
  is_nullable,
  column_default
FROM information_schema.columns
WHERE table_name = 'sent_emails'
ORDER BY ordinal_position;

-- 3. Check if admin_accounts has your email
SELECT email, auth_user_id
FROM admin_accounts;

-- 4. Check existing RLS policies on students table
SELECT 
  schemaname,
  tablename,
  policyname,
  permissive,
  roles,
  cmd,
  qual,
  with_check
FROM pg_policies
WHERE tablename = 'students';
