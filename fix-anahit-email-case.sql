-- ============================================================
-- FIX ANAHIT'S ACCOUNT - Email Case Mismatch
-- ============================================================

-- Step 1: Verify the auth account exists with lowercase email
SELECT 
  id as auth_user_id,
  email,
  email_confirmed_at,
  last_sign_in_at
FROM auth.users
WHERE email = 'anahit3434@gmail.com';  -- lowercase

-- Step 2: Update student record to use lowercase email (to match auth)
UPDATE students
SET email = 'anahit3434@gmail.com'  -- lowercase
WHERE id = 73;

-- Step 3: Verify the link is now correct
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
    WHEN au.id IS NULL THEN '❌ No auth account found'
    ELSE '✅ Properly linked and confirmed'
  END as status
FROM students s
LEFT JOIN auth.users au ON LOWER(au.email) = LOWER(s.email)
WHERE s.id = 73;

-- Step 4: Clear any stuck sessions (just in case)
UPDATE student_sessions
SET is_active = false
WHERE student_id = 73;

-- Step 5: Confirm fix - this should now return the auth record
SELECT 
  s.id,
  s.name,
  s.email as student_email,
  s.auth_user_id,
  au.id as auth_id,
  au.email as auth_email,
  au.email_confirmed_at
FROM students s
JOIN auth.users au ON LOWER(au.email) = LOWER(s.email)
WHERE s.id = 73;
