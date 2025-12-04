-- Clean up all conflicting policies on payments table
-- Keep only the working admin access policy

-- 1. Drop ALL existing policies
DROP POLICY IF EXISTS "Admin can view all payments" ON payments;
DROP POLICY IF EXISTS "payments_select_admin_or_owner" ON payments;
DROP POLICY IF EXISTS "payments_write_admin_only" ON payments;
DROP POLICY IF EXISTS "Admin and student payment access" ON payments;
DROP POLICY IF EXISTS "Students can view their own payments" ON payments;
DROP POLICY IF EXISTS "Enable read access for authenticated users" ON payments;

-- 2. Create ONE clean policy for admin access (fixes 403 error immediately)
CREATE POLICY "admin_full_access_payments"
ON payments
FOR ALL
USING (
  EXISTS (
    SELECT 1 
    FROM admin_accounts 
    WHERE admin_accounts.email = auth.jwt() ->> 'email'
  )
);

-- 3. Create ONE clean policy for student access (using existing function)
CREATE POLICY "students_view_own_payments"
ON payments
FOR SELECT
USING (
  is_arnoma_admin() OR
  linked_student_id::text IN (
    SELECT id::text 
    FROM students 
    WHERE auth_user_id::text = auth.uid()::text
  )
);

-- 4. Verify only 2 policies exist now
SELECT schemaname, tablename, policyname, permissive, roles, cmd
FROM pg_policies 
WHERE tablename = 'payments'
ORDER BY policyname;
