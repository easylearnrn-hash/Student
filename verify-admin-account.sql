-- ========================================
-- VERIFY: Your Auth UID is in admin_accounts
-- ========================================

-- Check all admin accounts
SELECT 
  auth_user_id,
  email
FROM admin_accounts;

-- If you see your email but the auth_user_id looks wrong,
-- or if you DON'T see your account at all, run this:

-- Option 1: Check what email you're logged in with
-- (Run this in browser console on Calendar.html page):
/*
console.log('My email:', await supabase.auth.getUser());
*/

-- Option 2: Manually add your auth_user_id to admin_accounts
-- First, find your auth_user_id from the auth.users table
-- (Service role can query this):
SELECT id, email FROM auth.users WHERE email LIKE '%festa%' OR email LIKE '%arnoma%';

-- Then insert/update admin_accounts with the correct auth_user_id:
-- (Replace 'YOUR-UUID-HERE' and 'your-email@gmail.com' with actual values)
/*
INSERT INTO admin_accounts (auth_user_id, email)
VALUES ('YOUR-UUID-HERE', 'your-email@gmail.com')
ON CONFLICT (auth_user_id) DO UPDATE SET email = EXCLUDED.email;
*/
