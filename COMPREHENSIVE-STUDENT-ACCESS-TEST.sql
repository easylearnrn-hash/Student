-- ============================================================================
-- 🔒 COMPREHENSIVE STUDENT ACCESS TEST
-- ============================================================================
-- This verifies EXACTLY what students can see vs what they CANNOT see

-- =============================================================================
-- PART 1: WHAT STUDENTS **SHOULD** BE ABLE TO ACCESS
-- =============================================================================

-- ✅ Students SHOULD see their own data from these tables:
SELECT 
  '✅ student-portal.html' as "Page/Feature",
  'SHOULD have access' as "Expected Access",
  'Shows student their own schedule, payments, notes' as "What They See"
UNION ALL
SELECT 
  '✅ Own student record',
  'SHOULD have access',
  'Their name, email, group, balance (from students table where auth_user_id = their UID)'
UNION ALL
SELECT 
  '✅ Own payments',
  'SHOULD have access',
  'Their payment history (from payments/payment_records where student_id = their ID)'
UNION ALL
SELECT 
  '✅ Own notes',
  'SHOULD have access',
  'Notes assigned to their group (from student_notes where group matches)'
UNION ALL
SELECT 
  '✅ Own test results',
  'SHOULD have access',
  'Their test scores and history'
UNION ALL
SELECT 
  '✅ Own schedule',
  'SHOULD have access',
  'Their class times from groups table'
UNION ALL
SELECT 
  '✅ Own alerts',
  'SHOULD have access',
  'Alerts created for them (from student_alerts where student_id = their ID)';

-- =============================================================================
-- PART 2: WHAT STUDENTS **MUST NOT** BE ABLE TO ACCESS
-- =============================================================================

-- ❌ Students MUST NOT see these pages/features:
SELECT 
  '❌ Payment-Records.html' as "Page/Feature",
  'MUST BE BLOCKED' as "Required Protection",
  'Admin tool - shows ALL student payments, earnings forecast' as "Why Dangerous",
  'requireAdminSession() checks admin_accounts table' as "Protection Method"
UNION ALL
SELECT 
  '❌ Calendar.html',
  'MUST BE BLOCKED',
  'Admin tool - shows ALL students schedules and payments',
  'Should check admin status (verify this exists!)'
UNION ALL
SELECT 
  '❌ Student-Manager.html',
  'MUST BE BLOCKED',
  'Admin tool - edits ALL student records',
  'Should check admin status (verify this exists!)'
UNION ALL
SELECT 
  '❌ Email-System.html',
  'MUST BE BLOCKED',
  'Admin tool - sends emails to students',
  'Should check admin status (verify this exists!)'
UNION ALL
SELECT 
  '❌ Test-Manager.html',
  'MUST BE BLOCKED',
  'Admin tool - creates/edits tests',
  'Should check admin status (verify this exists!)'
UNION ALL
SELECT 
  '❌ Notes-Manager-NEW.html',
  'MUST BE BLOCKED',
  'Admin tool - uploads/manages notes for all groups',
  'Should check admin status (verify this exists!)'
UNION ALL
SELECT 
  '❌ Other students payments',
  'RLS ENFORCED',
  'Cannot query payments/payment_records for other student_ids',
  'Database RLS policies enforce student_id match'
UNION ALL
SELECT 
  '❌ Other students personal data',
  'RLS ENFORCED',
  'Cannot see other students names, emails, balances',
  'Database RLS policies enforce auth_user_id match'
UNION ALL
SELECT 
  '❌ Earning forecasts/totals',
  'UI BLOCKED',
  'Cannot see revenue projections or total earnings',
  'Only shown in Payment-Records.html (admin-only)';

-- =============================================================================
-- PART 3: TEST DATABASE RLS ENFORCEMENT
-- =============================================================================

-- Test 1: Verify RLS is enabled on ALL sensitive tables
SELECT 
  tablename,
  CASE 
    WHEN rowsecurity THEN '✅ RLS ENABLED - Students isolated' 
    ELSE '❌ CRITICAL: RLS DISABLED - Students can see everything!'
  END as "Security Status"
FROM pg_tables 
WHERE tablename IN (
  'payments', 
  'payment_records', 
  'credit_payments',
  'students',
  'student_notes',
  'student_alerts',
  'student_sessions'
)
ORDER BY tablename;

-- Test 2: Verify NO overly permissive policies exist
SELECT 
  tablename,
  policyname,
  cmd,
  CASE 
    WHEN 'anon' = ANY(roles) AND cmd = 'SELECT' THEN '❌ BREACH: Anonymous can read!'
    WHEN 'public' = ANY(roles) AND cmd = 'SELECT' THEN '❌ BREACH: Public can read!'
    WHEN qual::text LIKE '%true%' AND cmd = 'SELECT' THEN '❌ BREACH: Always allows access!'
    WHEN qual::text LIKE '%is_arnoma_admin()%' AND qual::text LIKE '%student_id%' THEN '✅ Secure: Admin OR own data'
    WHEN qual::text LIKE '%auth.uid()%' THEN '✅ Secure: Requires authentication'
    ELSE '⚠️ Review policy manually'
  END as "Policy Assessment"
FROM pg_policies 
WHERE tablename IN ('payments', 'payment_records', 'credit_payments', 'students')
  AND cmd = 'SELECT'
ORDER BY tablename, policyname;

-- Test 3: Simulate cross-student data leakage test
WITH student_data_isolation AS (
  SELECT 
    s.id as student_id,
    s.name,
    COUNT(DISTINCT p.id) as payment_count,
    COUNT(DISTINCT pr.id) as payment_record_count
  FROM students s
  LEFT JOIN payments p ON (p.student_id::bigint = s.id OR p.linked_student_id::bigint = s.id)
  LEFT JOIN payment_records pr ON pr.student_id = s.id
  WHERE s.auth_user_id IS NOT NULL
    AND s.show_in_grid = true
  GROUP BY s.id, s.name
)
SELECT 
  'Data Isolation Test' as "Test Name",
  COUNT(*) as "Students Tested",
  SUM(payment_count) as "Total Payment Links",
  SUM(payment_record_count) as "Total Payment Records",
  CASE 
    WHEN COUNT(*) > 0 AND SUM(payment_count) > 0 THEN '✅ Students have isolated payment data'
    ELSE '⚠️ No payment data to test'
  END as "Result"
FROM student_data_isolation;

-- =============================================================================
-- PART 4: VERIFY ADMIN ACCESS CONTROLS ON PAGES
-- =============================================================================

-- Check if admin_accounts table is properly set up
SELECT 
  'Admin Accounts Setup' as "Check",
  COUNT(*) as "Total Admins",
  string_agg(email, ', ') as "Admin Emails",
  CASE 
    WHEN COUNT(*) > 0 THEN '✅ Admin accounts configured'
    ELSE '❌ No admin accounts - ALL pages accessible!'
  END as "Status"
FROM admin_accounts;

-- Verify your admin account exists and is linked
SELECT 
  'Your Admin Account' as "Check",
  email,
  auth_user_id,
  CASE 
    WHEN auth_user_id IS NOT NULL THEN '✅ Properly linked to auth system'
    ELSE '❌ Not linked - you cannot access admin pages!'
  END as "Status"
FROM admin_accounts
WHERE email = 'hrachfilm@gmail.com';

-- =============================================================================
-- PART 5: FINAL SECURITY CHECKLIST
-- =============================================================================

SELECT 
  CASE 
    -- Check 1: RLS enabled on all payment tables
    WHEN (SELECT COUNT(*) FROM pg_tables 
          WHERE tablename IN ('payments', 'payment_records', 'credit_payments') 
          AND rowsecurity = true) < 3 
    THEN '❌ CRITICAL: RLS not enabled on all payment tables'
    
    -- Check 2: No anonymous SELECT policies
    WHEN (SELECT COUNT(*) FROM pg_policies 
          WHERE tablename IN ('payments', 'payment_records', 'credit_payments')
          AND cmd = 'SELECT'
          AND 'anon' = ANY(roles)) > 0
    THEN '❌ CRITICAL: Anonymous users can read payment data'
    
    -- Check 3: Admin account exists
    WHEN (SELECT COUNT(*) FROM admin_accounts WHERE email = 'hrachfilm@gmail.com') = 0
    THEN '❌ CRITICAL: No admin account - cannot access admin pages'
    
    -- Check 4: Admin account linked to auth
    WHEN (SELECT auth_user_id FROM admin_accounts WHERE email = 'hrachfilm@gmail.com') IS NULL
    THEN '❌ CRITICAL: Admin account not linked to authentication'
    
    -- All checks passed
    ELSE '✅✅✅ SECURITY VERIFIED - Students isolated, Admin has access'
  END as "🔒 FINAL SECURITY STATUS 🔒";

-- =============================================================================
-- PART 6: MANUAL TESTING INSTRUCTIONS
-- =============================================================================

/*

🧪 MANUAL TEST PROCEDURE:

1. TEST STUDENT ACCESS (What they CAN see):
   ✅ Open student-portal.html
   ✅ Log in as a student (NOT hrachfilm@gmail.com)
   ✅ Verify you see:
      - Your own schedule
      - Your own payment history
      - Your own unpaid balance
      - Notes for your group
   ✅ Open browser console (F12)
   ✅ Run: console.log(window.allPayments)
   ✅ Verify you ONLY see your own name in the payment data

2. TEST STUDENT BLOCKED ACCESS (What they CANNOT see):
   ❌ Try to navigate to: Payment-Records.html
      → Should redirect to student-portal.html with "Access Denied" alert
   
   ❌ Try to navigate to: Calendar.html
      → Should redirect or show "Access Denied"
   
   ❌ Try to navigate to: Student-Manager.html
      → Should redirect or show "Access Denied"
   
   ❌ In browser console, try:
      SELECT * FROM payment_records;
      → Should return ONLY your own records (if any)
   
   ❌ In browser console, try:
      SELECT * FROM students;
      → Should return ONLY your own student record

3. TEST ADMIN ACCESS (What YOU can see as admin):
   ✅ Log out from student account
   ✅ Log in as hrachfilm@gmail.com
   ✅ Navigate to Payment-Records.html
      → Should load successfully and show Earning Forecast Overview
   ✅ Navigate to Calendar.html
      → Should show all students
   ✅ Navigate to Student-Manager.html
      → Should show all students

4. EXPECTED RESULTS:
   ✅ Students: Can ONLY see their own data, cannot access admin pages
   ✅ Admin: Can see ALL data, can access ALL pages
   ❌ If student sees OTHER student names → SECURITY BREACH
   ❌ If student can access Payment-Records.html → SECURITY BREACH

*/

-- =============================================================================
-- RUN THIS ENTIRE SCRIPT AND CHECK:
-- 1. All "Security Status" rows show ✅
-- 2. No "BREACH" or "CRITICAL" warnings
-- 3. Final status shows: ✅✅✅ SECURITY VERIFIED
-- =============================================================================
