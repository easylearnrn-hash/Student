-- COMPLETE RESTORE: Fix all RLS policies for Group Notes
-- Run this in Supabase SQL Editor

-- ========================================
-- 1. STUDENT_NOTE_PERMISSIONS TABLE
-- ========================================

-- Drop all existing policies
DROP POLICY IF EXISTS "Students can view their note permissions" ON student_note_permissions;
DROP POLICY IF EXISTS "Admins can manage note permissions" ON student_note_permissions;

-- Recreate policies
CREATE POLICY "Students can view their note permissions"
  ON student_note_permissions
  FOR SELECT
  TO authenticated
  USING (
    group_name IS NOT NULL
    OR
    student_id IN (
      SELECT id FROM students WHERE auth_user_id = auth.uid()
    )
  );

CREATE POLICY "Admins can manage note permissions"
  ON student_note_permissions
  FOR ALL
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM admin_accounts 
      WHERE email = (SELECT email FROM auth.users WHERE id = auth.uid())
    )
  )
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM admin_accounts 
      WHERE email = (SELECT email FROM auth.users WHERE id = auth.uid())
    )
  );

-- ========================================
-- 2. STUDENT_NOTES TABLE
-- ========================================

DROP POLICY IF EXISTS "Students can view accessible notes" ON student_notes;
DROP POLICY IF EXISTS "Admins can manage student notes" ON student_notes;

CREATE POLICY "Students can view accessible notes"
  ON student_notes
  FOR SELECT
  TO authenticated
  USING (
    id IN (
      SELECT note_id FROM student_note_permissions 
      WHERE is_accessible = true
      AND (
        student_id IN (SELECT id FROM students WHERE auth_user_id = auth.uid())
        OR group_name IN (SELECT group_name FROM students WHERE auth_user_id = auth.uid())
      )
    )
  );

CREATE POLICY "Admins can manage student notes"
  ON student_notes
  FOR ALL
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM admin_accounts 
      WHERE email = (SELECT email FROM auth.users WHERE id = auth.uid())
    )
  )
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM admin_accounts 
      WHERE email = (SELECT email FROM auth.users WHERE id = auth.uid())
    )
  );

-- ========================================
-- 3. STUDENTS TABLE
-- ========================================

DROP POLICY IF EXISTS "Students can view own profile" ON students;
DROP POLICY IF EXISTS "Admins can view all students" ON students;
DROP POLICY IF EXISTS "Admins can manage students" ON students;

CREATE POLICY "Students can view own profile"
  ON students
  FOR SELECT
  TO authenticated
  USING (auth_user_id = auth.uid());

CREATE POLICY "Admins can view all students"
  ON students
  FOR SELECT
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM admin_accounts 
      WHERE email = (SELECT email FROM auth.users WHERE id = auth.uid())
    )
  );

CREATE POLICY "Admins can manage students"
  ON students
  FOR ALL
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM admin_accounts 
      WHERE email = (SELECT email FROM auth.users WHERE id = auth.uid())
    )
  )
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM admin_accounts 
      WHERE email = (SELECT email FROM auth.users WHERE id = auth.uid())
    )
  );

-- ========================================
-- SUCCESS MESSAGE
-- ========================================

DO $$
BEGIN
  RAISE NOTICE '✅ All RLS policies restored successfully!';
END $$;
