-- Student Sessions Tracking Table
-- Run this SQL in Supabase SQL Editor to enable online status tracking

-- Create student_sessions table
CREATE TABLE IF NOT EXISTS student_sessions (
  id BIGSERIAL PRIMARY KEY,
  student_id BIGINT REFERENCES students(id) ON DELETE CASCADE,
  session_start TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  session_end TIMESTAMPTZ,
  last_activity TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  is_active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Add indexes for better performance
CREATE INDEX IF NOT EXISTS idx_student_sessions_student_id ON student_sessions(student_id);
CREATE INDEX IF NOT EXISTS idx_student_sessions_is_active ON student_sessions(is_active);
CREATE INDEX IF NOT EXISTS idx_student_sessions_last_activity ON student_sessions(last_activity);

-- Enable RLS
ALTER TABLE student_sessions ENABLE ROW LEVEL SECURITY;

-- Policy: Admins can do everything
CREATE POLICY "Admins have full access to student_sessions"
  ON student_sessions
  FOR ALL
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM admin_accounts
      WHERE admin_accounts.email = auth.jwt() ->> 'email'
    )
  );

-- Policy: Students can view/update their own sessions
CREATE POLICY "Students can manage their own sessions"
  ON student_sessions
  FOR ALL
  TO authenticated
  USING (
    student_id IN (
      SELECT id FROM students
      WHERE students.auth_user_id = auth.uid()
    )
  );

-- Function to auto-update updated_at timestamp
CREATE OR REPLACE FUNCTION update_student_sessions_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger to auto-update updated_at
CREATE TRIGGER student_sessions_updated_at
  BEFORE UPDATE ON student_sessions
  FOR EACH ROW
  EXECUTE FUNCTION update_student_sessions_updated_at();

-- Function to mark old sessions as inactive (sessions idle > 30 minutes)
CREATE OR REPLACE FUNCTION cleanup_inactive_sessions()
RETURNS void AS $$
BEGIN
  UPDATE student_sessions
  SET is_active = FALSE,
      session_end = last_activity
  WHERE is_active = TRUE
    AND last_activity < NOW() - INTERVAL '30 minutes';
END;
$$ LANGUAGE plpgsql;

COMMENT ON TABLE student_sessions IS 'Tracks student login sessions and activity for online status';
COMMENT ON COLUMN student_sessions.last_activity IS 'Updated via heartbeat every 2 minutes while student is active';
COMMENT ON COLUMN student_sessions.is_active IS 'Auto-set to false if no activity for 30+ minutes';
