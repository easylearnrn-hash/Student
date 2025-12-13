-- ============================================================
-- IMMEDIATE CLEANUP OF STALE SESSIONS
-- ============================================================
-- This will fix all the old sessions showing as "active"

-- Step 1: Mark ALL sessions older than 10 minutes as inactive
UPDATE student_sessions
SET 
  is_active = false,
  session_end = last_activity
WHERE 
  is_active = true
  AND last_activity < NOW() - INTERVAL '10 minutes';

-- Step 2: Verify the cleanup worked
SELECT 
  'After cleanup' as status,
  COUNT(*) FILTER (WHERE is_active = true) as active_sessions,
  COUNT(*) FILTER (WHERE is_active = false) as inactive_sessions,
  COUNT(*) as total_sessions
FROM student_sessions;

-- Step 3: Show currently active sessions (should only be sessions from last 10 minutes)
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

-- ============================================================
-- AUTOMATIC CLEANUP FUNCTION (improved)
-- ============================================================

CREATE OR REPLACE FUNCTION cleanup_inactive_sessions()
RETURNS TABLE(sessions_cleaned INTEGER)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  cleaned_count INTEGER;
BEGIN
  -- Mark sessions older than 10 minutes as inactive
  UPDATE student_sessions
  SET 
    is_active = false,
    session_end = COALESCE(session_end, last_activity)
  WHERE 
    is_active = true
    AND last_activity < NOW() - INTERVAL '10 minutes';
  
  GET DIAGNOSTICS cleaned_count = ROW_COUNT;
  
  RETURN QUERY SELECT cleaned_count;
END;
$$;

-- Test the function
SELECT * FROM cleanup_inactive_sessions();

-- ============================================================
-- NOTES:
-- ============================================================
-- This cleanup function should be called regularly. Options:
-- 
-- Option 1: Supabase Edge Function (recommended)
--   Create an edge function that calls this every 5 minutes
--   using Supabase's cron trigger
--
-- Option 2: Application-level (current implementation)
--   Student portal heartbeat calls this during session updates
--
-- Option 3: Database trigger
--   Automatically run on INSERT/UPDATE to student_sessions table
