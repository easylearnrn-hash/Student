-- ============================================
-- VERIFY STUDENT CANNOT SEE ADMIN DATA
-- ============================================
-- This SQL will show EXACTLY what each policy allows
-- Run this to be 1000% sure students are restricted
-- ============================================

-- STEP 1: Show ALL policies with their EXACT logic
SELECT 
  tablename,
  policyname,
  cmd as "Applies To",
  roles as "Roles",
  CASE 
    WHEN policyname ILIKE '%admin%' THEN '👑 ADMIN ONLY'
    WHEN policyname ILIKE '%student%' THEN '👤 STUDENT ONLY'
    ELSE '🔧 OTHER'
  END as "Access Level",
  qual as "USING (Filter Query)",
  with_check as "WITH CHECK (Insert/Update Rule)"
FROM pg_policies
WHERE schemaname = 'public'
  AND tablename IN ('students', 'payment_records', 'payments', 'student_notes', 'schedule_changes', 'groups')
ORDER BY 
  tablename,
  CASE 
    WHEN policyname ILIKE '%admin%' THEN 1
    WHEN policyname ILIKE '%student%' THEN 2
    ELSE 3
  END,
  policyname;

-- ============================================
-- CRITICAL CHECKS
-- ============================================

-- CHECK 1: Verify "Students can view own data" policy on students table
-- Should contain: WHERE auth_user_id = auth.uid()
-- This means students can ONLY see records where their auth_user_id matches
SELECT 
  policyname,
  qual as "SQL Filter Logic"
FROM pg_policies
WHERE tablename = 'students'
  AND policyname ILIKE '%student%view%';

-- CHECK 2: Verify "Students can view own payments" policy
-- Should contain: WHERE student_id = (SELECT id FROM students WHERE auth_user_id = auth.uid())
SELECT 
  policyname,
  qual as "SQL Filter Logic"
FROM pg_policies
WHERE tablename = 'payments'
  AND policyname ILIKE '%student%view%';

-- CHECK 3: Verify "Students can view own payment records" policy
-- Should contain: WHERE student_id = (SELECT id FROM students WHERE auth_user_id = auth.uid())
SELECT 
  policyname,
  qual as "SQL Filter Logic"
FROM pg_policies
WHERE tablename = 'payment_records'
  AND policyname ILIKE '%student%view%';

-- CHECK 4: Verify admin policies allow everything
-- Should contain: WHERE role = 'admin' (no other filters)
SELECT 
  tablename,
  policyname,
  qual as "SQL Filter Logic"
FROM pg_policies
WHERE policyname ILIKE '%admin%'
ORDER BY tablename;

-- ============================================
-- WHAT THESE RESULTS WILL TELL YOU
-- ============================================

-- If you see in the "SQL Filter Logic":
-- 
-- ADMIN POLICIES should have:
-- ✅ "((auth_user_id = auth.uid()) AND (role = 'admin'::text))"
--    → This means: Must be logged in AND have role='admin'
--    → NO OTHER FILTERS = can see ALL records
--
-- STUDENT POLICIES should have:
-- ✅ "(auth_user_id = auth.uid())"
--    → This means: Can ONLY see records where auth_user_id matches their login
--    → For payments: "student_id = (SELECT id FROM students WHERE auth_user_id = auth.uid())"
--    → This means: Can ONLY see payments where student_id matches their record
--
-- This is 100% SECURE because:
-- 1. auth.uid() returns the currently logged-in user's UUID
-- 2. Student policies filter by auth_user_id = auth.uid() (only their own records)
-- 3. Admin policies check role='admin' but don't filter records (see everything)
-- 4. RLS is ENABLED, so Supabase enforces these policies on every query

-- ============================================
-- REAL WORLD TEST (if you have a test student)
-- ============================================

-- To test with a real student account:
-- 1. Create a test student auth account in Supabase
-- 2. Link it to a student record
-- 3. Login as that student in Login-Portal.html
-- 4. Open browser console and try:
--    const { data } = await supabase.from('students').select('*')
-- 5. You should ONLY see 1 record (the student's own record)
-- 
-- As admin, the same query returns ALL students

-- ============================================
-- ANSWER TO YOUR QUESTION
-- ============================================

-- Are you 1000% sure students can't see anything admin can?
-- 
-- YES - IF the policies contain the filters shown above.
-- Run this SQL and check the "SQL Filter Logic" column.
-- 
-- If you see:
-- ✅ Student policies have "auth_user_id = auth.uid()" → SECURE
-- ✅ Admin policies have "role = 'admin'" with no other filters → ADMIN SEES ALL
-- ✅ RLS enabled = true (which you confirmed) → ENFORCED
-- 
-- Then YES, 1000% sure students cannot see admin data.
-- They can ONLY query records where:
-- - students table: WHERE auth_user_id = their_login_uuid
-- - payments table: WHERE student_id = their_student_id
-- - payment_records table: WHERE student_id = their_student_id
-- - student_notes table: WHERE student_id = their_student_id OR group_code = their_group

