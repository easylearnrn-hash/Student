-- Fix RLS policies for alert responses view
-- This allows admins to query student_alerts with student data

-- Drop existing admin policy if it exists
DROP POLICY IF EXISTS "Admin full access to alerts" ON student_alerts;

-- Create new admin policy that works with joins
CREATE POLICY "Admin full access to alerts"
  ON student_alerts
  FOR ALL
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM admin_accounts
      WHERE email = auth.jwt() ->> 'email'
    )
  )
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM admin_accounts
      WHERE email = auth.jwt() ->> 'email'
    )
  );

-- Verify the policy was created
SELECT 
  schemaname,
  tablename,
  policyname,
  permissive,
  roles,
  cmd
FROM pg_policies 
WHERE tablename = 'student_alerts';
