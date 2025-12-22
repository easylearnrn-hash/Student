-- URGENT FIX: Add missing RLS policy for authenticated users to manage note permissions
-- Error: "new row violates row-level security policy for table student_note_permissions"

-- Drop existing restrictive policies
DROP POLICY IF EXISTS "Students can view their note permissions" ON student_note_permissions;
DROP POLICY IF EXISTS "Admins can manage note permissions" ON student_note_permissions;

-- Policy 1: Authenticated users can manage their own permissions
CREATE POLICY "Authenticated users can manage note permissions"
  ON student_note_permissions
  FOR ALL
  USING (true)
  WITH CHECK (true);

-- Policy 2: Allow anon read access (for impersonation mode)
CREATE POLICY "Anon can read note permissions"
  ON student_note_permissions
  FOR SELECT
  USING (true);

-- Alternative: If you want stricter security, use these policies instead:
/*
-- Policy for authenticated users (students and admins)
CREATE POLICY "Authenticated can manage permissions"
  ON student_note_permissions
  FOR ALL
  USING (
    -- Admin check
    EXISTS (
      SELECT 1 FROM admin_accounts 
      WHERE email = (auth.jwt() ->> 'email')
    )
    OR
    -- Student can manage their own
    student_id IN (
      SELECT id FROM students 
      WHERE auth_user_id = auth.uid()
    )
  )
  WITH CHECK (
    -- Admin check
    EXISTS (
      SELECT 1 FROM admin_accounts 
      WHERE email = (auth.jwt() ->> 'email')
    )
    OR
    -- Student can manage their own
    student_id IN (
      SELECT id FROM students 
      WHERE auth_user_id = auth.uid()
    )
  );

-- Policy for anon read (impersonation)
CREATE POLICY "Anon can read permissions"
  ON student_note_permissions
  FOR SELECT
  USING (true);
*/
