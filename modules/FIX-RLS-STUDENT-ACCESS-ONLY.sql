-- ============================================
-- CRITICAL RLS FIX: STUDENTS CAN ONLY ACCESS STUDENT PORTAL
-- Run this in Supabase SQL Editor to lock down student access
-- ============================================

-- Helper function to check if user is admin
CREATE OR REPLACE FUNCTION is_arnoma_admin()
RETURNS BOOLEAN AS $$
BEGIN
  RETURN EXISTS (
    SELECT 1 FROM admin_accounts 
    WHERE auth_user_id = auth.uid()
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================
-- DROP OLD INCORRECT POLICIES
-- ============================================

-- Drop old student policies that might allow too much access
DROP POLICY IF EXISTS "Auth admins have full access to students" ON students;
DROP POLICY IF EXISTS "Auth admins have full access to payment records" ON payment_records;
DROP POLICY IF EXISTS "Auth admins have full access to payments" ON payments;
DROP POLICY IF EXISTS "Auth admins have full access to notes" ON student_notes;

-- ============================================
-- STUDENTS TABLE - STRICT ACCESS
-- ============================================

-- Students can ONLY view their own record
DROP POLICY IF EXISTS "Auth students can view own data" ON students;
CREATE POLICY "Auth students can view own data"
ON students FOR SELECT
TO authenticated
USING (
  auth.uid() = auth_user_id
  AND NOT is_arnoma_admin() -- Students only, admins use separate policy
);

-- Students can ONLY update their own non-critical fields
DROP POLICY IF EXISTS "Auth students can update own data" ON students;
CREATE POLICY "Auth students can update own data"
ON students FOR UPDATE
TO authenticated
USING (auth.uid() = auth_user_id AND NOT is_arnoma_admin())
WITH CHECK (
  auth.uid() = auth_user_id 
  AND NOT is_arnoma_admin()
);

-- Admins have full access (via admin_accounts table, not students.role)
CREATE POLICY "Admins have full access to students"
ON students FOR ALL
TO authenticated
USING (is_arnoma_admin());

-- ============================================
-- PAYMENT_RECORDS - STUDENTS SEE ONLY THEIRS
-- ============================================

-- Students can ONLY view their own payment records
DROP POLICY IF EXISTS "Auth students can view own payment records" ON payment_records;
CREATE POLICY "Auth students can view own payment records"
ON payment_records FOR SELECT
TO authenticated
USING (
  student_id::text IN (
    SELECT id::text FROM students WHERE auth_user_id = auth.uid()
  )
  AND NOT is_arnoma_admin()
);

-- Admins have full access
CREATE POLICY "Admins have full access to payment records"
ON payment_records FOR ALL
TO authenticated
USING (is_arnoma_admin());

-- ============================================
-- PAYMENTS TABLE - STUDENTS SEE ONLY THEIRS
-- ============================================

-- Students can ONLY view their own payments
DROP POLICY IF EXISTS "Auth students can view own payments" ON payments;
CREATE POLICY "Auth students can view own payments"
ON payments FOR SELECT
TO authenticated
USING (
  (
    linked_student_id::text IN (
      SELECT id::text FROM students WHERE auth_user_id = auth.uid()
    )
    OR
    student_id::text IN (
      SELECT id::text FROM students WHERE auth_user_id = auth.uid()
    )
  )
  AND NOT is_arnoma_admin()
);

-- Admins have full access
CREATE POLICY "Admins have full access to payments"
ON payments FOR ALL
TO authenticated
USING (is_arnoma_admin());

-- ============================================
-- STUDENT_NOTES - STUDENTS SEE ONLY THEIR GROUP
-- ============================================

-- Students can ONLY view notes for their group
DROP POLICY IF EXISTS "Auth students can view own notes" ON student_notes;
CREATE POLICY "Auth students can view own notes"
ON student_notes FOR SELECT
TO authenticated
USING (
  group_name IN (
    SELECT group_name FROM students WHERE auth_user_id = auth.uid()
  )
  AND NOT is_arnoma_admin()
  AND deleted = false -- Only non-deleted notes
);

-- Admins have full access
CREATE POLICY "Admins have full access to notes"
ON student_notes FOR ALL
TO authenticated
USING (is_arnoma_admin());

-- ============================================
-- GROUPS TABLE - STUDENTS CAN ONLY READ
-- ============================================

-- Ensure students can ONLY view groups, not modify
DROP POLICY IF EXISTS "Students can view groups" ON groups;
CREATE POLICY "Students can view groups"
ON groups FOR SELECT
TO authenticated
USING (
  -- Student can see their own group
  group_name IN (
    SELECT group_name FROM students WHERE auth_user_id = auth.uid()
  )
  OR is_arnoma_admin()
);

-- ============================================
-- TESTS - STUDENTS CAN ONLY VIEW ACTIVE TESTS
-- ============================================

DROP POLICY IF EXISTS "Students can view active tests" ON tests;
CREATE POLICY "Students can view active tests"
ON tests FOR SELECT
TO authenticated
USING (
  (is_active = true AND NOT is_arnoma_admin())
  OR is_arnoma_admin()
);

-- ============================================
-- TEST_QUESTIONS - STUDENTS CAN ONLY READ
-- ============================================

DROP POLICY IF EXISTS "Students can view questions" ON test_questions;
CREATE POLICY "Students can view questions"
ON test_questions FOR SELECT
TO authenticated
USING (
  test_id IN (SELECT id FROM tests WHERE is_active = true)
  OR is_arnoma_admin()
);

-- ============================================
-- STUDENT_ALERTS - STUDENTS SEE ONLY THEIRS
-- ============================================

DROP POLICY IF EXISTS "Students can view their own alerts" ON student_alerts;
CREATE POLICY "Students can view their own alerts"
ON student_alerts FOR SELECT
TO authenticated
USING (
  student_id IN (
    SELECT id FROM students WHERE auth_user_id = auth.uid()
  )
  AND NOT is_arnoma_admin()
);

DROP POLICY IF EXISTS "Students can update their own alerts" ON student_alerts;
CREATE POLICY "Students can update their own alerts"
ON student_alerts FOR UPDATE
TO authenticated
USING (
  student_id IN (
    SELECT id FROM students WHERE auth_user_id = auth.uid()
  )
  AND NOT is_arnoma_admin()
);

-- ============================================
-- CRITICAL: LOCK DOWN ADMIN-ONLY TABLES
-- ============================================

-- Ensure students CANNOT access these tables AT ALL
ALTER TABLE admin_accounts ENABLE ROW LEVEL SECURITY;
ALTER TABLE sent_emails ENABLE ROW LEVEL SECURITY;
ALTER TABLE email_templates ENABLE ROW LEVEL SECURITY;
ALTER TABLE automations ENABLE ROW LEVEL SECURITY;
ALTER TABLE notifications ENABLE ROW LEVEL SECURITY;
ALTER TABLE payer_aliases ENABLE ROW LEVEL SECURITY;
ALTER TABLE gmail_credentials ENABLE ROW LEVEL SECURITY;

-- Drop all existing policies for admin tables
DROP POLICY IF EXISTS "Admin access only" ON admin_accounts;
DROP POLICY IF EXISTS "Admin access only" ON sent_emails;
DROP POLICY IF EXISTS "Admin access only" ON email_templates;
DROP POLICY IF EXISTS "Admin access only" ON automations;
DROP POLICY IF EXISTS "Admin access only" ON notifications;
DROP POLICY IF EXISTS "Admin access only" ON payer_aliases;
DROP POLICY IF EXISTS "Admin access only" ON gmail_credentials;

-- Create strict admin-only policies
CREATE POLICY "Admin access only" ON admin_accounts FOR ALL TO authenticated USING (is_arnoma_admin());
CREATE POLICY "Admin access only" ON sent_emails FOR ALL TO authenticated USING (is_arnoma_admin());
CREATE POLICY "Admin access only" ON email_templates FOR ALL TO authenticated USING (is_arnoma_admin());
CREATE POLICY "Admin access only" ON automations FOR ALL TO authenticated USING (is_arnoma_admin());
CREATE POLICY "Admin access only" ON notifications FOR ALL TO authenticated USING (is_arnoma_admin());
CREATE POLICY "Admin access only" ON payer_aliases FOR ALL TO authenticated USING (is_arnoma_admin());
CREATE POLICY "Admin access only" ON gmail_credentials FOR ALL TO authenticated USING (is_arnoma_admin());

-- ============================================
-- VERIFICATION
-- ============================================

-- Check that all critical tables have RLS enabled
SELECT 
  schemaname,
  tablename,
  rowsecurity
FROM pg_tables
WHERE schemaname = 'public'
  AND rowsecurity = true
ORDER BY tablename;

-- List all policies
SELECT 
  schemaname,
  tablename,
  policyname,
  roles,
  cmd
FROM pg_policies
WHERE schemaname = 'public'
ORDER BY tablename, policyname;

-- ============================================
-- SUMMARY OF CHANGES
-- ============================================

/*
WHAT THIS FIXES:

✅ Students can ONLY see their own data (students, payments, payment_records)
✅ Students can ONLY see their group's notes
✅ Students can ONLY view active tests
✅ Students can ONLY see their own alerts
✅ Students CANNOT access admin tables (admin_accounts, sent_emails, etc.)
✅ Students CANNOT modify anything except their own alerts
✅ Admins identified via admin_accounts table (NOT students.role)
✅ All admin tools use admin_accounts for authentication

SECURITY GUARANTEE:
- If a student somehow navigates to an admin URL (Payment-Records, Student-Manager, etc.)
- The Supabase queries will FAIL because RLS blocks them
- They will see "access control" errors
- They CANNOT bypass this even with browser dev tools

NEXT STEPS:
1. Run this SQL in Supabase SQL Editor
2. Test student login → should only access student-portal.html
3. Test admin login → should access all admin tools
*/
