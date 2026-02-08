-- ============================================
-- EMERGENCY RLS LOCKDOWN
-- DROP ALL WEAK PUBLIC/ANON POLICIES IMMEDIATELY
-- ============================================

-- This script removes all insecure policies that allow public/anon access
-- to admin data and replaces them with strict student/admin separation

BEGIN;

-- ============================================
-- STEP 1: DROP ALL WEAK PUBLIC POLICIES
-- ============================================

-- Payment tables - NO PUBLIC ACCESS
DROP POLICY IF EXISTS "payment_records_select_policy" ON payment_records;
DROP POLICY IF EXISTS "payment_records_insert_policy" ON payment_records;
DROP POLICY IF EXISTS "payment_records_update_policy" ON payment_records;
DROP POLICY IF EXISTS "payment_records_delete_policy" ON payment_records;

DROP POLICY IF EXISTS "payments_select_policy" ON payments;
DROP POLICY IF EXISTS "payments_insert_policy" ON payments;
DROP POLICY IF EXISTS "payments_update_policy" ON payments;
DROP POLICY IF EXISTS "payments_delete_policy" ON payments;

-- Students table - NO ANON/PUBLIC READ ALL
DROP POLICY IF EXISTS "Public can read students" ON students;
DROP POLICY IF EXISTS "Public can insert students" ON students;
DROP POLICY IF EXISTS "Public can update students" ON students;

-- Admin tables - NO PUBLIC ACCESS
DROP POLICY IF EXISTS "Allow all operations on sent_emails" ON sent_emails;
DROP POLICY IF EXISTS "Allow all operations on email_templates" ON email_templates;
DROP POLICY IF EXISTS "Allow all operations on automations" ON automations;
DROP POLICY IF EXISTS "Allow all operations on test_email_addresses" ON test_email_addresses;

-- ============================================
-- STEP 2: CREATE HELPER FUNCTION
-- ============================================

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
-- STEP 3: SECURE STUDENTS TABLE
-- ============================================

-- Drop existing policies first
DROP POLICY IF EXISTS "Auth students can view own data" ON students;
DROP POLICY IF EXISTS "Auth students can update own data" ON students;
DROP POLICY IF EXISTS "Admins have full access to students" ON students;

-- Students can ONLY view their own record
CREATE POLICY "Auth students can view own data"
ON students FOR SELECT
TO authenticated
USING (
  auth.uid() = auth_user_id
  AND NOT is_arnoma_admin()
);

-- Students can ONLY update their own non-critical fields
CREATE POLICY "Auth students can update own data"
ON students FOR UPDATE
TO authenticated
USING (auth.uid() = auth_user_id AND NOT is_arnoma_admin())
WITH CHECK (auth.uid() = auth_user_id AND NOT is_arnoma_admin());

-- Admins have full access
CREATE POLICY "Admins have full access to students"
ON students FOR ALL
TO authenticated
USING (is_arnoma_admin());

-- ============================================
-- STEP 4: SECURE PAYMENT_RECORDS
-- ============================================

-- Drop existing policies first
DROP POLICY IF EXISTS "Auth students can view own payment records" ON payment_records;
DROP POLICY IF EXISTS "Admins have full access to payment records" ON payment_records;

-- Students can ONLY view their own payment records
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
-- STEP 5: SECURE PAYMENTS TABLE
-- ============================================

-- Drop existing policies first
DROP POLICY IF EXISTS "Auth students can view own payments" ON payments;
DROP POLICY IF EXISTS "Admins have full access to payments" ON payments;

-- Students can ONLY view their own payments
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
-- STEP 6: LOCK DOWN ADMIN TABLES
-- ============================================

-- Drop ALL existing admin table policies first
DROP POLICY IF EXISTS "Admin access only" ON sent_emails;
DROP POLICY IF EXISTS "Allow all operations on sent_emails" ON sent_emails;
DROP POLICY IF EXISTS "Allow test suite access to sent_emails" ON sent_emails;

DROP POLICY IF EXISTS "Admin access only" ON email_templates;
DROP POLICY IF EXISTS "Allow all operations on email_templates" ON email_templates;

DROP POLICY IF EXISTS "Admin access only" ON automations;
DROP POLICY IF EXISTS "Allow all operations on automations" ON automations;

DROP POLICY IF EXISTS "Admin access only" ON test_email_addresses;
DROP POLICY IF EXISTS "Allow all operations on test_email_addresses" ON test_email_addresses;

DROP POLICY IF EXISTS "Admin access only" ON notifications;
DROP POLICY IF EXISTS "auth_only_notifications" ON notifications;
DROP POLICY IF EXISTS "Allow test suite access to notifications" ON notifications;

DROP POLICY IF EXISTS "Admin access only" ON payer_aliases;
DROP POLICY IF EXISTS "Allow all for authenticated" ON payer_aliases;
DROP POLICY IF EXISTS "Allow all operations for authenticated users" ON payer_aliases;
DROP POLICY IF EXISTS "Allow read for anon" ON payer_aliases;
DROP POLICY IF EXISTS "Allow read for anon users" ON payer_aliases;

DROP POLICY IF EXISTS "Admin access only" ON gmail_credentials;
DROP POLICY IF EXISTS "auth_only_gmail_credentials" ON gmail_credentials;

DROP POLICY IF EXISTS "Admins can manage manual payment moves" ON manual_payment_moves;
DROP POLICY IF EXISTS "Admins can create manual payment moves" ON manual_payment_moves;
DROP POLICY IF EXISTS "Admins can delete manual payment moves" ON manual_payment_moves;
DROP POLICY IF EXISTS "Admins can view all manual payment moves" ON manual_payment_moves;
DROP POLICY IF EXISTS "Anonymous users cannot access manual payment moves" ON manual_payment_moves;

-- Now create clean admin-only policies
-- Sent emails - admin only
CREATE POLICY "Admin access only" ON sent_emails
FOR ALL TO authenticated
USING (is_arnoma_admin());

-- Email templates - admin only
CREATE POLICY "Admin access only" ON email_templates
FOR ALL TO authenticated
USING (is_arnoma_admin());

-- Automations - admin only
CREATE POLICY "Admin access only" ON automations
FOR ALL TO authenticated
USING (is_arnoma_admin());

-- Test email addresses - admin only
CREATE POLICY "Admin access only" ON test_email_addresses
FOR ALL TO authenticated
USING (is_arnoma_admin());

-- Notifications - admin only
CREATE POLICY "Admin access only" ON notifications
FOR ALL TO authenticated
USING (is_arnoma_admin());

-- Payer aliases - admin only
CREATE POLICY "Admin access only" ON payer_aliases
FOR ALL TO authenticated
USING (is_arnoma_admin());

-- Gmail credentials - admin only
CREATE POLICY "Admin access only" ON gmail_credentials
FOR ALL TO authenticated
USING (is_arnoma_admin());

-- Manual payment moves - admin only
CREATE POLICY "Admins can manage manual payment moves"
ON manual_payment_moves FOR ALL
TO authenticated
USING (is_arnoma_admin());

-- ============================================
-- STEP 7: SECURE STUDENT_NOTES
-- ============================================

-- Drop ALL existing policies
DROP POLICY IF EXISTS "allow_anon_read_non_deleted" ON student_notes;
DROP POLICY IF EXISTS "Admin full access to notes" ON student_notes;
DROP POLICY IF EXISTS "Auth students can view own notes" ON student_notes;
DROP POLICY IF EXISTS "Admins have full access to notes" ON student_notes;

-- Students can ONLY view notes for their group
CREATE POLICY "Auth students can view own notes"
ON student_notes FOR SELECT
TO authenticated
USING (
  group_name IN (
    SELECT group_name FROM students WHERE auth_user_id = auth.uid()
  )
  AND NOT is_arnoma_admin()
  AND deleted = false
);

-- Admins have full access
CREATE POLICY "Admins have full access to notes"
ON student_notes FOR ALL
TO authenticated
USING (is_arnoma_admin());

-- ============================================
-- STEP 8: VERIFY NO ANON/PUBLIC POLICIES REMAIN
-- ============================================

-- Check for remaining weak policies
SELECT 
  tablename,
  policyname,
  roles
FROM pg_policies
WHERE schemaname = 'public'
  AND (
    roles::text ILIKE '%anon%' 
    OR roles::text ILIKE '%public%'
  )
  AND tablename IN (
    'students',
    'payment_records', 
    'payments',
    'sent_emails',
    'email_templates',
    'automations',
    'admin_accounts',
    'payer_aliases',
    'gmail_credentials',
    'notifications',
    'manual_payment_moves'
  )
ORDER BY tablename;

-- This should return ZERO rows for critical admin tables!

COMMIT;

-- ============================================
-- VERIFICATION QUERIES
-- ============================================

-- Test 1: Check if admin function works
SELECT is_arnoma_admin(); -- Should return false if you're not admin

-- Test 2: List all policies on critical tables
SELECT 
  schemaname,
  tablename,
  policyname,
  roles,
  cmd
FROM pg_policies
WHERE schemaname = 'public'
  AND tablename IN ('students', 'payments', 'payment_records', 'sent_emails')
ORDER BY tablename, policyname;

-- Test 3: Verify RLS is enabled
SELECT 
  schemaname,
  tablename,
  rowsecurity
FROM pg_tables
WHERE schemaname = 'public'
  AND tablename IN ('students', 'payments', 'payment_records', 'sent_emails')
ORDER BY tablename;

-- ============================================
-- EXPECTED RESULTS AFTER FIX
-- ============================================

/*
STUDENTS TABLE should have:
- "Auth students can view own data" → authenticated → SELECT (with is_arnoma_admin() check)
- "Auth students can update own data" → authenticated → UPDATE (with is_arnoma_admin() check)
- "Admins have full access to students" → authenticated → ALL (admin only)

PAYMENTS TABLE should have:
- "Auth students can view own payments" → authenticated → SELECT (linked_student_id check)
- "Admins have full access to payments" → authenticated → ALL (admin only)

PAYMENT_RECORDS TABLE should have:
- "Auth students can view own payment records" → authenticated → SELECT (student_id check)
- "Admins have full access to payment records" → authenticated → ALL (admin only)

ADMIN TABLES should have ONLY:
- "Admin access only" → authenticated → ALL (admin only)

NO ANON OR PUBLIC POLICIES ON CRITICAL TABLES!
*/
