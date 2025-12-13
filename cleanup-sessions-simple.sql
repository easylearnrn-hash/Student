-- ============================================================
-- CLEANUP STALE SESSIONS - SIMPLE VERSION
-- ============================================================
-- Run this to immediately fix all the old "active" sessions

-- Step 1: Mark ALL sessions older than 10 minutes as inactive
UPDATE student_sessions
SET 
  is_active = false,
  session_end = last_activity
WHERE 
  is_active = true
  AND last_activity < NOW() - INTERVAL '10 minutes';

-- Step 2: Show results
SELECT 
  COUNT(*) FILTER (WHERE is_active = true) as currently_active,
  COUNT(*) FILTER (WHERE is_active = false) as now_inactive,
  COUNT(*) as total_sessions
FROM student_sessions;

-- Step 3: Show who's actually online right now (last 10 minutes)
SELECT 
  s.name as student_name,
  ss.session_start,
  ss.last_activity,
  ROUND(EXTRACT(EPOCH FROM (NOW() - ss.last_activity)) / 60) as minutes_ago
FROM student_sessions ss
JOIN students s ON s.id = ss.student_id
WHERE ss.is_active = true
ORDER BY ss.last_activity DESC;
