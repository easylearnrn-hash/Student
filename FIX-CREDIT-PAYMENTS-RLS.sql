-- ============================================================
-- FIX credit_payments 403 error
-- Students were blocked because the SELECT policy only matched
-- via auth_user_id = auth.uid(). Students who authenticate via
-- email (or whose auth_user_id column is not yet set) get 403.
-- Fix: add email = auth.email() as a fallback — consistent with
-- all other student-facing policies in this project.
-- ============================================================

-- Drop all existing credit_payments policies
DROP POLICY IF EXISTS "credit_payments_select_policy"         ON credit_payments;
DROP POLICY IF EXISTS "credit_payments_insert_policy"         ON credit_payments;
DROP POLICY IF EXISTS "credit_payments_update_policy"         ON credit_payments;
DROP POLICY IF EXISTS "credit_payments_delete_policy"         ON credit_payments;
DROP POLICY IF EXISTS "Students can view own credit payments"  ON credit_payments;
DROP POLICY IF EXISTS "Admins full access to credit payments"  ON credit_payments;

-- SELECT: admins see all; students see their own rows via UID or email
CREATE POLICY "credit_payments_select"
ON credit_payments FOR SELECT
USING (
  is_arnoma_admin()
  OR student_id IN (
    SELECT id FROM students
    WHERE auth_user_id = auth.uid()
       OR email = auth.email()
  )
);

-- INSERT / UPDATE / DELETE: admins only
CREATE POLICY "credit_payments_insert"
ON credit_payments FOR INSERT
WITH CHECK (is_arnoma_admin());

CREATE POLICY "credit_payments_update"
ON credit_payments FOR UPDATE
USING (is_arnoma_admin());

CREATE POLICY "credit_payments_delete"
ON credit_payments FOR DELETE
USING (is_arnoma_admin());
