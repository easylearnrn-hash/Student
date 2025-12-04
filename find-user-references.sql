-- ========================================================
-- FIND ALL REFERENCES TO alekevin@gmail.com
-- ========================================================

-- First, get the auth user ID
SELECT id as auth_user_id, email 
FROM auth.users 
WHERE email = 'alekevin@gmail.com';

-- Now search ALL tables for any references
-- Copy the UUID from above and use it in the queries below

-- Check what's preventing deletion:
SELECT 
  schemaname,
  tablename,
  pg_size_pretty(pg_total_relation_size(schemaname||'.'||tablename)) AS size
FROM pg_tables
WHERE schemaname NOT IN ('pg_catalog', 'information_schema')
ORDER BY pg_total_relation_size(schemaname||'.'||tablename) DESC;

-- This will show all your tables - then we can check each one manually
