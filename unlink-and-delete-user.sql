-- ============================================================
-- UNLINK AND PREPARE USER FOR DELETION
-- ============================================================
-- Run this to unlink the auth account from students table
-- so you can delete it from Supabase Auth Users panel
-- ============================================================

-- Step 1: Unlink the student record
UPDATE students 
SET auth_user_id = NULL 
WHERE email = 'hrachfilm@gmail.com';

-- Step 2: Verify the unlink (should show NULL for auth_user_id)
SELECT id, name, email, auth_user_id 
FROM students 
WHERE email = 'hrachfilm@gmail.com';

-- After running this, go back to Authentication → Users 
-- and you'll be able to delete the user successfully
