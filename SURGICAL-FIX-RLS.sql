-- ========================================
-- SURGICAL FIX: Remove Problematic Policies
-- ========================================
-- Based on audit results from your database

-- ============================================================
-- STEP 1: Remove policies that query auth.users (CRITICAL!)
-- ============================================================

-- These 3 policies cause "permission denied for table users" error
DROP POLICY IF EXISTS "Admin and student payment_records access" ON payment_records;
DROP POLICY IF EXISTS "Admins can manage note permissions" ON student_note_permissions;
DROP POLICY IF EXISTS "Admins can view all sessions" ON student_sessions;

-- ============================================================
-- STEP 2: Remove duplicate/overlapping SELECT policies on students
-- ============================================================

-- Keep only students_admin_all (the good one), remove the rest
-- Students table already has students_admin_all which works perfectly
-- These are redundant:
DROP POLICY IF EXISTS "Students can view own profile" ON students;
DROP POLICY IF EXISTS "Students can view own record" ON students;

-- ============================================================
-- STEP 3: Remove overlapping payment_records SELECT policy
-- ============================================================

-- Keep payment_records_select_admin_or_owner (uses is_arnoma_admin)
-- Remove the one that queries auth.users (already done in Step 1)

-- ============================================================
-- STEP 4: Clean up groups table (4 ALL policies + 2 SELECT!)
-- ============================================================

-- Keep only: auth_only_groups (simple and works)
DROP POLICY IF EXISTS "Admins can manage groups" ON groups;
DROP POLICY IF EXISTS "Allow anon full access to groups" ON groups;
DROP POLICY IF EXISTS "groups_write_admin_only" ON groups;

-- Keep only: groups_select_all for reading
DROP POLICY IF EXISTS "Everyone can view groups" ON groups;

-- ============================================================
-- STEP 5: Verify your admin account exists
-- ============================================================

SELECT 
  auth_user_id,
  email
FROM admin_accounts
WHERE email = 'hrachfilm@gmail.com';

-- Expected: 3d03b89d-b62c-47ce-91de-32b1af6d748d | hrachfilm@gmail.com

-- ============================================================
-- STEP 6: Verify cleaned policies on key tables
-- ============================================================

SELECT 
  tablename,
  policyname,
  cmd
FROM pg_policies
WHERE tablename IN ('students', 'payment_records', 'credit_payments', 'groups')
  AND schemaname = 'public'
ORDER BY tablename, cmd;

-- Expected for students:
-- students_admin_all (ALL) - this is the ONE we need!

-- Expected for payment_records:
-- payment_records_write_admin_only (ALL)
-- payment_records_select_admin_or_owner (SELECT)

-- Expected for credit_payments:
-- credit_payments_write_admin_only (ALL)
-- auth_only_credit_payments (ALL)
-- credit_payments_select_admin_or_owner (SELECT)

-- ============================================================
-- DONE! Now test "Apply from Credit" in Calendar
-- ============================================================
