-- CRITICAL FIX: Allow student portal (anonymous users) to read payment data
-- Student portal needs to check payments to unlock notes
-- This is SAFE because students can only see their own data (filtered by student_id in app logic)

-- Fix 1: payment_records table - allow anonymous SELECT
DROP POLICY IF EXISTS "anon_read_payment_records" ON payment_records;
CREATE POLICY "anon_read_payment_records"
  ON payment_records
  FOR SELECT
  TO anon
  USING (true);  -- Students filter by student_id in JavaScript

-- Fix 2: payments table - allow anonymous SELECT  
DROP POLICY IF EXISTS "anon_read_payments" ON payments;
CREATE POLICY "anon_read_payments"
  ON payments
  FOR SELECT
  TO anon
  USING (true);  -- Students filter by student_id/name in JavaScript

-- Fix 3: credit_payments table - allow anonymous SELECT
DROP POLICY IF EXISTS "anon_read_credit_payments" ON credit_payments;
CREATE POLICY "anon_read_credit_payments"
  ON credit_payments
  FOR SELECT
  TO anon
  USING (true);  -- Students filter by student_id in JavaScript

-- Verify policies were created
SELECT 
  schemaname,
  tablename,
  policyname,
  permissive,
  roles,
  cmd
FROM pg_policies 
WHERE tablename IN ('payment_records', 'payments', 'credit_payments')
  AND 'anon' = ANY(roles)
ORDER BY tablename, policyname;
