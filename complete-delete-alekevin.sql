-- ========================================================
-- COMPLETE DELETION: alekevin@gmail.com
-- ========================================================
-- This removes ALL data associated with this user
-- ========================================================

-- Step 1: Delete test attempts
DELETE FROM test_attempts
WHERE student_id IN (
  SELECT s.id FROM students s
  INNER JOIN auth.users au ON s.auth_user_id = au.id
  WHERE au.email = 'alekevin@gmail.com'
);

-- Step 2: Delete test reactions
DELETE FROM test_reactions
WHERE student_id IN (
  SELECT s.id FROM students s
  INNER JOIN auth.users au ON s.auth_user_id = au.id
  WHERE au.email = 'alekevin@gmail.com'
);

-- Step 3: Delete payment records
DELETE FROM payment_records
WHERE student_id IN (
  SELECT s.id FROM students s
  INNER JOIN auth.users au ON s.auth_user_id = au.id
  WHERE au.email = 'alekevin@gmail.com'
);

-- Step 4: Delete payments (Zelle)
DELETE FROM payments
WHERE student_id IN (
  SELECT s.id FROM students s
  INNER JOIN auth.users au ON s.auth_user_id = au.id
  WHERE au.email = 'alekevin@gmail.com'
);

-- Step 5: Delete student notes
DELETE FROM student_notes
WHERE student_id IN (
  SELECT s.id FROM students s
  INNER JOIN auth.users au ON s.auth_user_id = au.id
  WHERE au.email = 'alekevin@gmail.com'
);

-- Step 6: Delete session tracking
DELETE FROM study_sessions
WHERE student_id IN (
  SELECT s.id FROM students s
  INNER JOIN auth.users au ON s.auth_user_id = au.id
  WHERE au.email = 'alekevin@gmail.com'
);

-- Step 7: Delete from admin_accounts (if exists)
DELETE FROM admin_accounts
WHERE auth_user_id IN (
  SELECT id FROM auth.users WHERE email = 'alekevin@gmail.com'
);

-- Step 8: Delete the student record
DELETE FROM students
WHERE auth_user_id IN (
  SELECT id FROM auth.users WHERE email = 'alekevin@gmail.com'
);

-- Step 9: Verify everything is deleted
SELECT 
  (SELECT COUNT(*) FROM students WHERE auth_user_id IN (SELECT id FROM auth.users WHERE email = 'alekevin@gmail.com')) as students_remaining,
  (SELECT COUNT(*) FROM admin_accounts WHERE auth_user_id IN (SELECT id FROM auth.users WHERE email = 'alekevin@gmail.com')) as admin_remaining,
  (SELECT COUNT(*) FROM test_attempts WHERE student_id IN (SELECT s.id FROM students s INNER JOIN auth.users au ON s.auth_user_id = au.id WHERE au.email = 'alekevin@gmail.com')) as attempts_remaining,
  (SELECT COUNT(*) FROM payment_records WHERE student_id IN (SELECT s.id FROM students s INNER JOIN auth.users au ON s.auth_user_id = au.id WHERE au.email = 'alekevin@gmail.com')) as payments_remaining;

-- All counts should be 0
-- Now you can delete from: Authentication → Users → alekevin@gmail.com → Delete
