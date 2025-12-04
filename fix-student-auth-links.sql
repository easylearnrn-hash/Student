-- ============================================================
-- FIX STUDENT AUTH LINKAGE
-- ============================================================
-- This script helps identify students without auth accounts
-- You'll need to create auth accounts manually or via Supabase dashboard

-- STEP 1: List all students who need auth accounts
SELECT 
  id,
  name,
  email,
  'NEEDS AUTH ACCOUNT' as status
FROM students
WHERE auth_user_id IS NULL
  AND email IS NOT NULL
  AND email != ''
ORDER BY name;

-- STEP 2: After creating auth accounts in Supabase Dashboard:
-- Go to Authentication > Users > Invite User
-- Use the emails from the list above
-- Then come back and run this to link them:

-- Example update (replace with actual values after creating auth user):
-- UPDATE students 
-- SET auth_user_id = 'PASTE_UUID_FROM_AUTH_USERS_HERE'
-- WHERE email = 'student-email@example.com';

-- STEP 3: Verify linkage after updates
SELECT 
  s.id,
  s.name,
  s.email,
  s.auth_user_id,
  CASE 
    WHEN s.auth_user_id IS NULL THEN '❌ NOT LINKED'
    WHEN au.id IS NOT NULL THEN '✅ LINKED & VERIFIED'
    ELSE '⚠️ LINKED BUT USER NOT FOUND'
  END as status
FROM students s
LEFT JOIN auth.users au ON s.auth_user_id::text = au.id::text
ORDER BY 
  CASE 
    WHEN s.auth_user_id IS NULL THEN 1
    WHEN au.id IS NULL THEN 2
    ELSE 0
  END,
  s.name;

-- STEP 4: Count summary
SELECT 
  COUNT(*) FILTER (WHERE auth_user_id IS NOT NULL) as linked_students,
  COUNT(*) FILTER (WHERE auth_user_id IS NULL) as unlinked_students,
  COUNT(*) as total_students
FROM students;
