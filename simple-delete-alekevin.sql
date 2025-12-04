-- ========================================================
-- SIMPLE DELETION: alekevin@gmail.com
-- ========================================================
-- Only deletes from tables that exist in your database
-- ========================================================

-- Step 1: Delete from admin_accounts (if exists)
DELETE FROM admin_accounts
WHERE auth_user_id IN (
  SELECT id FROM auth.users WHERE email = 'alekevin@gmail.com'
);

-- Step 2: Delete payment records (if linked by student_id)
DELETE FROM payment_records
WHERE student_id::text IN (
  SELECT id::text FROM students WHERE email = 'alekevin@gmail.com'
);

-- Step 3: Delete payments (Zelle - if linked by student_id or student_name)
DELETE FROM payments
WHERE student_id::text IN (
  SELECT id::text FROM students WHERE email = 'alekevin@gmail.com'
)
OR resolved_student_name IN (
  SELECT name FROM students WHERE email = 'alekevin@gmail.com'
);

-- Step 4: Delete the student record
DELETE FROM students
WHERE email = 'alekevin@gmail.com';

-- Step 6: Verify everything is deleted (should all be 0)
SELECT 
  (SELECT COUNT(*) FROM students WHERE email = 'alekevin@gmail.com') as students_remaining,
  (SELECT COUNT(*) FROM admin_accounts WHERE auth_user_id IN (SELECT id FROM auth.users WHERE email = 'alekevin@gmail.com')) as admin_remaining;

-- Now delete from: Authentication → Users → alekevin@gmail.com → Delete
