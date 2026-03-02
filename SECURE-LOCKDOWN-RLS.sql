-- ============================================
-- STRICT SECURITY LOCKDOWN RLS POLICIES
-- Goal: Ensure students CAN ONLY see their own payments and profile.
-- Admin pages locked to hrachfilm@gmail.com only.
-- ============================================

BEGIN;

-- 1. Ensure only hrachfilm@gmail.com is in admin_accounts
DELETE FROM admin_accounts WHERE email != 'hrachfilm@gmail.com';

-- 2. Lock down PAYMENT_RECORDS table
DROP POLICY IF EXISTS "payment_records_select" ON payment_records;
DROP POLICY IF EXISTS "Public can view payment_records" ON payment_records;
DROP POLICY IF EXISTS "Anon can read payment records" ON payment_records;
DROP POLICY IF EXISTS "Students can view own payment records" ON payment_records;
DROP POLICY IF EXISTS "Admins can manage payment records" ON payment_records;

CREATE POLICY "Students can view own payment records"
ON payment_records FOR SELECT
TO authenticated, anon
USING (
  -- Admin sees all
  is_arnoma_admin() OR
  -- Student sees only their own payments
  student_id IN (SELECT id FROM students WHERE auth_user_id = auth.uid()) OR
  -- For Impersonation (anon token matched)
  student_id = (current_setting('request.jwt.claims', true)::json->>'impersonate_id')::uuid
);

CREATE POLICY "Admins can manage payment records"
ON payment_records FOR ALL
TO authenticated
USING (is_arnoma_admin())
WITH CHECK (is_arnoma_admin());


-- 3. Lock down PAYMENTS table (Zelle imports)
DROP POLICY IF EXISTS "payments_select" ON payments;
DROP POLICY IF EXISTS "Public can view payments" ON payments;
DROP POLICY IF EXISTS "Anon can read payments" ON payments;
DROP POLICY IF EXISTS "Students can view own payments" ON payments;
DROP POLICY IF EXISTS "Admins can manage payments" ON payments;

CREATE POLICY "Students can view own payments"
ON payments FOR SELECT
TO authenticated, anon
USING (
  -- Admin sees all
  is_arnoma_admin() OR
  -- Allowed for webhook/ingest scripts?
  (auth.role() = 'service_role') OR
  -- Student sees only matching IDs
  student_id IN (SELECT id FROM students WHERE auth_user_id = auth.uid()) OR
  linked_student_id IN (SELECT id FROM students WHERE auth_user_id = auth.uid())
);

CREATE POLICY "Admins can manage payments"
ON payments FOR ALL
TO authenticated
USING (is_arnoma_admin())
WITH CHECK (is_arnoma_admin());

-- Webhook ingest rule (usually anon or service role)
CREATE POLICY "Anon can insert payments"
ON payments FOR INSERT
TO anon, authenticated
WITH CHECK (true);

CREATE POLICY "Anon can update payments gmail_id"
ON payments FOR UPDATE
TO anon, authenticated
USING (true)
WITH CHECK (true);

-- 4. Lock down STUDENTS profile
DROP POLICY IF EXISTS "students_select" ON students;
DROP POLICY IF EXISTS "Public can view students" ON students;
DROP POLICY IF EXISTS "Anon can read students" ON students;

CREATE POLICY "Students can view own profile"
ON students FOR SELECT
TO authenticated, anon
USING (
  is_arnoma_admin() OR
  auth_user_id = auth.uid() OR
  id = (current_setting('request.jwt.claims', true)::json->>'impersonate_id')::uuid
);

COMMIT;
