-- ============================================================================
-- 🚨 FIX: Add hrachfilm@gmail.com to admin_accounts with correct auth_user_id
-- ============================================================================

-- STEP 1: Find your auth_user_id from the auth.users table
SELECT 
  id as "Your Auth User ID",
  email,
  created_at
FROM auth.users
WHERE email = 'hrachfilm@gmail.com';

-- STEP 2: Check what's currently in admin_accounts
SELECT * FROM admin_accounts WHERE email = 'hrachfilm@gmail.com';

-- STEP 3: Delete any broken entries
DELETE FROM admin_accounts WHERE email = 'hrachfilm@gmail.com' AND auth_user_id IS NULL;

-- STEP 4: Insert or update with the correct auth_user_id
INSERT INTO admin_accounts (auth_user_id, email)
SELECT 
  id,
  email
FROM auth.users
WHERE email = 'hrachfilm@gmail.com'
ON CONFLICT (auth_user_id) 
DO UPDATE SET email = EXCLUDED.email;

-- STEP 5: Verify it's fixed
SELECT 
  a.auth_user_id,
  a.email,
  u.email as "Auth Email",
  CASE 
    WHEN a.auth_user_id IS NOT NULL THEN '✅ FIXED'
    ELSE '❌ STILL BROKEN'
  END as "Status"
FROM admin_accounts a
LEFT JOIN auth.users u ON u.id = a.auth_user_id
WHERE a.email = 'hrachfilm@gmail.com';

-- STEP 6: Test the function (this will only work when you're logged in)
-- Run this in the Supabase SQL Editor while logged into your app
-- SELECT is_arnoma_admin() as "Am I Admin?";

-- =============================================================================
-- AFTER RUNNING THIS:
-- 1. Your auth_user_id should be properly linked in admin_accounts
-- 2. When you log into the app, is_arnoma_admin() will return TRUE
-- 3. You'll have access to all payment records
-- =============================================================================
