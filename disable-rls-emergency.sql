-- ============================================
-- EMERGENCY: DISABLE RLS TO RESTORE APP ACCESS
-- Run this IMMEDIATELY to restore your app
-- ============================================

-- Disable RLS on all tables that might be blocking access
ALTER TABLE students DISABLE ROW LEVEL SECURITY;
ALTER TABLE payment_records DISABLE ROW LEVEL SECURITY;
ALTER TABLE payments DISABLE ROW LEVEL SECURITY;
ALTER TABLE student_notes DISABLE ROW LEVEL SECURITY;
ALTER TABLE schedule_changes DISABLE ROW LEVEL SECURITY;
ALTER TABLE groups DISABLE ROW LEVEL SECURITY;

-- Drop ALL auth-based policies to clean up
DROP POLICY IF EXISTS "Auth students can view own data" ON students;
DROP POLICY IF EXISTS "Auth students can update own data" ON students;
DROP POLICY IF EXISTS "Auth admins have full access to students" ON students;
DROP POLICY IF EXISTS "Auth students can view own payment records" ON payment_records;
DROP POLICY IF EXISTS "Auth admins have full access to payment records" ON payment_records;
DROP POLICY IF EXISTS "Auth students can view own payments" ON payments;
DROP POLICY IF EXISTS "Auth admins have full access to payments" ON payments;
DROP POLICY IF EXISTS "Auth students can view own notes" ON student_notes;
DROP POLICY IF EXISTS "Auth admins have full access to notes" ON student_notes;

-- ============================================
-- VERIFICATION
-- ============================================

-- Check RLS is disabled
SELECT 
  schemaname,
  tablename,
  rowsecurity
FROM pg_tables
WHERE schemaname = 'public'
  AND tablename IN ('students', 'payment_records', 'payments', 'student_notes', 'schedule_changes', 'groups')
ORDER BY tablename;

-- Should show rowsecurity = false for all tables
