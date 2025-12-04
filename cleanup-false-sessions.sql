-- ============================================================================
-- CLEAN ALL SESSIONS - Full Reset for Accurate Student Tracking
-- ============================================================================
-- This script completely clears all session data to ensure accurate tracking
-- Run this in Supabase SQL Editor to reset the student_sessions table
-- ============================================================================

-- STEP 1: View what will be deleted (OPTIONAL - for verification)
SELECT 
  COUNT(*) as total_sessions,
  COUNT(DISTINCT student_id) as students_with_sessions,
  SUM(CASE WHEN is_active = true THEN 1 ELSE 0 END) as active_sessions
FROM student_sessions;

-- STEP 2: Delete ALL sessions (complete reset)
DELETE FROM student_sessions;

-- STEP 3: Verify the table is empty
SELECT COUNT(*) as remaining_sessions FROM student_sessions;

-- ============================================================================
-- Expected Result: 0 remaining_sessions
-- After this cleanup, only REAL student logins will create sessions
-- Admin impersonation will NOT create sessions (already fixed in code)
-- ============================================================================
