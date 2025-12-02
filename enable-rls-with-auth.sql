-- ============================================
-- RE-ENABLE RLS WITH AUTHENTICATION POLICIES
-- ============================================
-- Run this AFTER:
-- 1. Admin account is linked (hrachfilm@gmail.com)
-- 2. Student accounts are created and linked
-- 
-- This will activate the existing policies and enforce:
-- - Admins can see/edit everything
-- - Students can only see their own data
-- ============================================

-- STEP 1: Remove the "Allow anon full access" policies
-- These were for the old public access pattern, we don't need them anymore
DROP POLICY IF EXISTS "Allow anon full access to students" ON students;
DROP POLICY IF EXISTS "Allow anon full access to payments" ON payments;

-- STEP 2: Enable RLS on all tables
-- This activates the authentication-based policies
ALTER TABLE students ENABLE ROW LEVEL SECURITY;
ALTER TABLE payment_records ENABLE ROW LEVEL SECURITY;
ALTER TABLE payments ENABLE ROW LEVEL SECURITY;
ALTER TABLE student_notes ENABLE ROW LEVEL SECURITY;
ALTER TABLE schedule_changes ENABLE ROW LEVEL SECURITY;
ALTER TABLE groups ENABLE ROW LEVEL SECURITY;

-- STEP 3: Verify the policies are active
-- Should show all your admin/student policies
SELECT 
  schemaname,
  tablename,
  policyname,
  CASE 
    WHEN policyname ILIKE '%admin%' THEN '👑 Admin policy'
    WHEN policyname ILIKE '%student%' THEN '👤 Student policy'
    ELSE '🔧 Other policy'
  END as policy_type,
  cmd as applies_to,
  qual as using_expression
FROM pg_policies
WHERE schemaname = 'public'
  AND tablename IN ('students', 'payment_records', 'payments', 'student_notes')
ORDER BY 
  tablename,
  CASE 
    WHEN policyname ILIKE '%admin%' THEN 1
    WHEN policyname ILIKE '%student%' THEN 2
    ELSE 3
  END;

-- STEP 4: Verify RLS is enabled
-- Should show rowsecurity = true for all tables
SELECT 
  tablename,
  rowsecurity,
  CASE 
    WHEN rowsecurity = true THEN '🔒 RLS enabled (secure)'
    ELSE '⚠️ RLS disabled (insecure)'
  END as status
FROM pg_tables
WHERE schemaname = 'public'
  AND tablename IN ('students', 'payment_records', 'payments', 'student_notes', 'schedule_changes', 'groups')
ORDER BY tablename;

-- ============================================
-- WHAT THIS DOES
-- ============================================

-- After running this SQL:
-- ✅ Admin (you) can query all students, all payments, all notes
-- ✅ Students can only query their own data (WHERE auth_user_id = current_user_id)
-- ✅ Anonymous access is blocked (must be logged in)
-- ✅ Database enforces security (not just the app UI)

-- Your existing policies will handle:
-- - "Admins have full access to students" → You see everyone
-- - "Students can view own data" → Students see only their record
-- - "Students can view own payments" → Students see only their payments
-- - "Students can view own notes" → Students see only their notes

-- ============================================
-- IMPORTANT: Run this ONLY when ready!
-- ============================================

-- Before running this, make sure:
-- 1. ✅ Your admin account is linked (run link-admin-account.sql first)
-- 2. ✅ You've tested login at Login-Portal.html
-- 3. ⚠️ Student accounts are created (or you're okay testing with just admin)

-- If something breaks after running this:
-- - You can always run disable-rls-emergency.sql again to restore access
-- - Then debug the policy issues
-- - Then try enabling RLS again

-- Test after enabling RLS:
-- 1. Login as admin → should see all students in Student Manager
-- 2. Login as student → should see only own data in Student Portal
-- 3. Try accessing Student Manager as student → should be redirected
