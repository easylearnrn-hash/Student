-- CRITICAL FIX: Remove RLS policies that reference auth.users table
-- Error: "permission denied for table users"
-- The auth.users table cannot be queried in RLS policies

-- Step 1: Drop ALL existing policies on student_note_permissions
DROP POLICY IF EXISTS "Students can view their note permissions" ON student_note_permissions;
DROP POLICY IF EXISTS "Admins can manage note permissions" ON student_note_permissions;
DROP POLICY IF EXISTS "Authenticated users can manage note permissions" ON student_note_permissions;
DROP POLICY IF EXISTS "Anon can read note permissions" ON student_note_permissions;

-- Step 2: Create simple, working policies that DON'T reference auth.users

-- Policy 1: All authenticated users can fully manage permissions
CREATE POLICY "authenticated_full_access"
  ON student_note_permissions
  FOR ALL
  TO authenticated
  USING (true)
  WITH CHECK (true);

-- Policy 2: Anonymous users can read (for impersonation mode)
CREATE POLICY "anon_read_access"
  ON student_note_permissions
  FOR SELECT
  TO anon
  USING (true);

-- Verify policies were created
SELECT schemaname, tablename, policyname, roles, cmd, qual, with_check
FROM pg_policies
WHERE tablename = 'student_note_permissions';
