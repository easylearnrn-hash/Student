-- Fix RLS policies for 'payments' table (Zelle payments)
-- Current issue: 403 error when admin tries to access

-- 1. Check current policies on payments table
SELECT schemaname, tablename, policyname, permissive, roles, cmd, qual
FROM pg_policies 
WHERE tablename = 'payments';

-- 2. Check column types in payments table
SELECT column_name, data_type 
FROM information_schema.columns 
WHERE table_name = 'payments' 
  AND column_name IN ('linked_student_id', 'student_id', 'resolved_student_name');

-- 3. Check column types in students table
SELECT column_name, data_type 
FROM information_schema.columns 
WHERE table_name = 'students' 
  AND column_name IN ('id', 'auth_user_id', 'student_name');

-- 4. Drop existing restrictive policies if any
DROP POLICY IF EXISTS "Students can view their own payments" ON payments;
DROP POLICY IF EXISTS "Enable read access for authenticated users" ON payments;
DROP POLICY IF EXISTS "Admin and student access to payments" ON payments;

-- 5. Create SIMPLE admin-only policy first (to fix 403 immediately)
CREATE POLICY "Admin can view all payments"
ON payments
FOR SELECT
USING (
  EXISTS (
    SELECT 1 
    FROM admin_accounts 
    WHERE admin_accounts.email = auth.jwt() ->> 'email'
  )
);

-- 6. Verify the policy was created
SELECT schemaname, tablename, policyname, permissive, roles, cmd, qual
FROM pg_policies 
WHERE tablename = 'payments';
