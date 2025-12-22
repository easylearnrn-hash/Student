-- ============================================================
-- DIAGNOSE ANAHIT HOVHANNISYAN ACCOUNT ISSUE
-- Email: anahit3434@gmail.com
-- Issue: System logs out when trying to sign in
-- ============================================================

-- 1. Check if student record exists
SELECT 
  id,
  name,
  email,
  group_name,
  status,
  show_in_grid,
  auth_user_id,
  created_at
FROM students
WHERE email ILIKE '%anahit3434@gmail.com%'
   OR name ILIKE '%Anahit%Hovhannisyan%'
   OR name ILIKE '%Hovhannisyan%';

-- 2. Check auth.users table for this email
SELECT 
  id as auth_user_id,
  email,
  email_confirmed_at,
  created_at,
  last_sign_in_at,
  confirmed_at,
  deleted_at,
  is_sso_user,
  raw_app_meta_data,
  raw_user_meta_data
FROM auth.users
WHERE email ILIKE '%anahit3434@gmail.com%';

-- 3. Check if there's a mismatch between student record and auth record
SELECT 
  s.id as student_id,
  s.name as student_name,
  s.email as student_email,
  s.auth_user_id as linked_auth_id,
  au.id as actual_auth_id,
  au.email as auth_email,
  au.email_confirmed_at,
  CASE 
    WHEN s.auth_user_id IS NULL THEN '❌ No auth_user_id linked'
    WHEN s.auth_user_id != au.id THEN '⚠️ Mismatched auth_user_id'
    WHEN au.email_confirmed_at IS NULL THEN '⚠️ Email not confirmed'
    WHEN au.deleted_at IS NOT NULL THEN '❌ Auth account deleted'
    ELSE '✅ Properly linked'
  END as status
FROM students s
LEFT JOIN auth.users au ON au.email = s.email
WHERE s.email ILIKE '%anahit3434@gmail.com%'
   OR s.name ILIKE '%Anahit%Hovhannisyan%';

-- 4. Check recent session logs for this student
SELECT 
  sl.id,
  sl.student_id,
  s.name as student_name,
  s.email,
  sl.session_start,
  sl.session_end,
  sl.pages_viewed,
  sl.is_active
FROM session_logs sl
JOIN students s ON s.id = sl.student_id
WHERE s.email ILIKE '%anahit3434@gmail.com%'
   OR s.name ILIKE '%Anahit%Hovhannisyan%'
ORDER BY sl.session_start DESC
LIMIT 10;

-- 5. Check active student sessions
SELECT 
  ss.id,
  ss.student_id,
  s.name as student_name,
  s.email,
  ss.last_activity,
  ss.is_active,
  ss.created_at
FROM student_sessions ss
JOIN students s ON s.id = ss.student_id
WHERE s.email ILIKE '%anahit3434@gmail.com%'
   OR s.name ILIKE '%Anahit%Hovhannisyan%'
ORDER BY ss.last_activity DESC;

-- 6. Check if email exists in student_waiting_list (possible duplicate)
SELECT *
FROM student_waiting_list
WHERE email ILIKE '%anahit3434@gmail.com%';

-- ============================================================
-- COMMON FIXES:
-- ============================================================

-- FIX 1: If student exists but auth_user_id is NULL or wrong
/*
-- First, get the correct auth.users id
SELECT id FROM auth.users WHERE email = 'anahit3434@gmail.com';

-- Then update the student record (replace 'CORRECT_AUTH_ID' with actual ID)
UPDATE students 
SET auth_user_id = 'CORRECT_AUTH_ID'
WHERE email = 'anahit3434@gmail.com';
*/

-- FIX 2: If email not confirmed in auth.users
/*
UPDATE auth.users
SET email_confirmed_at = NOW(),
    confirmed_at = NOW()
WHERE email = 'anahit3434@gmail.com';
*/

-- FIX 3: If student record doesn't exist but auth account does
/*
-- Create student record linked to auth account
INSERT INTO students (
  name,
  email,
  auth_user_id,
  show_in_grid,
  status
)
VALUES (
  'Anahit Hovhannisyan',
  'anahit3434@gmail.com',
  (SELECT id FROM auth.users WHERE email = 'anahit3434@gmail.com'),
  true,
  'active'
);
*/

-- FIX 4: Clear any stuck sessions
/*
-- Deactivate all active sessions
UPDATE student_sessions
SET is_active = false
WHERE student_id IN (
  SELECT id FROM students WHERE email = 'anahit3434@gmail.com'
);
*/

-- FIX 5: If auth account doesn't exist at all
/*
-- User needs to complete signup at student portal
-- Send them this link: [YOUR_STUDENT_PORTAL_URL]
-- They should use email: anahit3434@gmail.com
-- They'll receive a confirmation email from Supabase
*/
