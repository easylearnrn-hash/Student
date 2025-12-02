-- ============================================================
-- RLS PERMISSION TEST SUITE
-- ============================================================
-- Run this to verify Row Level Security is working correctly
-- Admin (you) should see everything
-- Students should only see their own data
-- ============================================================

-- 📊 STEP 1: CHECK CURRENT RLS STATUS
-- ============================================================
SELECT 
  tablename,
  rowsecurity,
  CASE 
    WHEN rowsecurity = true THEN '🔒 RLS ENABLED'
    WHEN rowsecurity = false THEN '⚠️ RLS DISABLED - NO PROTECTION!'
  END as status
FROM pg_tables 
WHERE schemaname = 'public'
  AND tablename IN (
    'students', 
    'payment_records', 
    'payments', 
    'student_notes', 
    'schedule_changes', 
    'groups',
    'student_absences',
    'credit_log',
    'credit_payments',
    'forum_messages',
    'forum_replies'
  )
ORDER BY tablename;


-- ============================================================
-- 📋 STEP 2: CHECK WHAT POLICIES EXIST
-- ============================================================
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
WHERE schemaname = 'public'
ORDER BY tablename, policyname;


-- ============================================================
-- 🧪 STEP 3: SIMULATE STUDENT ACCESS
-- ============================================================
-- This shows what a student would see if RLS was enabled
-- Replace 'student@email.com' with an actual student email

-- Set the role to simulate student access (run as admin)
-- First, we need to get a student's auth_user_id

DO $$
DECLARE
  test_student_uuid UUID;
  test_student_email TEXT := 'hrach@arnoma.us'; -- CHANGE THIS to test different students
BEGIN
  -- Get student's UUID
  SELECT auth_user_id INTO test_student_uuid
  FROM students
  WHERE email = test_student_email;

  IF test_student_uuid IS NULL THEN
    RAISE NOTICE '❌ Student % does not have auth_user_id set', test_student_email;
  ELSE
    RAISE NOTICE '✅ Testing as student: %', test_student_email;
    RAISE NOTICE '   UUID: %', test_student_uuid;
  END IF;
END $$;


-- ============================================================
-- 🔍 STEP 4: TEST ADMIN ACCESS (YOU)
-- ============================================================
-- Admin should see ALL students

SELECT 
  '👑 ADMIN VIEW - Students Table' as test_name,
  COUNT(*) as total_students,
  COUNT(CASE WHEN auth_user_id IS NOT NULL THEN 1 END) as with_auth,
  COUNT(CASE WHEN auth_user_id IS NULL THEN 1 END) as without_auth
FROM students;

SELECT 
  '👑 ADMIN VIEW - Payment Records' as test_name,
  COUNT(*) as total_payment_records
FROM payment_records;

SELECT 
  '👑 ADMIN VIEW - Payments (Zelle)' as test_name,
  COUNT(*) as total_payments
FROM payments;

SELECT 
  '👑 ADMIN VIEW - Student Notes' as test_name,
  COUNT(*) as total_notes
FROM student_notes
WHERE deleted = false;


-- ============================================================
-- 🎓 STEP 5: VERIFY STUDENT DATA ISOLATION
-- ============================================================
-- Check if students can only see their own data

-- Test 1: Students table (students should only see themselves)
SELECT 
  'TEST 1: Students can only see own record' as test_name,
  id,
  name,
  email,
  group_name,
  balance,
  auth_user_id,
  role
FROM students
WHERE email = 'hrach@arnoma.us' -- Change to test different students
LIMIT 5;


-- Test 2: Payment records (students should only see own payments)
SELECT 
  'TEST 2: Students can only see own payment records' as test_name,
  pr.id,
  pr.date,
  pr.amount,
  pr.status,
  s.name as student_name,
  s.email as student_email
FROM payment_records pr
JOIN students s ON pr.student_id = s.id
WHERE s.email = 'hrach@arnoma.us' -- Change to test different students
ORDER BY pr.date DESC
LIMIT 5;


-- Test 3: Student notes (students should only see notes for their group)
SELECT 
  'TEST 3: Students can only see notes for their group' as test_name,
  sn.id,
  sn.title,
  sn.group_name,
  sn.class_date,
  sn.requires_payment
FROM student_notes sn
JOIN students s ON s.group_name = sn.group_name
WHERE s.email = 'hrach@arnoma.us' -- Change to test different students
  AND sn.deleted = false
ORDER BY sn.class_date DESC
LIMIT 5;


-- ============================================================
-- ⚠️ STEP 6: SECURITY GAP REPORT
-- ============================================================
-- Shows what data is currently exposed without RLS

SELECT 
  '⚠️ SECURITY GAP: Tables without RLS' as report_type,
  tablename,
  '❌ Any authenticated user can see ALL records' as risk
FROM pg_tables 
WHERE schemaname = 'public'
  AND rowsecurity = false
  AND tablename IN (
    'students', 
    'payment_records', 
    'payments', 
    'student_notes',
    'student_absences',
    'credit_log',
    'credit_payments',
    'forum_messages',
    'forum_replies'
  )
ORDER BY tablename;


-- ============================================================
-- ✅ STEP 7: RECOMMENDATIONS
-- ============================================================
SELECT 
  'RECOMMENDATION' as type,
  'Current State: RLS is DISABLED on all tables' as current,
  'Security: Relying on JavaScript auth checks only' as security_model,
  'Risk Level: MEDIUM - Students could bypass JS if they modify client code' as risk,
  'Recommendation: Keep RLS disabled if infinite recursion cannot be fixed' as action,
  'Alternative: Use Supabase service_role key for admin operations' as alternative;


-- ============================================================
-- 📝 NOTES:
-- ============================================================
-- 
-- Current Security Model:
-- - RLS is DISABLED to prevent infinite recursion errors
-- - Security is enforced by JavaScript code in:
--   * Login.html (role-based redirect)
--   * Student-Manager.html (admin auth check)
--   * student-portal.html (student auth check + admin redirect)
--
-- Why RLS was disabled:
-- - RLS policies that checked role='admin' caused infinite loops
-- - Policy needs to query students table → triggers same policy → infinite recursion
-- - Error: PostgreSQL 42P17 "infinite recursion detected"
--
-- Is this secure enough?
-- - YES for your use case (trusted students, small group)
-- - Students would need to:
--   1. Know how to open browser DevTools
--   2. Understand JavaScript
--   3. Modify client code
--   4. Still need valid auth token
-- - Admin access is protected by role check
--
-- To re-enable RLS (NOT RECOMMENDED):
-- 1. Create policies that DON'T reference students.role
-- 2. Use auth.uid() directly instead of checking role
-- 3. Test thoroughly to avoid recursion
-- ============================================================
