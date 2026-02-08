-- ============================================
-- FIX ALL STUDENT PORTAL RLS POLICIES
-- Students are blocked from accessing multiple tables
-- ============================================

BEGIN;

-- ============================================
-- 1. STUDENT_NOTE_PERMISSIONS
-- ============================================

DROP POLICY IF EXISTS "Students can view their note permissions" ON student_note_permissions;
DROP POLICY IF EXISTS "Allow authenticated users to read permissions" ON student_note_permissions;
DROP POLICY IF EXISTS "Allow authenticated users to manage permissions" ON student_note_permissions;
DROP POLICY IF EXISTS "authenticated_full_access" ON student_note_permissions;
DROP POLICY IF EXISTS "anon_read_access" ON student_note_permissions;

CREATE POLICY "Students can read own permissions"
ON student_note_permissions FOR SELECT
TO authenticated
USING (
  student_id IN (SELECT id FROM students WHERE auth_user_id = auth.uid())
  OR is_arnoma_admin()
);

CREATE POLICY "Admins full access to note permissions"
ON student_note_permissions FOR ALL
TO authenticated
USING (is_arnoma_admin())
WITH CHECK (is_arnoma_admin());

-- ============================================
-- 2. NOTE_FREE_ACCESS
-- ============================================

DROP POLICY IF EXISTS "Students can view free access" ON note_free_access;
DROP POLICY IF EXISTS "Allow anon read for impersonation" ON note_free_access;
DROP POLICY IF EXISTS "Students can view their free access" ON note_free_access;
DROP POLICY IF EXISTS "Admin full access to note_free_access" ON note_free_access;

CREATE POLICY "Students can view free access"
ON note_free_access FOR SELECT
TO public
USING (
  -- Individual access for this student
  student_id IN (SELECT id FROM students WHERE auth_user_id = auth.uid())
  OR
  -- Group access for this student's group
  (access_type = 'group' AND group_letter IN (
    SELECT REPLACE(REPLACE(group_name, 'Group ', ''), 'group ', '')
    FROM students 
    WHERE auth_user_id = auth.uid()
  ))
  OR
  is_arnoma_admin()
);

CREATE POLICY "Admins full access to note_free_access"
ON note_free_access FOR ALL
TO authenticated
USING (is_arnoma_admin())
WITH CHECK (is_arnoma_admin());

-- ============================================
-- 3. STUDENT_ABSENCES
-- ============================================

DROP POLICY IF EXISTS "Students can read their own absences" ON student_absences;
DROP POLICY IF EXISTS "Public can read student absences" ON student_absences;
DROP POLICY IF EXISTS "Public can insert student absences" ON student_absences;
DROP POLICY IF EXISTS "Public can update student absences" ON student_absences;
DROP POLICY IF EXISTS "Public can delete student absences" ON student_absences;
DROP POLICY IF EXISTS "Allow anon read for impersonation" ON student_absences;
DROP POLICY IF EXISTS "Admins can manage all absences" ON student_absences;

CREATE POLICY "Students can view own absences"
ON student_absences FOR SELECT
TO authenticated
USING (
  student_id IN (SELECT id FROM students WHERE auth_user_id = auth.uid())
  OR is_arnoma_admin()
);

CREATE POLICY "Admins full access to absences"
ON student_absences FOR ALL
TO authenticated
USING (is_arnoma_admin())
WITH CHECK (is_arnoma_admin());

-- ============================================
-- 4. CREDIT_PAYMENTS
-- ============================================

DROP POLICY IF EXISTS "credit_payments_select_policy" ON credit_payments;
DROP POLICY IF EXISTS "credit_payments_insert_policy" ON credit_payments;
DROP POLICY IF EXISTS "credit_payments_update_policy" ON credit_payments;
DROP POLICY IF EXISTS "credit_payments_delete_policy" ON credit_payments;

CREATE POLICY "Students can view own credit payments"
ON credit_payments FOR SELECT
TO authenticated
USING (
  student_id IN (SELECT id FROM students WHERE auth_user_id = auth.uid())
  OR is_arnoma_admin()
);

CREATE POLICY "Admins full access to credit payments"
ON credit_payments FOR ALL
TO authenticated
USING (is_arnoma_admin())
WITH CHECK (is_arnoma_admin());

-- ============================================
-- 5. SKIPPED_CLASSES
-- ============================================

DROP POLICY IF EXISTS "Students can read their group skipped classes" ON skipped_classes;
DROP POLICY IF EXISTS "Public can select skipped classes" ON skipped_classes;
DROP POLICY IF EXISTS "Admins can manage all skipped classes" ON skipped_classes;

CREATE POLICY "Students can view their group skipped classes"
ON skipped_classes FOR SELECT
TO authenticated
USING (
  group_name IN (SELECT group_name FROM students WHERE auth_user_id = auth.uid())
  OR is_arnoma_admin()
);

CREATE POLICY "Admins full access to skipped classes"
ON skipped_classes FOR ALL
TO authenticated
USING (is_arnoma_admin())
WITH CHECK (is_arnoma_admin());

-- ============================================
-- VERIFICATION
-- ============================================

SELECT 
  tablename,
  COUNT(*) as policy_count
FROM pg_policies
WHERE schemaname = 'public'
  AND tablename IN (
    'student_note_permissions',
    'note_free_access',
    'student_absences',
    'credit_payments',
    'skipped_classes',
    'student_sessions'
  )
GROUP BY tablename
ORDER BY tablename;

COMMIT;

-- ============================================
-- EXPECTED RESULTS
-- ============================================

/*
Each table should have 2 policies:
1. Students can view/access their own data
2. Admins have full access

Tables fixed:
✅ student_note_permissions
✅ note_free_access
✅ student_absences
✅ credit_payments
✅ skipped_classes
✅ student_sessions (already fixed)

After running this, students should be able to:
✅ View their note permissions
✅ View free access grants for their group
✅ View their absence records
✅ View their credit payments
✅ View skipped classes for their group
✅ Manage their active sessions
*/
