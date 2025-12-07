-- Fix student_sessions RLS policy - remove auth.users table access
-- The error "permission denied for table users" means the policy is trying to access auth.users
-- which students don't have permission for

-- Drop the old policy
DROP POLICY IF EXISTS "Students can create own sessions" ON student_sessions;

-- Recreate without auth.users dependency
CREATE POLICY "Students can create own sessions"
ON student_sessions
FOR INSERT
TO authenticated
WITH CHECK (
  -- Allow insert if the student_id matches a student record with this auth user
  student_id IN (
    SELECT id FROM students WHERE auth_user_id = auth.uid()
  )
);

-- Also update the update policy
DROP POLICY IF EXISTS "Students can update own sessions" ON student_sessions;

CREATE POLICY "Students can update own sessions"
ON student_sessions
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
