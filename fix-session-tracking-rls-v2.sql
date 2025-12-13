-- ============================================================
-- FIX SESSION TRACKING RLS POLICIES
-- ============================================================
-- This fixes permission issues preventing students from tracking sessions

-- Ensure table exists
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

-- Drop ALL existing policies (clean slate)
DROP POLICY IF EXISTS "Admins have full access to student_sessions" ON student_sessions;
DROP POLICY IF EXISTS "Students can manage their own sessions" ON student_sessions;
DROP POLICY IF EXISTS "Students can insert own sessions" ON student_sessions;
DROP POLICY IF EXISTS "Students can update own sessions" ON student_sessions;
DROP POLICY IF EXISTS "Students can view own sessions" ON student_sessions;
DROP POLICY IF EXISTS "Admins full access" ON student_sessions;

-- ============================================================
-- NEW SIMPLIFIED POLICIES
-- ============================================================

-- Policy 1: Admins can do EVERYTHING
CREATE POLICY "Admins full access to student_sessions"
  ON student_sessions
  FOR ALL
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM admin_accounts
      WHERE email = auth.email()
      AND is_active = true
    )
  )
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM admin_accounts
      WHERE email = auth.email()
      AND is_active = true
    )
  );

-- Policy 2: Students can INSERT their own sessions
CREATE POLICY "Students can insert own sessions"
  ON student_sessions
  FOR INSERT
  TO authenticated
  WITH CHECK (
    student_id IN (
      SELECT id FROM students
      WHERE email = auth.email()
    )
  );

-- Policy 3: Students can UPDATE their own sessions
CREATE POLICY "Students can update own sessions"
  ON student_sessions
  FOR UPDATE
  TO authenticated
  USING (
    student_id IN (
      SELECT id FROM students
      WHERE email = auth.email()
    )
  )
  WITH CHECK (
    student_id IN (
      SELECT id FROM students
      WHERE email = auth.email()
    )
  );

-- Policy 4: Students can VIEW their own sessions
CREATE POLICY "Students can view own sessions"
  ON student_sessions
  FOR SELECT
  TO authenticated
  USING (
    student_id IN (
      SELECT id FROM students
      WHERE email = auth.email()
    )
  );

-- ============================================================
-- AUTOMATIC SESSION CLEANUP FUNCTION
-- ============================================================
-- This automatically marks sessions as inactive after 10 minutes of no activity

CREATE OR REPLACE FUNCTION cleanup_inactive_sessions()
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  UPDATE student_sessions
  SET 
    is_active = false,
    session_end = last_activity
  WHERE 
    is_active = true
    AND last_activity < NOW() - INTERVAL '10 minutes';
END;
$$;

-- Create a cron job to run cleanup every 5 minutes (requires pg_cron extension)
-- If you don't have pg_cron, you can call this manually or from an edge function
-- SELECT cron.schedule('cleanup-sessions', '*/5 * * * *', 'SELECT cleanup_inactive_sessions()');

-- ============================================================
-- TEST QUERIES
-- ============================================================

-- Check if policies are working
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

-- See current active sessions
SELECT 
  s.name as student_name,
  ss.session_start,
  ss.last_activity,
  ss.is_active,
  EXTRACT(EPOCH FROM (NOW() - ss.last_activity)) / 60 as minutes_since_activity
FROM student_sessions ss
JOIN students s ON s.id = ss.student_id
WHERE ss.is_active = true
ORDER BY ss.last_activity DESC;
