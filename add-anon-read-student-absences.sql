-- Add anonymous read policy for student_absences table
-- This allows the student portal (using anon key in impersonation mode) to check absences

-- Drop existing policy if it exists
DROP POLICY IF EXISTS "Allow anon read for impersonation" ON student_absences;

-- Create new policy allowing anon users to read all student_absences records
-- This mirrors the pattern used in other tables for impersonation support
CREATE POLICY "Allow anon read for impersonation"
ON student_absences
FOR SELECT
TO anon
USING (true);

-- Verify the policy was created
SELECT 
  tablename,
  policyname,
  permissive,
  roles,
  cmd,
  qual
FROM pg_policies 
WHERE tablename = 'student_absences'
ORDER BY policyname;
