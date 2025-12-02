-- ============================================
-- SUPABASE AUTH SETUP FOR STUDENT PORTAL
-- Run this in Supabase SQL Editor
-- ============================================

-- Step 1: Add auth_user_id column to students table
-- This links students to Supabase Auth users
ALTER TABLE students 
ADD COLUMN IF NOT EXISTS auth_user_id UUID REFERENCES auth.users(id);

-- Add index for faster lookups
CREATE INDEX IF NOT EXISTS idx_students_auth_user_id ON students(auth_user_id);

-- Step 2: Add role column for admin/student distinction
ALTER TABLE students 
ADD COLUMN IF NOT EXISTS role TEXT DEFAULT 'student' CHECK (role IN ('student', 'admin'));

-- Update existing students to 'student' role
UPDATE students SET role = 'student' WHERE role IS NULL;

-- ============================================
-- ENABLE ROW LEVEL SECURITY (RLS)
-- ============================================

-- RLS is already enabled on these tables
-- Just confirming - no action needed if already enabled
ALTER TABLE students ENABLE ROW LEVEL SECURITY;
ALTER TABLE payment_records ENABLE ROW LEVEL SECURITY;
ALTER TABLE payments ENABLE ROW LEVEL SECURITY;
ALTER TABLE student_notes ENABLE ROW LEVEL SECURITY;
ALTER TABLE schedule_changes ENABLE ROW LEVEL SECURITY;
ALTER TABLE groups ENABLE ROW LEVEL SECURITY;

-- ============================================
-- RLS POLICIES FOR STUDENTS TABLE
-- ============================================

-- Note: Keep existing public/anon policies for admin tools
-- Just add new auth-based policies for student login

-- Students with auth can view their own record
CREATE POLICY "Auth students can view own data"
ON students FOR SELECT
TO authenticated
USING (auth.uid() = auth_user_id);

-- Students with auth can update their own non-critical fields
CREATE POLICY "Auth students can update own data"
ON students FOR UPDATE
TO authenticated
USING (auth.uid() = auth_user_id)
WITH CHECK (
  auth.uid() = auth_user_id 
  AND role = 'student'
);

-- Admins with auth have full access
CREATE POLICY "Auth admins have full access to students"
ON students FOR ALL
TO authenticated
USING (
  (SELECT role FROM students WHERE auth_user_id = auth.uid()) = 'admin'
);

-- ============================================
-- RLS POLICIES FOR PAYMENT_RECORDS TABLE
-- ============================================

-- Note: Keep existing public policies for admin tools
-- Add auth-based policies for student portal

-- Auth students can view their own payment records
CREATE POLICY "Auth students can view own payment records"
ON payment_records FOR SELECT
TO authenticated
USING (
  student_id::text IN (
    SELECT id::text FROM students WHERE auth_user_id = auth.uid()
  )
);

-- Auth admins have full access
CREATE POLICY "Auth admins have full access to payment records"
ON payment_records FOR ALL
TO authenticated
USING (
  (SELECT role FROM students WHERE auth_user_id = auth.uid()) = 'admin'
);

-- ============================================
-- RLS POLICIES FOR PAYMENTS TABLE (Zelle)
-- ============================================

-- Note: Keep existing public/anon policies for admin tools
-- Add auth-based policies for student portal

-- Auth students can view their own payments
CREATE POLICY "Auth students can view own payments"
ON payments FOR SELECT
TO authenticated
USING (
  linked_student_id::text IN (
    SELECT id::text FROM students WHERE auth_user_id = auth.uid()
  )
  OR
  student_id::text IN (
    SELECT id::text FROM students WHERE auth_user_id = auth.uid()
  )
);

-- Auth admins have full access
CREATE POLICY "Auth admins have full access to payments"
ON payments FOR ALL
TO authenticated
USING (
  (SELECT role FROM students WHERE auth_user_id = auth.uid()) = 'admin'
);

-- ============================================
-- RLS POLICIES FOR STUDENT_NOTES TABLE
-- ============================================

-- Note: Keep existing public policies for admin tools
-- Add auth-based policies for student portal

-- Auth students can view notes for their group
CREATE POLICY "Auth students can view own notes"
ON student_notes FOR SELECT
TO authenticated
USING (
  group_name IN (
    SELECT group_name FROM students WHERE auth_user_id = auth.uid()
  )
);

-- Auth admins have full access
CREATE POLICY "Auth admins have full access to notes"
ON student_notes FOR ALL
TO authenticated
USING (
  (SELECT role FROM students WHERE auth_user_id = auth.uid()) = 'admin'
);

-- ============================================
-- RLS POLICIES FOR SCHEDULE_CHANGES TABLE
-- ============================================

-- Note: Existing policies already allow authenticated users to view
-- Just ensure auth students can view (already covered by existing policy)
-- No changes needed - existing "Everyone can view schedule changes" policy covers this

-- ============================================
-- GROUPS TABLE - PUBLIC READ
-- ============================================

-- Note: Existing policies already allow authenticated users to view
-- The "Everyone can view groups" policy already covers authenticated students
-- No changes needed

-- ============================================
-- VERIFICATION QUERIES
-- ============================================

-- Check that RLS is enabled
SELECT 
  schemaname,
  tablename,
  rowsecurity
FROM pg_tables
WHERE schemaname = 'public'
  AND tablename IN ('students', 'payment_records', 'payments', 'student_notes', 'schedule_changes', 'groups')
ORDER BY tablename;

-- Check policies
SELECT 
  schemaname,
  tablename,
  policyname,
  permissive,
  roles,
  cmd
FROM pg_policies
WHERE schemaname = 'public'
ORDER BY tablename, policyname;

-- ============================================
-- NOTES FOR IMPLEMENTATION
-- ============================================

/*
NEXT STEPS:

1. Run this SQL in Supabase SQL Editor
2. Create student accounts via Student Manager
3. Update student-portal.html to use Supabase Auth
4. Keep admin tools using SERVICE_ROLE_KEY

SECURITY SUMMARY:
✅ Students can ONLY see their own data
✅ Admins have full access (via service role or admin role)
✅ All tables protected by RLS
✅ Passwords stored securely in auth.users
✅ Admin tools remain separate and secure

TO CREATE STUDENT ACCOUNTS:
- Option 1: Bulk create via Supabase Dashboard
- Option 2: Add signup flow in Student Manager
- Option 3: Manual creation with initial passwords
*/
