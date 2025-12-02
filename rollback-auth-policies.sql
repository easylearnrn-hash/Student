-- ============================================
-- ROLLBACK AUTH POLICIES - RESTORE APP ACCESS
-- Run this to remove the auth-based policies that are blocking your app
-- ============================================

-- Drop auth-based policies from STUDENTS table
DROP POLICY IF EXISTS "Auth students can view own data" ON students;
DROP POLICY IF EXISTS "Auth students can update own data" ON students;
DROP POLICY IF EXISTS "Auth admins have full access to students" ON students;

-- Drop auth-based policies from PAYMENT_RECORDS table
DROP POLICY IF EXISTS "Auth students can view own payment records" ON payment_records;
DROP POLICY IF EXISTS "Auth admins have full access to payment records" ON payment_records;

-- Drop auth-based policies from PAYMENTS table
DROP POLICY IF EXISTS "Auth students can view own payments" ON payments;
DROP POLICY IF EXISTS "Auth admins have full access to payments" ON payments;

-- Drop auth-based policies from STUDENT_NOTES table
DROP POLICY IF EXISTS "Auth students can view own notes" ON student_notes;
DROP POLICY IF EXISTS "Auth admins have full access to notes" ON student_notes;

-- ============================================
-- VERIFICATION
-- ============================================

-- Check remaining policies
SELECT 
  tablename,
  policyname,
  roles
FROM pg_policies
WHERE schemaname = 'public'
  AND tablename IN ('students', 'payment_records', 'payments', 'student_notes')
ORDER BY tablename, policyname;
