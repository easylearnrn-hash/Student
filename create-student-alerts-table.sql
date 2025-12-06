-- Create student_alerts table for admin-to-student alert system
-- Run this in Supabase SQL Editor

CREATE TABLE IF NOT EXISTS student_alerts (
  id BIGSERIAL PRIMARY KEY,
  student_id BIGINT NOT NULL REFERENCES students(id) ON DELETE CASCADE,
  message TEXT NOT NULL,
  alert_type VARCHAR(20) DEFAULT 'info' CHECK (alert_type IN ('info', 'warning', 'urgent', 'success')),
  is_read BOOLEAN DEFAULT FALSE,
  expires_at TIMESTAMP WITH TIME ZONE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create index for faster queries
CREATE INDEX IF NOT EXISTS idx_student_alerts_student_id ON student_alerts(student_id);
CREATE INDEX IF NOT EXISTS idx_student_alerts_created_at ON student_alerts(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_student_alerts_is_read ON student_alerts(is_read);

-- Add RLS policies
ALTER TABLE student_alerts ENABLE ROW LEVEL SECURITY;

-- Policy: Admin can do everything
CREATE POLICY "Admin full access to alerts"
  ON student_alerts
  FOR ALL
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM admin_accounts
      WHERE email = auth.jwt() ->> 'email'
    )
  );

-- Policy: Students can view their own alerts
CREATE POLICY "Students can view their own alerts"
  ON student_alerts
  FOR SELECT
  TO authenticated
  USING (
    student_id IN (
      SELECT id FROM students
      WHERE email = auth.jwt() ->> 'email'
    )
  );

-- Policy: Students can mark their own alerts as read
CREATE POLICY "Students can update their own alerts"
  ON student_alerts
  FOR UPDATE
  TO authenticated
  USING (
    student_id IN (
      SELECT id FROM students
      WHERE email = auth.jwt() ->> 'email'
    )
  )
  WITH CHECK (
    student_id IN (
      SELECT id FROM students
      WHERE email = auth.jwt() ->> 'email'
    )
  );

-- Create function to auto-update updated_at timestamp
CREATE OR REPLACE FUNCTION update_student_alerts_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger to auto-update updated_at
CREATE TRIGGER update_student_alerts_timestamp
  BEFORE UPDATE ON student_alerts
  FOR EACH ROW
  EXECUTE FUNCTION update_student_alerts_updated_at();

-- Create function to clean up expired alerts (optional, run periodically)
CREATE OR REPLACE FUNCTION delete_expired_alerts()
RETURNS void AS $$
BEGIN
  DELETE FROM student_alerts
  WHERE expires_at IS NOT NULL
  AND expires_at < NOW();
END;
$$ LANGUAGE plpgsql;

-- Grant necessary permissions
GRANT ALL ON student_alerts TO authenticated;
GRANT ALL ON student_alerts TO service_role;
