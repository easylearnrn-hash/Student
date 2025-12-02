-- ============================================================
-- FINAL RLS + ADMIN ACCESS FIX
-- ============================================================
-- Goal:
--   • Students only see their own data
--   • Admins (listed in admin_accounts) can see/edit everything
--   • No infinite recursion (no policies read from students role column)
-- Usage:
--   1. Paste this entire script into the Supabase SQL Editor
--   2. Run it once (it is idempotent)
--   3. Reload the app and log in again
-- ============================================================

BEGIN;

-- ------------------------------------------------------------
-- STEP 0: Canonical admin list (no recursion, easy to audit)
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS admin_accounts (
  auth_user_id UUID PRIMARY KEY REFERENCES auth.users (id) ON DELETE CASCADE,
  email TEXT UNIQUE
);

-- Admin table should stay wide open for service role but is invisible
-- to regular users because they have zero privileges on it.
ALTER TABLE admin_accounts DISABLE ROW LEVEL SECURITY;

-- Ensure your known admin is listed (update email if needed)
INSERT INTO admin_accounts (auth_user_id, email)
VALUES
  ('3d03b89d-b62c-47ce-91de-32b1af6d748d', 'hrachfilm@gmail.com')
ON CONFLICT (auth_user_id)
DO UPDATE SET email = EXCLUDED.email;

-- ------------------------------------------------------------
-- STEP 1: Helper function so every policy can just call is_arnoma_admin()
-- ------------------------------------------------------------
CREATE OR REPLACE FUNCTION is_arnoma_admin()
RETURNS BOOLEAN
LANGUAGE sql
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT EXISTS (
    SELECT 1
    FROM admin_accounts
    WHERE auth_user_id = auth.uid()
  );
$$;

GRANT EXECUTE ON FUNCTION is_arnoma_admin() TO authenticated;

-- ------------------------------------------------------------
-- STEP 2: Make sure RLS is enabled everywhere we rely on it
-- ------------------------------------------------------------
ALTER TABLE students ENABLE ROW LEVEL SECURITY;
ALTER TABLE payment_records ENABLE ROW LEVEL SECURITY;
ALTER TABLE payments ENABLE ROW LEVEL SECURITY;
ALTER TABLE student_notes ENABLE ROW LEVEL SECURITY;
ALTER TABLE student_absences ENABLE ROW LEVEL SECURITY;
ALTER TABLE credit_log ENABLE ROW LEVEL SECURITY;
ALTER TABLE credit_payments ENABLE ROW LEVEL SECURITY;
ALTER TABLE forum_messages ENABLE ROW LEVEL SECURITY;
ALTER TABLE forum_replies ENABLE ROW LEVEL SECURITY;
ALTER TABLE schedule_changes ENABLE ROW LEVEL SECURITY;
ALTER TABLE groups ENABLE ROW LEVEL SECURITY;

-- ------------------------------------------------------------
-- STEP 3: Drop legacy policies so we can recreate clean ones
-- ------------------------------------------------------------
DROP POLICY IF EXISTS "students_select_own"            ON students;
DROP POLICY IF EXISTS "students_update_own"            ON students;
DROP POLICY IF EXISTS "payment_records_select_own"     ON payment_records;
DROP POLICY IF EXISTS "payments_select_own"            ON payments;
DROP POLICY IF EXISTS "student_notes_select_own_group" ON student_notes;
DROP POLICY IF EXISTS "student_absences_select_own"    ON student_absences;
DROP POLICY IF EXISTS "credit_log_select_own"          ON credit_log;
DROP POLICY IF EXISTS "credit_payments_select_own"     ON credit_payments;
DROP POLICY IF EXISTS "forum_messages_select_all"      ON forum_messages;
DROP POLICY IF EXISTS "forum_messages_insert_own"      ON forum_messages;
DROP POLICY IF EXISTS "forum_messages_update_own"      ON forum_messages;
DROP POLICY IF EXISTS "forum_messages_delete_own"      ON forum_messages;
DROP POLICY IF EXISTS "forum_replies_select_all"       ON forum_replies;
DROP POLICY IF EXISTS "forum_replies_insert_own"       ON forum_replies;
DROP POLICY IF EXISTS "forum_replies_update_own"       ON forum_replies;
DROP POLICY IF EXISTS "forum_replies_delete_own"       ON forum_replies;
DROP POLICY IF EXISTS "schedule_changes_select_all"    ON schedule_changes;
DROP POLICY IF EXISTS "groups_select_all"              ON groups;

-- ------------------------------------------------------------
-- STEP 4: Students table (admins see everything, students see self)
-- ------------------------------------------------------------
CREATE POLICY "students_select_admin_or_self"
ON students
FOR SELECT
TO authenticated
USING (
  is_arnoma_admin() OR auth.uid() = auth_user_id
);

CREATE POLICY "students_update_admin_or_self"
ON students
FOR UPDATE
TO authenticated
USING (
  is_arnoma_admin() OR auth.uid() = auth_user_id
)
WITH CHECK (
  is_arnoma_admin() OR auth.uid() = auth_user_id
);

CREATE POLICY "students_insert_admin_only"
ON students
FOR INSERT
TO authenticated
WITH CHECK (is_arnoma_admin());

CREATE POLICY "students_delete_admin_only"
ON students
FOR DELETE
TO authenticated
USING (is_arnoma_admin());

-- ------------------------------------------------------------
-- STEP 5: Payment records (owners see their history, admins full)
-- ------------------------------------------------------------
CREATE POLICY "payment_records_select_admin_or_owner"
ON payment_records
FOR SELECT
TO authenticated
USING (
  is_arnoma_admin()
  OR student_id IN (
    SELECT id FROM students WHERE auth_user_id = auth.uid()
  )
);

CREATE POLICY "payment_records_write_admin_only"
ON payment_records
FOR ALL
TO authenticated
USING (is_arnoma_admin())
WITH CHECK (is_arnoma_admin());

-- ------------------------------------------------------------
-- STEP 6: Payments table (Zelle imports, same rule set)
-- ------------------------------------------------------------
CREATE POLICY "payments_select_admin_or_owner"
ON payments
FOR SELECT
TO authenticated
USING (
  is_arnoma_admin()
  OR linked_student_id IN (
    SELECT id::text FROM students WHERE auth_user_id = auth.uid()
  )
  OR student_id IN (
    SELECT id::text FROM students WHERE auth_user_id = auth.uid()
  )
);

CREATE POLICY "payments_write_admin_only"
ON payments
FOR ALL
TO authenticated
USING (is_arnoma_admin())
WITH CHECK (is_arnoma_admin());

-- ------------------------------------------------------------
-- STEP 7: Student notes (students limited by group/payment)
-- ------------------------------------------------------------
CREATE POLICY "student_notes_select_admin_or_group"
ON student_notes
FOR SELECT
TO authenticated
USING (
  is_arnoma_admin()
  OR (
    deleted = false
    AND group_name IN (
      SELECT group_name FROM students WHERE auth_user_id = auth.uid()
    )
    AND (
      requires_payment = false
      OR EXISTS (
        SELECT 1 FROM students 
        WHERE auth_user_id = auth.uid() 
          AND balance <= 0
      )
    )
  )
);

CREATE POLICY "student_notes_write_admin_only"
ON student_notes
FOR ALL
TO authenticated
USING (is_arnoma_admin())
WITH CHECK (is_arnoma_admin());

-- ------------------------------------------------------------
-- STEP 8: Student absences
-- ------------------------------------------------------------
CREATE POLICY "student_absences_select_admin_or_owner"
ON student_absences
FOR SELECT
TO authenticated
USING (
  is_arnoma_admin()
  OR student_id IN (
    SELECT id FROM students WHERE auth_user_id = auth.uid()
  )
);

CREATE POLICY "student_absences_write_admin_only"
ON student_absences
FOR ALL
TO authenticated
USING (is_arnoma_admin())
WITH CHECK (is_arnoma_admin());

-- ------------------------------------------------------------
-- STEP 9: Credit log / credit payments
-- ------------------------------------------------------------
CREATE POLICY "credit_log_select_admin_or_owner"
ON credit_log
FOR SELECT
TO authenticated
USING (
  is_arnoma_admin()
  OR student_id IN (
    SELECT id FROM students WHERE auth_user_id = auth.uid()
  )
);

CREATE POLICY "credit_log_write_admin_only"
ON credit_log
FOR ALL
TO authenticated
USING (is_arnoma_admin())
WITH CHECK (is_arnoma_admin());

CREATE POLICY "credit_payments_select_admin_or_owner"
ON credit_payments
FOR SELECT
TO authenticated
USING (
  is_arnoma_admin()
  OR student_id IN (
    SELECT id FROM students WHERE auth_user_id = auth.uid()
  )
);

CREATE POLICY "credit_payments_write_admin_only"
ON credit_payments
FOR ALL
TO authenticated
USING (is_arnoma_admin())
WITH CHECK (is_arnoma_admin());

-- ------------------------------------------------------------
-- STEP 10: Forum (students post; admins can moderate anything)
-- ------------------------------------------------------------
CREATE POLICY "forum_messages_select_all"
ON forum_messages
FOR SELECT
TO authenticated
USING (true);

CREATE POLICY "forum_messages_insert_self_or_admin"
ON forum_messages
FOR INSERT
TO authenticated
WITH CHECK (
  is_arnoma_admin()
  OR student_id IN (
    SELECT id FROM students WHERE auth_user_id = auth.uid()
  )
);

CREATE POLICY "forum_messages_update_delete"
ON forum_messages
FOR ALL
TO authenticated
USING (
  is_arnoma_admin()
  OR student_id IN (
    SELECT id FROM students WHERE auth_user_id = auth.uid()
  )
)
WITH CHECK (
  is_arnoma_admin()
  OR student_id IN (
    SELECT id FROM students WHERE auth_user_id = auth.uid()
  )
);

CREATE POLICY "forum_replies_select_all"
ON forum_replies
FOR SELECT
TO authenticated
USING (true);

CREATE POLICY "forum_replies_insert_self_or_admin"
ON forum_replies
FOR INSERT
TO authenticated
WITH CHECK (
  is_arnoma_admin()
  OR student_id IN (
    SELECT id FROM students WHERE auth_user_id = auth.uid()
  )
);

CREATE POLICY "forum_replies_update_delete"
ON forum_replies
FOR ALL
TO authenticated
USING (
  is_arnoma_admin()
  OR student_id IN (
    SELECT id FROM students WHERE auth_user_id = auth.uid()
  )
)
WITH CHECK (
  is_arnoma_admin()
  OR student_id IN (
    SELECT id FROM students WHERE auth_user_id = auth.uid()
  )
);

-- ------------------------------------------------------------
-- STEP 11: Schedule changes & groups (read for all, write admin)
-- ------------------------------------------------------------
CREATE POLICY "schedule_changes_select_all"
ON schedule_changes
FOR SELECT
TO authenticated
USING (true);

CREATE POLICY "schedule_changes_write_admin_only"
ON schedule_changes
FOR ALL
TO authenticated
USING (is_arnoma_admin())
WITH CHECK (is_arnoma_admin());

CREATE POLICY "groups_select_all"
ON groups
FOR SELECT
TO authenticated
USING (true);

CREATE POLICY "groups_write_admin_only"
ON groups
FOR ALL
TO authenticated
USING (is_arnoma_admin())
WITH CHECK (is_arnoma_admin());

COMMIT;

-- ------------------------------------------------------------
-- STEP 12: Verification helpers you can run afterward
-- ------------------------------------------------------------
-- View which auth IDs are treated as admins
SELECT * FROM admin_accounts;

-- Confirm every policy exists
SELECT tablename, policyname, roles, cmd
FROM pg_policies
WHERE schemaname = 'public'
ORDER BY tablename, policyname;

-- Confirm RLS is on
SELECT tablename, rowsecurity
FROM pg_tables
WHERE schemaname = 'public'
  AND tablename IN (
    'students','payment_records','payments','student_notes','student_absences',
    'credit_log','credit_payments','forum_messages','forum_replies','schedule_changes','groups'
  )
ORDER BY tablename;

-- After running this script, admins listed in admin_accounts can log in
-- with a normal Supabase session (no service key needed) and see/edit
-- every record. Students remain isolated to only their own information.
-- ============================================================
