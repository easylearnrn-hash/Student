-- Emergency fix for Group Notes permissions
-- This restores RLS policies that got broken

-- 1. Fix student_note_permissions policies
DROP POLICY IF EXISTS "Students can view their note permissions" ON student_note_permissions;
DROP POLICY IF EXISTS "Admins can manage note permissions" ON student_note_permissions;

-- Allow students to read permissions for their group or individual access
CREATE POLICY "Students can view their note permissions"
  ON student_note_permissions
  FOR SELECT
  USING (
    -- Students can see group permissions
    group_name IS NOT NULL
    OR
    -- Or their individual permissions
    student_id IN (
      SELECT id FROM students WHERE auth_user_id = auth.uid()
    )
  );

-- Allow admins to do everything
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

-- 2. Make sure student_notes is accessible
DROP POLICY IF EXISTS "Admins can manage student notes" ON student_notes;

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

-- 3. Make sure students table is readable by admins
DROP POLICY IF EXISTS "Admins can view all students" ON students;

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
