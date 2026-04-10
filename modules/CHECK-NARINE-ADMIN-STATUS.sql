-- ============================================================================
-- CHECK NARINE AVETISYAN ADMIN STATUS
-- ============================================================================
-- Verify if Narine is incorrectly listed as admin

-- Check admin_accounts table
SELECT 
  '=== ADMIN ACCOUNTS - NARINE CHECK ===' as "Section",
  auth_user_id,
  email,
  timezone_offset
FROM admin_accounts
WHERE LOWER(email) LIKE '%narine%' OR LOWER(email) LIKE '%avetisyan%';

-- Check students table for Narine
SELECT 
  '=== STUDENTS TABLE - NARINE CHECK ===' as "Section",
  id,
  name,
  email,
  auth_user_id,
  status,
  group_name
FROM students
WHERE LOWER(name) LIKE '%narine%' OR LOWER(email) LIKE '%narine%';

-- Check if Narine's auth_user_id is in admin_accounts
SELECT 
  '=== CROSS-CHECK ===' as "Section",
  s.name as "Student Name",
  s.email as "Student Email",
  s.auth_user_id as "Student Auth ID",
  CASE 
    WHEN a.auth_user_id IS NOT NULL THEN '❌ IS ADMIN (REMOVE!)'
    ELSE '✅ Not Admin (Correct)'
  END as "Admin Status"
FROM students s
LEFT JOIN admin_accounts a ON s.auth_user_id = a.auth_user_id
WHERE LOWER(s.name) LIKE '%narine%' OR LOWER(s.email) LIKE '%narine%';

-- Show ALL admins (should only be you)
SELECT 
  '=== ALL CURRENT ADMINS ===' as "Section",
  auth_user_id,
  email,
  timezone_offset
FROM admin_accounts
ORDER BY email;
