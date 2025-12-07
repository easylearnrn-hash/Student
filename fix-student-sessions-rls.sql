-- Check student_sessions RLS policies
SELECT 
  schemaname,
  tablename,
  policyname,
  permissive,
  roles,
  cmd,
  qual
FROM pg_policies 
WHERE tablename = 'student_sessions';

-- If no policies exist, create them
-- Allow students to insert their own sessions
DROP POLICY IF EXISTS "Students can create own sessions" ON student_sessions;

CREATE POLICY "Students can create own sessions"
ON student_sessions
FOR INSERT
TO authenticated
WITH CHECK (
  student_id IN (
    SELECT id FROM students WHERE auth_user_id = auth.uid()
  )
);

-- Allow students to update their own sessions
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

-- Allow admins to view all sessions
DROP POLICY IF EXISTS "Admins can view all sessions" ON student_sessions;

CREATE POLICY "Admins can view all sessions"
ON student_sessions
FOR SELECT
TO authenticated
USING (
  EXISTS (
    SELECT 1 FROM admin_accounts
    WHERE admin_accounts.email = (
      SELECT email FROM auth.users WHERE id = auth.uid()
    )::text
  )
);
