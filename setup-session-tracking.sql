-- ============================================================
-- COMPREHENSIVE SESSION TRACKING SYSTEM
-- ============================================================
-- This creates detailed session monitoring for students
-- Tracks: login time, logout time, duration, page views, etc.

-- Create session_logs table for detailed tracking
CREATE TABLE IF NOT EXISTS public.session_logs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  student_id INTEGER REFERENCES students(id) ON DELETE CASCADE,
  session_start TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  session_end TIMESTAMPTZ,
  duration_seconds INTEGER GENERATED ALWAYS AS (
    CASE 
      WHEN session_end IS NOT NULL 
      THEN EXTRACT(EPOCH FROM (session_end - session_start))::INTEGER
      ELSE NULL
    END
  ) STORED,
  last_activity TIMESTAMPTZ DEFAULT NOW(),
  ip_address TEXT,
  user_agent TEXT,
  pages_viewed JSONB DEFAULT '[]'::jsonb,
  total_page_views INTEGER DEFAULT 0,
  notes_accessed JSONB DEFAULT '[]'::jsonb,
  total_notes_viewed INTEGER DEFAULT 0,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Add indexes for performance
CREATE INDEX IF NOT EXISTS idx_session_logs_student ON session_logs(student_id);
CREATE INDEX IF NOT EXISTS idx_session_logs_active ON session_logs(is_active);
CREATE INDEX IF NOT EXISTS idx_session_logs_start ON session_logs(session_start DESC);

-- Create view for session statistics
CREATE OR REPLACE VIEW student_session_stats AS
SELECT 
  s.id as student_id,
  s.name as student_name,
  s.email,
  COUNT(sl.id) as total_sessions,
  SUM(sl.duration_seconds) as total_seconds,
  ROUND(SUM(sl.duration_seconds) / 3600.0, 2) as total_hours,
  ROUND(AVG(sl.duration_seconds) / 60.0, 2) as avg_session_minutes,
  MAX(sl.session_start) as last_login,
  MAX(sl.last_activity) as last_activity,
  SUM(sl.total_page_views) as total_page_views,
  SUM(sl.total_notes_viewed) as total_notes_viewed,
  -- Current session info
  (SELECT is_active FROM session_logs WHERE student_id = s.id ORDER BY session_start DESC LIMIT 1) as currently_online,
  (SELECT session_start FROM session_logs WHERE student_id = s.id AND is_active = true ORDER BY session_start DESC LIMIT 1) as current_session_start
FROM students s
LEFT JOIN session_logs sl ON s.id = sl.student_id
GROUP BY s.id, s.name, s.email;

-- Add RLS policies
ALTER TABLE session_logs ENABLE ROW LEVEL SECURITY;

-- Students can only see their own sessions
CREATE POLICY "Students can view own sessions"
  ON session_logs FOR SELECT
  USING (student_id IN (SELECT id FROM students WHERE auth_user_id::text = auth.uid()::text));

-- Students can insert their own sessions
CREATE POLICY "Students can create own sessions"
  ON session_logs FOR INSERT
  WITH CHECK (student_id IN (SELECT id FROM students WHERE auth_user_id::text = auth.uid()::text));

-- Students can update their own active sessions
CREATE POLICY "Students can update own sessions"
  ON session_logs FOR UPDATE
  USING (student_id IN (SELECT id FROM students WHERE auth_user_id::text = auth.uid()::text));

-- Admins can see all sessions
CREATE POLICY "Admins can view all sessions"
  ON session_logs FOR SELECT
  USING (EXISTS (SELECT 1 FROM admin_accounts WHERE email = auth.jwt()->>'email'));

-- Grant permissions
GRANT SELECT, INSERT, UPDATE ON session_logs TO authenticated;
GRANT SELECT ON student_session_stats TO authenticated;

-- Function to automatically end sessions after inactivity
CREATE OR REPLACE FUNCTION end_inactive_sessions()
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  UPDATE session_logs
  SET is_active = false,
      session_end = last_activity
  WHERE is_active = true
    AND last_activity < NOW() - INTERVAL '30 minutes';
END;
$$;

-- Create a function to track page views
CREATE OR REPLACE FUNCTION log_page_view(
  p_session_id UUID,
  p_page_name TEXT
)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  UPDATE session_logs
  SET 
    pages_viewed = pages_viewed || jsonb_build_object(
      'page', p_page_name,
      'timestamp', NOW()
    ),
    total_page_views = total_page_views + 1,
    last_activity = NOW()
  WHERE id = p_session_id;
END;
$$;

-- Create a function to track note access
CREATE OR REPLACE FUNCTION log_note_access(
  p_session_id UUID,
  p_note_id INTEGER,
  p_note_title TEXT
)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  UPDATE session_logs
  SET 
    notes_accessed = notes_accessed || jsonb_build_object(
      'note_id', p_note_id,
      'note_title', p_note_title,
      'timestamp', NOW()
    ),
    total_notes_viewed = total_notes_viewed + 1,
    last_activity = NOW()
  WHERE id = p_session_id;
END;
$$;

COMMENT ON TABLE session_logs IS 'Detailed session tracking for student portal usage monitoring';
COMMENT ON VIEW student_session_stats IS 'Aggregated session statistics per student';
