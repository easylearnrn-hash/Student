-- ============================================================
-- FIX: 406 Not Acceptable — broken ::uuid cast on integer IDs
-- The previous SECURE-LOCKDOWN-RLS.sql cast students.id to ::uuid
-- but students.id is an INTEGER. This crashed every SELECT on
-- students / payment_records for ALL users (including paid students).
-- ============================================================

BEGIN;

-- -------------------------------------------------------
-- FIX 1: students table — drop the broken policy, recreate clean
-- -------------------------------------------------------
DROP POLICY IF EXISTS "Students can view own profile" ON students;

CREATE POLICY "Students can view own profile"
ON students FOR SELECT
TO authenticated, anon
USING (
  is_arnoma_admin()
  OR auth_user_id::text = auth.uid()::text
);

-- -------------------------------------------------------
-- FIX 2: payment_records table — drop broken policy, recreate clean
-- -------------------------------------------------------
DROP POLICY IF EXISTS "Students can view own payment records" ON payment_records;

CREATE POLICY "Students can view own payment records"
ON payment_records FOR SELECT
TO authenticated, anon
USING (
  is_arnoma_admin()
  OR student_id::bigint IN (
    SELECT id::bigint FROM students WHERE auth_user_id::text = auth.uid()::text
  )
);

-- -------------------------------------------------------
-- FIX 3: payments (Zelle/Venmo) table — drop broken policy, recreate clean
-- -------------------------------------------------------
DROP POLICY IF EXISTS "Students can view own payments" ON payments;

CREATE POLICY "Students can view own payments"
ON payments FOR SELECT
TO authenticated, anon
USING (
  is_arnoma_admin()
  OR (auth.role() = 'service_role')
  OR student_id::bigint IN (
    SELECT id::bigint FROM students WHERE auth_user_id::text = auth.uid()::text
  )
  OR linked_student_id::bigint IN (
    SELECT id::bigint FROM students WHERE auth_user_id::text = auth.uid()::text
  )
);

COMMIT;
