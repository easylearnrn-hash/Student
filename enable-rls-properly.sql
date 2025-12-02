-- ============================================================
-- PROPER RLS SETUP (NO INFINITE RECURSION)
-- ============================================================
-- This avoids infinite recursion by NOT checking students.role
-- Instead, we use auth.uid() directly
-- ============================================================

-- STEP 1: Enable RLS on all tables
-- ============================================================
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


-- ============================================================
-- STEP 2: STUDENTS TABLE POLICIES
-- ============================================================

-- Students can only view their own record
CREATE POLICY "students_select_own"
ON students
FOR SELECT
TO authenticated
USING (auth.uid() = auth_user_id);

-- Students can update their own record (for profile edits)
CREATE POLICY "students_update_own"
ON students
FOR UPDATE
TO authenticated
USING (auth.uid() = auth_user_id)
WITH CHECK (auth.uid() = auth_user_id);


-- ============================================================
-- STEP 3: PAYMENT_RECORDS TABLE POLICIES
-- ============================================================

-- Students can only view their own payment records
CREATE POLICY "payment_records_select_own"
ON payment_records
FOR SELECT
TO authenticated
USING (
  student_id IN (
    SELECT id FROM students WHERE auth_user_id = auth.uid()
  )
);


-- ============================================================
-- STEP 4: PAYMENTS TABLE POLICIES (Zelle)
-- ============================================================

-- Students can only view payments linked to them
CREATE POLICY "payments_select_own"
ON payments
FOR SELECT
TO authenticated
USING (
  linked_student_id IN (
    SELECT id::text FROM students WHERE auth_user_id = auth.uid()
  )
  OR student_id IN (
    SELECT id::text FROM students WHERE auth_user_id = auth.uid()
  )
);


-- ============================================================
-- STEP 5: STUDENT_NOTES TABLE POLICIES
-- ============================================================

-- Students can view notes for their group
CREATE POLICY "student_notes_select_own_group"
ON student_notes
FOR SELECT
TO authenticated
USING (
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
);


-- ============================================================
-- STEP 6: STUDENT_ABSENCES TABLE POLICIES
-- ============================================================

-- Students can only view their own absences
CREATE POLICY "student_absences_select_own"
ON student_absences
FOR SELECT
TO authenticated
USING (
  student_id IN (
    SELECT id FROM students WHERE auth_user_id = auth.uid()
  )
);


-- ============================================================
-- STEP 7: CREDIT_LOG TABLE POLICIES
-- ============================================================

-- Students can only view their own credit log
CREATE POLICY "credit_log_select_own"
ON credit_log
FOR SELECT
TO authenticated
USING (
  student_id IN (
    SELECT id FROM students WHERE auth_user_id = auth.uid()
  )
);


-- ============================================================
-- STEP 8: CREDIT_PAYMENTS TABLE POLICIES
-- ============================================================

-- Students can only view their own credit payments
CREATE POLICY "credit_payments_select_own"
ON credit_payments
FOR SELECT
TO authenticated
USING (
  student_id IN (
    SELECT id FROM students WHERE auth_user_id = auth.uid()
  )
);


-- ============================================================
-- STEP 9: FORUM_MESSAGES TABLE POLICIES
-- ============================================================

-- Students can view all messages (public forum)
CREATE POLICY "forum_messages_select_all"
ON forum_messages
FOR SELECT
TO authenticated
USING (true);

-- Students can insert their own messages
CREATE POLICY "forum_messages_insert_own"
ON forum_messages
FOR INSERT
TO authenticated
WITH CHECK (
  student_id IN (
    SELECT id FROM students WHERE auth_user_id = auth.uid()
  )
);

-- Students can update/delete their own messages
CREATE POLICY "forum_messages_update_own"
ON forum_messages
FOR UPDATE
TO authenticated
USING (
  student_id IN (
    SELECT id FROM students WHERE auth_user_id = auth.uid()
  )
)
WITH CHECK (
  student_id IN (
    SELECT id FROM students WHERE auth_user_id = auth.uid()
  )
);

CREATE POLICY "forum_messages_delete_own"
ON forum_messages
FOR DELETE
TO authenticated
USING (
  student_id IN (
    SELECT id FROM students WHERE auth_user_id = auth.uid()
  )
);


-- ============================================================
-- STEP 10: FORUM_REPLIES TABLE POLICIES
-- ============================================================

-- Students can view all replies
CREATE POLICY "forum_replies_select_all"
ON forum_replies
FOR SELECT
TO authenticated
USING (true);

-- Students can insert their own replies
CREATE POLICY "forum_replies_insert_own"
ON forum_replies
FOR INSERT
TO authenticated
WITH CHECK (
  student_id IN (
    SELECT id FROM students WHERE auth_user_id = auth.uid()
  )
);

-- Students can update/delete their own replies
CREATE POLICY "forum_replies_update_own"
ON forum_replies
FOR UPDATE
TO authenticated
USING (
  student_id IN (
    SELECT id FROM students WHERE auth_user_id = auth.uid()
  )
)
WITH CHECK (
  student_id IN (
    SELECT id FROM students WHERE auth_user_id = auth.uid()
  )
);

CREATE POLICY "forum_replies_delete_own"
ON forum_replies
FOR DELETE
TO authenticated
USING (
  student_id IN (
    SELECT id FROM students WHERE auth_user_id = auth.uid()
  )
);


-- ============================================================
-- STEP 11: SCHEDULE_CHANGES TABLE POLICIES
-- ============================================================

-- Students can view all schedule changes (public announcements)
CREATE POLICY "schedule_changes_select_all"
ON schedule_changes
FOR SELECT
TO authenticated
USING (true);


-- ============================================================
-- STEP 12: GROUPS TABLE POLICIES
-- ============================================================

-- Students can view all groups (needed for schedule display)
CREATE POLICY "groups_select_all"
ON groups
FOR SELECT
TO authenticated
USING (true);


-- ============================================================
-- STEP 13: ADMIN BYPASS (Service Role Key)
-- ============================================================
-- Admin operations should use Supabase Service Role Key
-- This bypasses ALL RLS policies automatically
-- 
-- In your admin pages (Student-Manager.html, etc.):
-- Use the service_role key instead of anon key
-- 
-- Current: const SUPABASE_ANON_KEY = 'eyJhbGci...'
-- For Admin: const SUPABASE_SERVICE_KEY = 'eyJhbGci...' (from Supabase dashboard)
--
-- Example:
-- const supabaseAdmin = createClient(SUPABASE_URL, SUPABASE_SERVICE_KEY);
-- 
-- This gives full access to all tables, bypassing RLS
-- ============================================================


-- ============================================================
-- VERIFICATION QUERIES
-- ============================================================

-- Check all policies were created
SELECT 
  schemaname,
  tablename,
  policyname,
  permissive,
  roles,
  cmd
FROM pg_policies 
WHERE schemaname = 'public'
ORDER BY tablename, policyname;

-- Check RLS is enabled
SELECT 
  tablename,
  rowsecurity,
  CASE 
    WHEN rowsecurity = true THEN '🔒 RLS ENABLED ✅'
    WHEN rowsecurity = false THEN '⚠️ RLS DISABLED'
  END as status
FROM pg_tables 
WHERE schemaname = 'public'
  AND tablename IN (
    'students', 
    'payment_records', 
    'payments', 
    'student_notes', 
    'schedule_changes', 
    'groups',
    'student_absences',
    'credit_log',
    'credit_payments',
    'forum_messages',
    'forum_replies'
  )
ORDER BY tablename;


-- ============================================================
-- NOTES:
-- ============================================================
-- 
-- ✅ NO INFINITE RECURSION
-- - Policies don't check students.role
-- - They only use auth.uid() = auth_user_id
-- - No circular references
--
-- ✅ SECURITY MODEL
-- - Students: Can only see their own data
-- - Admin: Use service_role key to bypass RLS
-- - Forum/Schedule: Public to all authenticated users
--
-- ✅ NEXT STEPS FOR ADMIN PAGES
-- 1. Get service_role key from Supabase Dashboard → Settings → API
-- 2. Update admin pages to use service_role instead of anon key:
--    - Student-Manager.html
--    - Payment-Records.html
--    - Email-System.html
--    - Notes-Manager.html
-- 3. Keep anon key in student-facing pages:
--    - student-portal.html
--    - Login.html
--
-- ⚠️ IMPORTANT: Never expose service_role key in client-side code
-- that students can access! Only use it in admin-only pages.
-- ============================================================
