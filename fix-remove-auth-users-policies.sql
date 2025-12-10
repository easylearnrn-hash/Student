-- ========================================
-- FIX: Remove Policy That Accesses auth.users
-- ========================================

-- Drop the policy that queries auth.users (causes permission error)
DROP POLICY IF EXISTS "Admins can manage students" ON students;
DROP POLICY IF EXISTS "Admins can view all students" ON students;

-- Keep only the safe policies:
-- ✅ students_admin_all - checks admin_accounts.auth_user_id directly (NO auth.users query)
-- ✅ Students can view own profile - simple auth.uid() check
-- ✅ Students can view own record - JWT claims check

-- Verify remaining policies
SELECT 
  policyname,
  cmd,
  qual::text as using_clause,
  with_check::text as with_check_clause
FROM pg_policies 
WHERE tablename = 'students'
ORDER BY cmd, policyname;

-- Expected result after this fix:
-- Only 3 policies should remain, and NONE should query auth.users table

-- Now test "Apply from Credit" button in Calendar!
