-- ============================================
-- TEST AUTHENTICATION & AUTHORIZATION SETUP
-- ============================================

-- TEST 1: Verify admin account is linked correctly
-- Should show hrachfilm@gmail.com with role='admin' and auth_user_id filled
SELECT 
  id,
  name,
  email,
  role,
  auth_user_id,
  CASE 
    WHEN auth_user_id IS NOT NULL AND role = 'admin' THEN '✅ Admin setup complete'
    WHEN auth_user_id IS NULL THEN '❌ No auth_user_id linked'
    WHEN role != 'admin' THEN '❌ Role is not admin'
    ELSE '⚠️ Unknown issue'
  END as status
FROM students
WHERE email = 'hrachfilm@gmail.com';

-- TEST 2: Check all students and their auth status
-- Shows which students have auth accounts linked and their roles
SELECT 
  id,
  name,
  email,
  role,
  auth_user_id,
  CASE 
    WHEN auth_user_id IS NOT NULL THEN '✅ Has auth account'
    ELSE '❌ No auth account'
  END as auth_status
FROM students
ORDER BY 
  CASE WHEN role = 'admin' THEN 0 ELSE 1 END,
  name;

-- TEST 3: Verify RLS is disabled (current state)
-- Should show rowsecurity = false for all tables
SELECT 
  tablename,
  rowsecurity,
  CASE 
    WHEN rowsecurity = false THEN '✅ RLS disabled (public access)'
    ELSE '⚠️ RLS enabled (may block access)'
  END as status
FROM pg_tables
WHERE schemaname = 'public'
  AND tablename IN ('students', 'payment_records', 'payments', 'student_notes', 'schedule_changes', 'groups')
ORDER BY tablename;

-- TEST 4: Count policies on each table
-- Should show existing public/anon policies
SELECT 
  tablename,
  COUNT(*) as policy_count,
  STRING_AGG(policyname, ', ' ORDER BY policyname) as policies
FROM pg_policies
WHERE schemaname = 'public'
  AND tablename IN ('students', 'payment_records', 'payments', 'student_notes')
GROUP BY tablename
ORDER BY tablename;

-- ============================================
-- SUMMARY OF CURRENT STATE
-- ============================================

-- Current setup:
-- 1. RLS is DISABLED on all tables (everyone has public access)
-- 2. Your admin account is linked with auth_user_id and role='admin'
-- 3. Students don't have auth accounts yet (they need to be created)
-- 4. Authentication WORKS (login redirects based on role)
-- 5. Authorization is NOT enforced yet (no RLS blocking data access)

-- What this means:
-- ✅ You can login as admin → goes to Student Manager
-- ✅ Students with auth accounts can login → goes to Student Portal
-- ⚠️ But RLS is disabled, so technically anyone can see all data
-- ⚠️ The app-level checks prevent students from accessing admin tools
-- ⚠️ Database-level security (RLS) is not active yet

-- NEXT STEPS to enable full security:
-- 1. Create student auth accounts (via Supabase Dashboard or SQL)
-- 2. Link student auth accounts to student records (like we did for admin)
-- 3. Re-enable RLS with the auth-based policies we created earlier
-- 4. Test that students can only see their own data
