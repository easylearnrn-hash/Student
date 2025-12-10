-- ========================================
-- FIX: Simplify RLS Policies on Students Table
-- ========================================
-- The issue: is_arnoma_admin() function might be querying auth.users
-- which causes "permission denied for table users" error

-- Step 1: Drop the problematic policies that use is_arnoma_admin()
DROP POLICY IF EXISTS "students_update_admin_or_self" ON students;
DROP POLICY IF EXISTS "students_insert_admin_only" ON students;
DROP POLICY IF EXISTS "students_delete_admin_only" ON students;
DROP POLICY IF EXISTS "students_select_admin_or_self" ON students;

-- Step 2: Keep only the working policies
-- (students_admin_all already works - it checks admin_accounts.auth_user_id directly)

-- Step 3: Verify remaining policies
SELECT 
  policyname,
  cmd,
  qual::text
FROM pg_policies 
WHERE tablename = 'students'
ORDER BY cmd, policyname;

-- Expected result: Only policies that DON'T use is_arnoma_admin() should remain:
-- - students_admin_all (uses admin_accounts.auth_user_id directly)
-- - Admins can manage students (uses admin_accounts.email)
-- - Admins can view all students
-- - Students can view own profile
-- - Students can view own record

-- Step 4: Test UPDATE permission from browser
-- After running this SQL, try "Apply from Credit" button in Calendar again
