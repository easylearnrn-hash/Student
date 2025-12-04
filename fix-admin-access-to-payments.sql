-- ============================================================
-- FIX ADMIN ACCESS TO PAYMENT TABLES
-- ============================================================
-- This ensures admins can view all payments while students can only see their own

-- 1. First, ensure your admin account exists in admin_accounts table
-- Get your auth_user_id from auth.users and insert into admin_accounts
INSERT INTO admin_accounts (email, auth_user_id)
SELECT 'hrachfilm@gmail.com', id
FROM auth.users
WHERE email = 'hrachfilm@gmail.com'
ON CONFLICT (email) DO NOTHING;

-- 2. Drop any existing conflicting policies
DROP POLICY IF EXISTS "Admins can view all payments" ON payments;
DROP POLICY IF EXISTS "Admins can view all payment_records" ON payment_records;
DROP POLICY IF EXISTS "Students can view linked payments" ON payments;
DROP POLICY IF EXISTS "Students can view own payment records" ON payment_records;

-- 3. Create comprehensive policy for PAYMENTS table (Zelle payments)
CREATE POLICY "Admin and student payment access" ON payments
  FOR SELECT
  USING (
    -- Admins can see everything
    EXISTS (
      SELECT 1 FROM admin_accounts 
      WHERE email = (SELECT email FROM auth.users WHERE id = auth.uid())
    )
    OR
    -- Students can see payments linked to them
    linked_student_id IN (
      SELECT id::text FROM students WHERE auth_user_id::text = auth.uid()::text
    )
  );

-- 4. Create comprehensive policy for PAYMENT_RECORDS table (Manual payments)
CREATE POLICY "Admin and student payment_records access" ON payment_records
  FOR SELECT
  USING (
    -- Admins can see everything
    EXISTS (
      SELECT 1 FROM admin_accounts 
      WHERE email = (SELECT email FROM auth.users WHERE id = auth.uid())
    )
    OR
    -- Students can see their own records
    student_id IN (
      SELECT id FROM students WHERE auth_user_id::text = auth.uid()::text
    )
  );

-- 5. Ensure RLS is enabled
ALTER TABLE payments ENABLE ROW LEVEL SECURITY;
ALTER TABLE payment_records ENABLE ROW LEVEL SECURITY;

-- 6. Grant necessary permissions
GRANT SELECT ON payments TO authenticated;
GRANT SELECT ON payment_records TO authenticated;

-- 7. Verify the policies were created
SELECT 
  schemaname,
  tablename,
  policyname,
  permissive,
  roles,
  cmd
FROM pg_policies
WHERE tablename IN ('payment_records', 'payments')
ORDER BY tablename, policyname;

-- 8. Test query - this should return payments if you're an admin
SELECT COUNT(*) as total_payments FROM payments;
SELECT COUNT(*) as total_payment_records FROM payment_records;

COMMENT ON POLICY "Admin and student payment access" ON payments 
  IS 'Admins can view all Zelle payments, students can only view payments linked to their student_id';

COMMENT ON POLICY "Admin and student payment_records access" ON payment_records 
  IS 'Admins can view all manual payment records, students can only view their own records';
