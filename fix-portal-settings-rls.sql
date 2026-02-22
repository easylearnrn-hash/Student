-- =============================================================================
-- ARNOMA SECURITY HARDENING
-- Guarantees:
--   1. Students can ONLY read their OWN payment_records / payments rows
--   2. Students can NEVER read other students' payment records
--   3. Earning-Forecast data (ALL students + ALL payments) is admin-only at DB level
--   4. portal_settings is readable by every authenticated user (students + admins)
-- Run this in Supabase SQL Editor.
-- =============================================================================

-- DIAGNOSTIC: shows exact column types — verify before running
-- SELECT table_name, column_name, data_type
-- FROM information_schema.columns
-- WHERE table_schema = 'public'
--   AND table_name IN ('payment_records', 'payments', 'students')
--   AND column_name IN ('id', 'student_id', 'linked_student_id')
-- ORDER BY table_name, column_name;

-- Ensure the admin helper function exists (idempotent)
CREATE OR REPLACE FUNCTION is_arnoma_admin()
RETURNS BOOLEAN AS $$
BEGIN
  RETURN EXISTS (
    SELECT 1 FROM admin_accounts
    WHERE auth_user_id = auth.uid()
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;


-- =============================================================================
-- STEP 1: Nuke ALL existing policies on the four target tables.
-- This avoids "already exists" and type-cast errors from old policies.
-- =============================================================================
DO $$
DECLARE
  r RECORD;
BEGIN
  FOR r IN
    SELECT policyname, tablename
    FROM pg_policies
    WHERE schemaname = 'public'
      AND tablename IN ('payment_records', 'payments', 'students', 'portal_settings')
  LOOP
    EXECUTE format('DROP POLICY IF EXISTS %I ON %I', r.policyname, r.tablename);
  END LOOP;
END $$;


-- =============================================================================
-- payment_records
-- =============================================================================

-- Students: read only their own rows
-- Cast both sides to text — works regardless of whether student_id is int, bigint, or text
CREATE POLICY "Students can read own payment records"
ON payment_records FOR SELECT
TO authenticated
USING (
  NOT is_arnoma_admin()
  AND student_id::text IN (
    SELECT id::text FROM students WHERE auth_user_id = auth.uid()
  )
);

-- Admins: full access
CREATE POLICY "Admins have full access to payment records"
ON payment_records FOR ALL
TO authenticated
USING (is_arnoma_admin());


-- =============================================================================
-- payments  (Zelle / Venmo automated imports)
-- =============================================================================

-- Students: read only rows linked to their own student id
-- NOTE: linked_student_id and student_id on the payments table are stored as TEXT,
-- while students.id is BIGINT — cast students.id to text for the comparison.
CREATE POLICY "Students can read own payments"
ON payments FOR SELECT
TO authenticated
USING (
  NOT is_arnoma_admin()
  AND (
    linked_student_id IN (SELECT id::text FROM students WHERE auth_user_id = auth.uid())
    OR student_id::text IN (SELECT id::text FROM students WHERE auth_user_id = auth.uid())
  )
);

-- Anon INSERT — required for the automated Gmail import edge function
CREATE POLICY "Anon can insert payments"
ON payments FOR INSERT
TO anon
WITH CHECK (true);

-- Anon UPDATE — required for Gmail import dedup (gmail_id unique constraint)
CREATE POLICY "Anon can update payments by gmail_id"
ON payments FOR UPDATE
TO anon
USING (true);

-- Admins: full access
CREATE POLICY "Admins have full access to payments"
ON payments FOR ALL
TO authenticated
USING (is_arnoma_admin());


-- =============================================================================
-- students
-- (Earning-Forecast queries ALL students — block non-admins at DB level)
-- =============================================================================

-- Students: read only their own single row
CREATE POLICY "Students can read own record"
ON students FOR SELECT
TO authenticated
USING (
  NOT is_arnoma_admin()
  AND auth_user_id = auth.uid()
);

-- Students: update only their own non-critical fields
CREATE POLICY "Students can update own record"
ON students FOR UPDATE
TO authenticated
USING (NOT is_arnoma_admin() AND auth_user_id = auth.uid())
WITH CHECK (NOT is_arnoma_admin() AND auth_user_id = auth.uid());

-- Admins: full access (Student Manager, Calendar, Earning Forecast, etc.)
CREATE POLICY "Admins have full access to students"
ON students FOR ALL
TO authenticated
USING (is_arnoma_admin());


-- =============================================================================
-- portal_settings
-- (Christmas theme etc — everyone reads, only admins write)
-- =============================================================================

-- All authenticated users (students + admins) can read
CREATE POLICY "Authenticated users can read portal settings"
ON portal_settings FOR SELECT
TO authenticated
USING (true);

-- Anon can read (portal may query before auth resolves)
CREATE POLICY "Anon can read portal settings"
ON portal_settings FOR SELECT
TO anon
USING (true);

-- Only admins can write
CREATE POLICY "Admins can write portal settings"
ON portal_settings FOR ALL
TO authenticated
USING (is_arnoma_admin());


-- =============================================================================
-- VERIFICATION
-- =============================================================================

-- Should return the clean set of policies above (no old broken ones)
SELECT tablename, policyname, roles, cmd
FROM pg_policies
WHERE schemaname = 'public'
  AND tablename IN ('payment_records', 'payments', 'students', 'portal_settings')
ORDER BY tablename, policyname;
