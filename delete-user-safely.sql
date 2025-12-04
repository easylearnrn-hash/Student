-- ========================================================
-- SAFE USER DELETION SCRIPT
-- ========================================================
-- This script safely removes a user by:
-- 1. Finding the auth user ID
-- 2. Unlinking from students table
-- 3. Unlinking from admin_accounts table
-- 4. Removing any other dependencies
-- 5. Then you can delete from Supabase Auth UI
-- ========================================================

-- STEP 1: Find the user's UUID in auth.users
SELECT 
  id as auth_user_id,
  email,
  created_at,
  email_confirmed_at
FROM auth.users
WHERE email = 'alekevin@gmail.com';

-- Copy the auth_user_id from above, then run the queries below

-- ========================================================
-- STEP 2: Check what's linked to this user
-- ========================================================

-- Check students table
SELECT 
  id,
  name,
  email,
  auth_user_id,
  '🔗 LINKED TO AUTH' as status
FROM students
WHERE auth_user_id = 'PASTE_AUTH_USER_ID_HERE';

-- Check admin_accounts table
SELECT 
  id,
  email,
  auth_user_id,
  '🔗 LINKED TO AUTH' as status
FROM admin_accounts
WHERE auth_user_id = 'PASTE_AUTH_USER_ID_HERE';

-- Check test_attempts (student test history)
SELECT COUNT(*) as attempt_count
FROM test_attempts
WHERE student_id IN (
  SELECT id FROM students WHERE auth_user_id = 'PASTE_AUTH_USER_ID_HERE'
);

-- Check payment_records
SELECT COUNT(*) as payment_count
FROM payment_records
WHERE student_id IN (
  SELECT id FROM students WHERE auth_user_id = 'PASTE_AUTH_USER_ID_HERE'
);

-- ========================================================
-- STEP 3: UNLINK THE USER (Choose your action)
-- ========================================================

-- OPTION A: Just unlink auth (keeps student record but removes login ability)
-- This is SAFER - student data stays intact, they just can't log in
UPDATE students
SET auth_user_id = NULL
WHERE auth_user_id = 'PASTE_AUTH_USER_ID_HERE';

-- OPTION B: Remove from admin_accounts (if they're an admin)
DELETE FROM admin_accounts
WHERE auth_user_id = 'PASTE_AUTH_USER_ID_HERE';

-- ========================================================
-- STEP 4: OPTIONAL - Delete student record entirely
-- ========================================================
-- ⚠️ WARNING: This deletes ALL student data (payments, tests, etc.)
-- Only do this if you're absolutely sure!

-- First, delete related records (in order due to foreign keys)
/*
-- Delete test attempts
DELETE FROM test_attempts
WHERE student_id IN (
  SELECT id FROM students WHERE auth_user_id = 'PASTE_AUTH_USER_ID_HERE'
);

-- Delete payment records
DELETE FROM payment_records
WHERE student_id IN (
  SELECT id FROM students WHERE auth_user_id = 'PASTE_AUTH_USER_ID_HERE'
);

-- Delete student notes assignments
DELETE FROM student_notes
WHERE student_id IN (
  SELECT id FROM students WHERE auth_user_id = 'PASTE_AUTH_USER_ID_HERE'
);

-- Finally, delete the student record
DELETE FROM students
WHERE auth_user_id = 'PASTE_AUTH_USER_ID_HERE';
*/

-- ========================================================
-- STEP 5: Verify user is unlinked
-- ========================================================
SELECT 
  (SELECT COUNT(*) FROM students WHERE auth_user_id = 'PASTE_AUTH_USER_ID_HERE') as students_linked,
  (SELECT COUNT(*) FROM admin_accounts WHERE auth_user_id = 'PASTE_AUTH_USER_ID_HERE') as admin_accounts_linked;

-- If both return 0, you can now safely delete the user from:
-- Supabase Dashboard → Authentication → Users → [select user] → Delete
