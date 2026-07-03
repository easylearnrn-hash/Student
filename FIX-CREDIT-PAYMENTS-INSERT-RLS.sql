-- Allow students to insert credit_payments for their own student_id.
-- The previous policy was admin-only, blocking the Pay From Credit flow.
DROP POLICY IF EXISTS "credit_payments_insert" ON credit_payments;

CREATE POLICY "credit_payments_insert"
ON credit_payments FOR INSERT
WITH CHECK (
  is_arnoma_admin()
  OR student_id IN (
    SELECT id FROM students
    WHERE auth_user_id = auth.uid()
       OR email = auth.email()
  )
);
