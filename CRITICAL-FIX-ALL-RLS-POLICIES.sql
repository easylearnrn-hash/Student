-- ========================================
-- CRITICAL: FIX ALL OVERLAPPING RLS POLICIES
-- ========================================
-- This script will clean up ALL tables with overlapping/conflicting policies

-- ============================================================
-- STEP 1: DISABLE RLS TEMPORARILY ON KEY TABLES (FOR TESTING)
-- ============================================================
ALTER TABLE students DISABLE ROW LEVEL SECURITY;
ALTER TABLE payment_records DISABLE ROW LEVEL SECURITY;
ALTER TABLE payments DISABLE ROW LEVEL SECURITY;
ALTER TABLE credit_payments DISABLE ROW LEVEL SECURITY;
ALTER TABLE student_notes DISABLE ROW LEVEL SECURITY;
ALTER TABLE note_folders DISABLE ROW LEVEL SECURITY;

-- ============================================================
-- STEP 2: DROP ALL EXISTING POLICIES ON STUDENTS TABLE
-- ============================================================
DROP POLICY IF EXISTS "students_admin_all" ON students;
DROP POLICY IF EXISTS "Students can view own profile" ON students;
DROP POLICY IF EXISTS "Students can view own record" ON students;
DROP POLICY IF EXISTS "Admins can manage students" ON students;
DROP POLICY IF EXISTS "Admins can view all students" ON students;
DROP POLICY IF EXISTS "students_update_admin_or_self" ON students;
DROP POLICY IF EXISTS "students_insert_admin_only" ON students;
DROP POLICY IF EXISTS "students_delete_admin_only" ON students;
DROP POLICY IF EXISTS "students_select_admin_or_self" ON students;

-- ============================================================
-- STEP 3: DROP ALL POLICIES ON OTHER TABLES
-- ============================================================

-- Payment Records
DROP POLICY IF EXISTS "payment_records_admin_all" ON payment_records;
DROP POLICY IF EXISTS "Admin full access to payment_records" ON payment_records;

-- Payments
DROP POLICY IF EXISTS "payments_admin_all" ON payments;
DROP POLICY IF EXISTS "Admin full access to payments" ON payments;

-- Credit Payments
DROP POLICY IF EXISTS "credit_payments_admin_all" ON credit_payments;
DROP POLICY IF EXISTS "Admin full access to credit_payments" ON credit_payments;

-- Student Notes
DROP POLICY IF EXISTS "student_notes_admin_all" ON student_notes;
DROP POLICY IF EXISTS "Admin full access to student_notes" ON student_notes;

-- Note Folders
DROP POLICY IF EXISTS "note_folders_admin_all" ON note_folders;
DROP POLICY IF EXISTS "Admin full access to note_folders" ON note_folders;

-- ============================================================
-- STEP 4: CREATE SIMPLE, NON-CONFLICTING POLICIES
-- ============================================================

-- RE-ENABLE RLS
ALTER TABLE students ENABLE ROW LEVEL SECURITY;
ALTER TABLE payment_records ENABLE ROW LEVEL SECURITY;
ALTER TABLE payments ENABLE ROW LEVEL SECURITY;
ALTER TABLE credit_payments ENABLE ROW LEVEL SECURITY;
ALTER TABLE student_notes ENABLE ROW LEVEL SECURITY;
ALTER TABLE note_folders ENABLE ROW LEVEL SECURITY;

-- Students Table: Admin full access
CREATE POLICY "admin_all_students"
ON students
FOR ALL
TO authenticated
USING (
  EXISTS (SELECT 1 FROM admin_accounts WHERE auth_user_id = auth.uid())
)
WITH CHECK (
  EXISTS (SELECT 1 FROM admin_accounts WHERE auth_user_id = auth.uid())
);

-- Payment Records: Admin full access
CREATE POLICY "admin_all_payment_records"
ON payment_records
FOR ALL
TO authenticated
USING (
  EXISTS (SELECT 1 FROM admin_accounts WHERE auth_user_id = auth.uid())
)
WITH CHECK (
  EXISTS (SELECT 1 FROM admin_accounts WHERE auth_user_id = auth.uid())
);

-- Payments: Admin full access
CREATE POLICY "admin_all_payments"
ON payments
FOR ALL
TO authenticated
USING (
  EXISTS (SELECT 1 FROM admin_accounts WHERE auth_user_id = auth.uid())
)
WITH CHECK (
  EXISTS (SELECT 1 FROM admin_accounts WHERE auth_user_id = auth.uid())
);

-- Credit Payments: Admin full access
CREATE POLICY "admin_all_credit_payments"
ON credit_payments
FOR ALL
TO authenticated
USING (
  EXISTS (SELECT 1 FROM admin_accounts WHERE auth_user_id = auth.uid())
)
WITH CHECK (
  EXISTS (SELECT 1 FROM admin_accounts WHERE auth_user_id = auth.uid())
);

-- Student Notes: Admin full access
CREATE POLICY "admin_all_student_notes"
ON student_notes
FOR ALL
TO authenticated
USING (
  EXISTS (SELECT 1 FROM admin_accounts WHERE auth_user_id = auth.uid())
)
WITH CHECK (
  EXISTS (SELECT 1 FROM admin_accounts WHERE auth_user_id = auth.uid())
);

-- Note Folders: Admin full access
CREATE POLICY "admin_all_note_folders"
ON note_folders
FOR ALL
TO authenticated
USING (
  EXISTS (SELECT 1 FROM admin_accounts WHERE auth_user_id = auth.uid())
)
WITH CHECK (
  EXISTS (SELECT 1 FROM admin_accounts WHERE auth_user_id = auth.uid())
);

-- ============================================================
-- STEP 5: VERIFY CLEAN STATE
-- ============================================================

-- Check students table policies
SELECT 
  tablename,
  policyname,
  cmd,
  qual::text
FROM pg_policies 
WHERE tablename IN ('students', 'payment_records', 'payments', 'credit_payments', 'student_notes', 'note_folders')
ORDER BY tablename, cmd;

-- Expected: Only ONE policy per table, all named "admin_all_[tablename]"

-- ============================================================
-- STEP 6: VERIFY YOUR ADMIN ACCOUNT
-- ============================================================

-- Check admin_accounts table
SELECT * FROM admin_accounts;

-- Check your current user (run in browser console):
/*
const { data: { user } } = await supabase.auth.getUser();
console.log('My User ID:', user.id);
console.log('My Email:', user.email);
*/

-- If your user ID is not in admin_accounts, add it:
-- (Replace with YOUR actual UUID and email from browser console)
/*
INSERT INTO admin_accounts (auth_user_id, email)
VALUES ('YOUR-USER-ID-FROM-BROWSER', 'your-email@gmail.com')
ON CONFLICT (auth_user_id) DO UPDATE SET email = EXCLUDED.email;
*/

-- ============================================================
-- DONE! Now test "Apply from Credit" button in Calendar
-- ============================================================
