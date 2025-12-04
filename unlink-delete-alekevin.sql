-- ========================================================
-- AUTO UNLINK AND DELETE: alekevin@gmail.com
-- ========================================================
-- Run this entire script to automatically unlink and allow deletion
-- ========================================================

-- Unlink from students table
UPDATE students
SET auth_user_id = NULL
WHERE auth_user_id IN (
  SELECT id FROM auth.users WHERE email = 'alekevin@gmail.com'
);

-- Remove from admin_accounts table
DELETE FROM admin_accounts
WHERE auth_user_id IN (
  SELECT id FROM auth.users WHERE email = 'alekevin@gmail.com'
);

-- Verify unlinked (should return 0 and 0)
SELECT 
  (SELECT COUNT(*) FROM students WHERE auth_user_id IN (SELECT id FROM auth.users WHERE email = 'alekevin@gmail.com')) as students_still_linked,
  (SELECT COUNT(*) FROM admin_accounts WHERE auth_user_id IN (SELECT id FROM auth.users WHERE email = 'alekevin@gmail.com')) as admin_still_linked;

-- Now go to Authentication → Users → alekevin@gmail.com → Delete
