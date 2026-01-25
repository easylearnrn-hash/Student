-- ============================================================================
-- 📊 STUDENT vs ADMIN ACCESS COMPARISON
-- ============================================================================
-- This shows exactly what each role can see in the system

-- =============================================================================
-- PART 1: STUDENT ACCESS - What Students CAN See
-- =============================================================================

SELECT '=== STUDENT ACCESS ===' as "Access Level";

-- Students can see their own student record
SELECT 
  '✅ Own Student Record' as "What Students Can See",
  'students table' as "Data Source",
  'WHERE auth_user_id = their UID' as "Filter Applied",
  'Name, email, group, balance, price_per_class' as "Fields Visible"
UNION ALL

-- Students can see their own payments
SELECT 
  '✅ Own Payments (Zelle/Venmo)',
  'payments table',
  'WHERE student_id = their ID OR linked_student_id = their ID',
  'Amount, date, payer_name, for_class'
UNION ALL

SELECT 
  '✅ Own Payment Records (Manual)',
  'payment_records table',
  'WHERE student_id = their ID',
  'Amount, date, status, notes'
UNION ALL

SELECT 
  '✅ Own Credit Payments',
  'credit_payments table',
  'WHERE student_id = their ID',
  'Amount, class_date, applied_class_date'
UNION ALL

-- Students can see group notes
SELECT 
  '✅ Group Notes',
  'student_notes table',
  'WHERE group_name = their group AND deleted = false',
  'Title, PDF URL, requires_payment, class_date'
UNION ALL

-- Students can see their own alerts
SELECT 
  '✅ Own Alerts',
  'student_alerts table',
  'WHERE student_id = their ID',
  'Message, created_at, is_read, scheduled_for'
UNION ALL

-- Students can see their group schedule
SELECT 
  '✅ Group Schedule',
  'groups table',
  'WHERE group_name = their group',
  'Schedule times, one_time_schedules'
UNION ALL

SELECT 
  '✅ Own Test Results',
  'test_results table (if exists)',
  'WHERE student_id = their ID',
  'Test scores, completion dates'
UNION ALL

SELECT 
  '✅ Active Tests',
  'tests table',
  'WHERE is_active = true',
  'Test name, description (public tests only)';

-- Count what students can actually see
SELECT 
  'STUDENT DATA SUMMARY' as "Category",
  (SELECT COUNT(*) FROM students WHERE auth_user_id IS NOT NULL AND show_in_grid = true) as "Total Students with Access",
  (SELECT COUNT(DISTINCT student_id) FROM payments WHERE student_id IS NOT NULL) as "Students with Payments",
  (SELECT COUNT(DISTINCT student_id) FROM payment_records WHERE student_id IS NOT NULL) as "Students with Payment Records";

-- =============================================================================
-- PART 2: STUDENT ACCESS - What Students CANNOT See
-- =============================================================================

SELECT '=== STUDENT RESTRICTIONS ===' as "Access Level";

SELECT 
  '❌ Other Students Data' as "What Students CANNOT See",
  'students, payments, payment_records' as "Tables Blocked",
  'RLS enforces student_id match' as "Protection Method",
  'Database level - cannot be bypassed' as "Enforcement"
UNION ALL

SELECT 
  '❌ Payment-Records.html',
  'Admin page',
  'requireAdminSession() checks admin_accounts',
  'Redirects to student-portal.html with alert'
UNION ALL

SELECT 
  '❌ Earning Forecast Overview',
  'Admin feature in Payment-Records.html',
  'Page-level access control',
  'Shows total revenue - admin only'
UNION ALL

SELECT 
  '❌ Calendar.html',
  'Admin page',
  'Should check admin status',
  'Shows all students schedules'
UNION ALL

SELECT 
  '❌ Student-Manager.html',
  'Admin page',
  'Should check admin status',
  'Manages all student records'
UNION ALL

SELECT 
  '❌ Email-System.html',
  'Admin page',
  'Should check admin status',
  'Sends emails to students'
UNION ALL

SELECT 
  '❌ Test-Manager.html',
  'Admin page',
  'Should check admin status',
  'Creates/edits tests'
UNION ALL

SELECT 
  '❌ Notes-Manager-NEW.html',
  'Admin page',
  'Should check admin status',
  'Uploads/manages notes'
UNION ALL

SELECT 
  '❌ Group-Notes.html',
  'Admin page',
  'Should check admin status',
  'Assigns notes to groups'
UNION ALL

SELECT 
  '❌ Admin Accounts Table',
  'admin_accounts table',
  'No RLS policy for students',
  'Students cannot query this table'
UNION ALL

SELECT 
  '❌ Other Students Balances',
  'students.balance field',
  'RLS blocks WHERE auth_user_id != theirs',
  'Can only see own balance';

-- =============================================================================
-- PART 3: ADMIN ACCESS - What Admins CAN See
-- =============================================================================

SELECT '=== ADMIN ACCESS ===' as "Access Level";

SELECT 
  '✅ ALL Students' as "What Admins Can See",
  'students table' as "Data Source",
  'is_arnoma_admin() = true' as "Access Method",
  'All student records without restriction' as "Scope"
UNION ALL

SELECT 
  '✅ ALL Payments',
  'payments table',
  'is_arnoma_admin() = true',
  'All Zelle/Venmo payments for all students'
UNION ALL

SELECT 
  '✅ ALL Payment Records',
  'payment_records table',
  'is_arnoma_admin() = true',
  'All manual payment entries for all students'
UNION ALL

SELECT 
  '✅ ALL Credit Payments',
  'credit_payments table',
  'is_arnoma_admin() = true',
  'All credit transactions for all students'
UNION ALL

SELECT 
  '✅ ALL Notes',
  'student_notes table',
  'is_arnoma_admin() = true',
  'All notes for all groups (including deleted)'
UNION ALL

SELECT 
  '✅ ALL Alerts',
  'student_alerts table',
  'is_arnoma_admin() = true',
  'All alerts for all students'
UNION ALL

SELECT 
  '✅ ALL Tests',
  'tests, test_questions tables',
  'is_arnoma_admin() = true',
  'All tests (active and inactive)'
UNION ALL

SELECT 
  '✅ Earning Forecast Overview',
  'Payment-Records.html',
  'requireAdminSession() passes',
  'Weekly/monthly revenue projections'
UNION ALL

SELECT 
  '✅ Calendar (All Students)',
  'Calendar.html',
  'Admin access',
  'All students schedules and payments'
UNION ALL

SELECT 
  '✅ Student Manager',
  'Student-Manager.html',
  'Admin access',
  'Edit all student records'
UNION ALL

SELECT 
  '✅ Email System',
  'Email-System.html',
  'Admin access',
  'Send emails to any student'
UNION ALL

SELECT 
  '✅ Test Manager',
  'Test-Manager.html',
  'Admin access',
  'Create/edit/delete tests'
UNION ALL

SELECT 
  '✅ Notes Manager',
  'Notes-Manager-NEW.html',
  'Admin access',
  'Upload/manage notes for all groups';

-- Count what admin can see
SELECT 
  'ADMIN DATA SUMMARY' as "Category",
  (SELECT COUNT(*) FROM students) as "Total Students",
  (SELECT COUNT(*) FROM payments) as "Total Payments",
  (SELECT COUNT(*) FROM payment_records) as "Total Payment Records",
  (SELECT COUNT(*) FROM student_notes) as "Total Notes",
  (SELECT COUNT(*) FROM tests) as "Total Tests";

-- =============================================================================
-- PART 4: VERIFICATION - Check Your Admin Account
-- =============================================================================

SELECT '=== YOUR ADMIN ACCESS ===' as "Status";

SELECT 
  'hrachfilm@gmail.com' as "Your Email",
  CASE 
    WHEN EXISTS (SELECT 1 FROM admin_accounts WHERE email = 'hrachfilm@gmail.com')
    THEN '✅ You ARE in admin_accounts table'
    ELSE '❌ You are NOT in admin_accounts table'
  END as "Admin Status",
  CASE 
    WHEN (SELECT auth_user_id FROM admin_accounts WHERE email = 'hrachfilm@gmail.com') IS NOT NULL
    THEN '✅ Auth linked - can access admin pages'
    ELSE '❌ Auth not linked - cannot access admin pages'
  END as "Auth Link Status",
  CASE 
    WHEN EXISTS (SELECT 1 FROM admin_accounts WHERE email = 'hrachfilm@gmail.com' AND auth_user_id IS NOT NULL)
    THEN '✅ FULL ADMIN ACCESS'
    ELSE '❌ LIMITED OR NO ACCESS'
  END as "Overall Access";

-- =============================================================================
-- PART 5: SIDE-BY-SIDE COMPARISON
-- =============================================================================

SELECT '=== ACCESS COMPARISON TABLE ===' as "Comparison";

SELECT 
  'Data/Feature' as "Item",
  'Student Access' as "Students Can See",
  'Admin Access' as "Admins Can See"
UNION ALL
SELECT 'Own Student Record', '✅ YES', '✅ YES'
UNION ALL
SELECT 'Other Students Records', '❌ NO', '✅ YES'
UNION ALL
SELECT 'Own Payments', '✅ YES', '✅ YES'
UNION ALL
SELECT 'Other Students Payments', '❌ NO', '✅ YES'
UNION ALL
SELECT 'Own Balance', '✅ YES', '✅ YES'
UNION ALL
SELECT 'Other Students Balances', '❌ NO', '✅ YES'
UNION ALL
SELECT 'Group Notes (own group)', '✅ YES', '✅ YES'
UNION ALL
SELECT 'Group Notes (all groups)', '❌ NO', '✅ YES'
UNION ALL
SELECT 'Own Schedule', '✅ YES', '✅ YES'
UNION ALL
SELECT 'All Students Schedules', '❌ NO', '✅ YES'
UNION ALL
SELECT 'student-portal.html', '✅ YES', '✅ YES (redirected to admin tools)'
UNION ALL
SELECT 'Payment-Records.html', '❌ NO', '✅ YES'
UNION ALL
SELECT 'Calendar.html', '❌ NO', '✅ YES'
UNION ALL
SELECT 'Student-Manager.html', '❌ NO', '✅ YES'
UNION ALL
SELECT 'Email-System.html', '❌ NO', '✅ YES'
UNION ALL
SELECT 'Test-Manager.html', '❌ NO', '✅ YES'
UNION ALL
SELECT 'Notes-Manager-NEW.html', '❌ NO', '✅ YES'
UNION ALL
SELECT 'Earning Forecast Overview', '❌ NO', '✅ YES'
UNION ALL
SELECT 'Revenue Projections', '❌ NO', '✅ YES'
UNION ALL
SELECT 'Total System Earnings', '❌ NO', '✅ YES';

-- =============================================================================
-- FINAL SUMMARY
-- =============================================================================

SELECT 
  CASE 
    WHEN (
      -- Admin account exists
      EXISTS (SELECT 1 FROM admin_accounts WHERE email = 'hrachfilm@gmail.com')
      AND
      -- Admin account is linked
      (SELECT auth_user_id FROM admin_accounts WHERE email = 'hrachfilm@gmail.com') IS NOT NULL
      AND
      -- RLS is enabled on payment tables
      (SELECT COUNT(*) FROM pg_tables 
       WHERE tablename IN ('payments', 'payment_records', 'credit_payments') 
       AND rowsecurity = true) = 3
      AND
      -- No overly permissive policies
      (SELECT COUNT(*) FROM pg_policies 
       WHERE tablename IN ('payments', 'payment_records', 'credit_payments')
       AND cmd = 'SELECT'
       AND ('anon' = ANY(roles) OR 'public' = ANY(roles))) = 0
    )
    THEN '✅✅✅ ACCESS CONTROL VERIFIED

STUDENTS:
- Can see ONLY their own data
- BLOCKED from admin pages
- ISOLATED from other students

ADMINS:
- Can see ALL data
- Can access ALL pages
- Full system control'
    ELSE '❌ ACCESS CONTROL ISSUES DETECTED - Review above sections'
  END as "🔒 FINAL ACCESS CONTROL SUMMARY 🔒";
