-- ============================================================
-- CHECK PAYMENT VISIBILITY FOR STUDENTS
-- ============================================================
-- Run this to verify RLS policies allow students to see their payments

-- 1. Check payment_records RLS policies
SELECT 
  schemaname,
  tablename,
  policyname,
  permissive,
  roles,
  cmd,
  qual,
  with_check
FROM pg_policies
WHERE tablename IN ('payment_records', 'payments')
ORDER BY tablename, policyname;

-- 2. Check if students have proper auth_user_id linkage
SELECT 
  id,
  name,
  email,
  auth_user_id,
  CASE 
    WHEN auth_user_id IS NULL THEN '❌ NO AUTH LINK'
    ELSE '✅ Linked'
  END as auth_status
FROM students
ORDER BY name;

-- 3. Test payment visibility for a specific student (replace with actual student_id)
-- This simulates what a student would see
SELECT 
  pr.id,
  pr.student_id,
  s.name as student_name,
  pr.amount,
  pr.date as payment_date,
  pr.status,
  pr.payment_method
FROM payment_records pr
LEFT JOIN students s ON pr.student_id = s.id
WHERE pr.student_id = 11  -- Replace with actual student ID
ORDER BY pr.date DESC;

-- 4. Check Zelle payments visibility
SELECT 
  p.id,
  p.linked_student_id,
  p.resolved_student_name as student_name,
  p.amount,
  p.email_date as payment_date,
  p.sender_name as payer_name
FROM payments p
WHERE p.linked_student_id = '11'  -- Replace with actual student ID as text
ORDER BY p.email_date DESC;

-- 5. Fix: Grant students access to view their payments
-- Run this if payments are not visible

-- Ensure authenticated users can read payments
GRANT SELECT ON payment_records TO authenticated;
GRANT SELECT ON payments TO authenticated;

-- Create/update RLS policy for payment_records
DROP POLICY IF EXISTS "Students can view own payment records" ON payment_records;
CREATE POLICY "Students can view own payment records"
  ON payment_records FOR SELECT
  USING (
    -- Students can see their own records
    student_id IN (
      SELECT id FROM students WHERE auth_user_id::text = auth.uid()::text
    )
    OR
    -- Admins can see all
    EXISTS (
      SELECT 1 FROM admin_accounts 
      WHERE email = (SELECT email FROM auth.users WHERE id = auth.uid())
    )
  );

-- Create/update RLS policy for payments (Zelle)
DROP POLICY IF EXISTS "Students can view linked payments" ON payments;
CREATE POLICY "Students can view linked payments"
  ON payments FOR SELECT
  USING (
    -- Students can see payments linked to them
    linked_student_id IN (
      SELECT id::text FROM students WHERE auth_user_id::text = auth.uid()::text
    )
    OR
    -- Admins can see all
    EXISTS (
      SELECT 1 FROM admin_accounts 
      WHERE email = (SELECT email FROM auth.users WHERE id = auth.uid())
    )
  );

-- 6. Verify policies are active
SELECT tablename, rowsecurity 
FROM pg_tables 
WHERE tablename IN ('payment_records', 'payments')
  AND schemaname = 'public';

COMMENT ON POLICY "Students can view own payment records" ON payment_records IS 'Students can view payments linked to their student ID';
COMMENT ON POLICY "Students can view linked payments" ON payments IS 'Students can view Zelle payments linked to their student ID';
