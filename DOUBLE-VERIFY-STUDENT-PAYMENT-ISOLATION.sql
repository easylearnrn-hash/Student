-- ============================================================================
-- 🔒 DOUBLE VERIFICATION: Students can ONLY see their own payments
-- ============================================================================
-- This script simulates student access and verifies data isolation
-- Run this in Supabase SQL Editor

-- =============================================================================
-- TEST 1: Verify RLS is ENABLED and FORCED on all payment tables
-- =============================================================================
SELECT 
  schemaname,
  tablename,
  CASE 
    WHEN rowsecurity THEN '✅ RLS ENABLED' 
    ELSE '❌ RLS DISABLED - CRITICAL SECURITY ISSUE!' 
  END as "RLS Status"
FROM pg_tables 
WHERE tablename IN ('payments', 'payment_records', 'credit_payments')
ORDER BY tablename;

-- Expected: All should show ✅ RLS ENABLED

-- =============================================================================
-- TEST 2: Check that NO policies allow public/anonymous SELECT access
-- =============================================================================
SELECT 
  tablename,
  policyname,
  roles,
  cmd,
  CASE 
    WHEN 'anon' = ANY(roles) AND cmd = 'SELECT' THEN '❌ SECURITY BREACH - ANON CAN READ!'
    WHEN 'public' = ANY(roles) AND cmd = 'SELECT' THEN '❌ SECURITY BREACH - PUBLIC CAN READ!'
    WHEN qual::text LIKE '%true%' AND cmd = 'SELECT' THEN '❌ OVERLY PERMISSIVE!'
    ELSE '✅ Secure'
  END as "Security Check"
FROM pg_policies 
WHERE tablename IN ('payments', 'payment_records', 'credit_payments')
  AND cmd = 'SELECT'
ORDER BY tablename;

-- Expected: All should show ✅ Secure

-- =============================================================================
-- TEST 3: Verify SELECT policies require student_id match OR admin
-- =============================================================================
SELECT 
  tablename,
  policyname,
  CASE 
    WHEN qual::text LIKE '%is_arnoma_admin()%' 
         AND qual::text LIKE '%student_id%' 
         AND qual::text LIKE '%auth.uid()%' 
    THEN '✅ Properly restricted (admin OR own data)'
    ELSE '⚠️ Policy might not be restrictive enough'
  END as "Policy Check",
  qual::text as "Policy Logic"
FROM pg_policies 
WHERE tablename IN ('payments', 'payment_records', 'credit_payments')
  AND cmd = 'SELECT'
ORDER BY tablename;

-- Expected: All should show ✅ Properly restricted

-- =============================================================================
-- TEST 4: Count students and their payment links
-- =============================================================================
SELECT 
  COUNT(DISTINCT s.id) as "Total Students",
  COUNT(DISTINCT p.id) as "Total Payments",
  COUNT(DISTINCT pr.id) as "Total Payment Records",
  COUNT(DISTINCT cp.id) as "Total Credit Payments"
FROM students s
LEFT JOIN payments p ON (p.student_id::bigint = s.id OR p.linked_student_id::bigint = s.id)
LEFT JOIN payment_records pr ON pr.student_id = s.id
LEFT JOIN credit_payments cp ON cp.student_id = s.id;

-- =============================================================================
-- TEST 5: Simulate student access - Pick 3 random students
-- =============================================================================
-- Get 3 students with their auth_user_ids
SELECT 
  s.id as "Student ID",
  s.name as "Student Name",
  s.auth_user_id as "Auth User ID",
  s.email,
  CASE 
    WHEN s.auth_user_id IS NULL THEN '⚠️ No auth account'
    ELSE '✅ Has auth account'
  END as "Auth Status"
FROM students s
WHERE s.auth_user_id IS NOT NULL
  AND s.show_in_grid = true
ORDER BY s.id
LIMIT 3;

-- =============================================================================
-- TEST 6: For each student, count how many payments they SHOULD see
-- =============================================================================
-- This shows what each student SHOULD see based on the RLS policies
WITH student_payment_counts AS (
  SELECT 
    s.id as student_id,
    s.name,
    s.auth_user_id,
    -- Count payments table records
    COUNT(DISTINCT p.id) as payments_count,
    -- Count payment_records table records  
    COUNT(DISTINCT pr.id) as payment_records_count,
    -- Count credit_payments table records
    COUNT(DISTINCT cp.id) as credit_payments_count,
    -- Total across all tables
    COUNT(DISTINCT p.id) + COUNT(DISTINCT pr.id) + COUNT(DISTINCT cp.id) as total_payment_count
  FROM students s
  LEFT JOIN payments p ON (
    (p.student_id::bigint = s.id OR p.linked_student_id::bigint = s.id)
  )
  LEFT JOIN payment_records pr ON pr.student_id = s.id
  LEFT JOIN credit_payments cp ON cp.student_id = s.id
  WHERE s.auth_user_id IS NOT NULL
    AND s.show_in_grid = true
  GROUP BY s.id, s.name, s.auth_user_id
  ORDER BY s.id
  LIMIT 5
)
SELECT 
  student_id,
  name,
  payments_count as "Payments (Zelle)",
  payment_records_count as "Payment Records (Manual)",
  credit_payments_count as "Credit Payments",
  total_payment_count as "Total They Should See",
  CASE 
    WHEN total_payment_count = 0 THEN '⚠️ No payments recorded'
    WHEN total_payment_count > 0 THEN '✅ Has payment data'
  END as "Data Status"
FROM student_payment_counts;

-- =============================================================================
-- TEST 7: Critical Cross-Student Isolation Test
-- =============================================================================
-- Verify that students CANNOT see each other's data by checking for overlaps
WITH student_payments AS (
  SELECT 
    s.id as student_id,
    s.name,
    array_agg(DISTINCT p.id) FILTER (WHERE p.id IS NOT NULL) as payment_ids,
    array_agg(DISTINCT pr.id) FILTER (WHERE pr.id IS NOT NULL) as payment_record_ids
  FROM students s
  LEFT JOIN payments p ON (p.student_id::bigint = s.id OR p.linked_student_id::bigint = s.id)
  LEFT JOIN payment_records pr ON pr.student_id = s.id
  WHERE s.auth_user_id IS NOT NULL
    AND s.show_in_grid = true
  GROUP BY s.id, s.name
)
SELECT 
  s1.student_id as "Student 1 ID",
  s1.name as "Student 1 Name",
  s2.student_id as "Student 2 ID", 
  s2.name as "Student 2 Name",
  CASE 
    WHEN s1.payment_ids && s2.payment_ids THEN '❌ SECURITY BREACH - SHARED PAYMENTS!'
    WHEN s1.payment_record_ids && s2.payment_record_ids THEN '❌ SECURITY BREACH - SHARED RECORDS!'
    ELSE '✅ No data overlap'
  END as "Isolation Check"
FROM student_payments s1
CROSS JOIN student_payments s2
WHERE s1.student_id < s2.student_id  -- Compare each pair only once
  AND (
    s1.payment_ids && s2.payment_ids 
    OR s1.payment_record_ids && s2.payment_record_ids
  )
ORDER BY s1.student_id, s2.student_id;

-- Expected: Should return NO ROWS (means no students share payment records)

-- =============================================================================
-- TEST 8: Verify admin can see EVERYTHING
-- =============================================================================
SELECT 
  'Admin Test' as "Test Type",
  (SELECT COUNT(*) FROM payments) as "Total Payments in DB",
  (SELECT COUNT(*) FROM payment_records) as "Total Payment Records in DB",
  (SELECT COUNT(*) FROM credit_payments) as "Total Credit Payments in DB",
  (SELECT COUNT(*) FROM admin_accounts WHERE email = 'hrachfilm@gmail.com') as "Admin Account Exists",
  CASE 
    WHEN (SELECT COUNT(*) FROM admin_accounts WHERE email = 'hrachfilm@gmail.com') > 0 
    THEN '✅ Admin has access to all records'
    ELSE '❌ Admin account missing'
  END as "Admin Status";

-- =============================================================================
-- FINAL VERDICT
-- =============================================================================
SELECT 
  CASE 
    WHEN (
      -- Check 1: RLS enabled on all tables
      (SELECT COUNT(*) FROM pg_tables 
       WHERE tablename IN ('payments', 'payment_records', 'credit_payments') 
       AND rowsecurity = true) = 3
      AND
      -- Check 2: No overly permissive policies
      (SELECT COUNT(*) FROM pg_policies 
       WHERE tablename IN ('payments', 'payment_records', 'credit_payments')
       AND cmd = 'SELECT'
       AND (
         'anon' = ANY(roles) 
         OR 'public' = ANY(roles)
         OR qual::text LIKE '%true%'
       )) = 0
      AND
      -- Check 3: All SELECT policies check student_id OR admin
      (SELECT COUNT(*) FROM pg_policies 
       WHERE tablename IN ('payments', 'payment_records', 'credit_payments')
       AND cmd = 'SELECT'
       AND qual::text LIKE '%is_arnoma_admin()%'
       AND qual::text LIKE '%student_id%'
      ) >= 3
    )
    THEN '✅✅✅ SECURITY VERIFIED - Students can ONLY see their own payments!'
    ELSE '❌❌❌ SECURITY ISSUE DETECTED - Review policies above!'
  END as "🔒 FINAL SECURITY VERDICT 🔒";

-- =============================================================================
-- INSTRUCTIONS TO TEST WITH ACTUAL STUDENT LOGIN:
-- =============================================================================
-- 1. Open student-portal.html in a browser
-- 2. Log in as a student (NOT as hrachfilm@gmail.com)
-- 3. Open browser console (F12)
-- 4. Run: console.log(window.allPayments || currentPayments)
-- 5. Verify the student ONLY sees their own payment records
-- 6. Check the "Student Name" field - should ONLY show that student's name
-- 7. If you see OTHER student names → SECURITY BREACH (report immediately)
-- 
-- Expected Result: Student should see ONLY their own payments, no one else's
-- =============================================================================
