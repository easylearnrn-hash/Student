-- ========================================================
-- NUCLEAR DELETE: Complete cleanup of alekevin@gmail.com
-- ========================================================
-- This removes ALL references including auth system tables
-- ========================================================

-- Get the user ID first
DO $$
DECLARE
  user_uuid UUID;
BEGIN
  SELECT id INTO user_uuid FROM auth.users WHERE email = 'alekevin@gmail.com';
  
  IF user_uuid IS NULL THEN
    RAISE NOTICE 'User not found';
    RETURN;
  END IF;

  RAISE NOTICE 'Deleting user: %', user_uuid;

  -- Delete from auth system tables (in correct order)
  DELETE FROM auth.mfa_amr_claims WHERE session_id IN (SELECT id FROM auth.sessions WHERE user_id = user_uuid);
  DELETE FROM auth.mfa_challenges WHERE factor_id IN (SELECT id FROM auth.mfa_factors WHERE user_id = user_uuid);
  DELETE FROM auth.mfa_factors WHERE user_id = user_uuid;
  DELETE FROM auth.refresh_tokens WHERE user_id = user_uuid;
  DELETE FROM auth.sessions WHERE user_id = user_uuid;
  DELETE FROM auth.identities WHERE user_id = user_uuid;
  DELETE FROM auth.one_time_tokens WHERE user_id = user_uuid;
  
  -- Delete from public tables
  DELETE FROM admin_accounts WHERE auth_user_id = user_uuid;
  DELETE FROM students WHERE auth_user_id = user_uuid;
  
  -- Finally delete the auth user
  DELETE FROM auth.users WHERE id = user_uuid;
  
  RAISE NOTICE '✅ User deleted successfully!';
END $$;

-- Verify deletion
SELECT 
  (SELECT COUNT(*) FROM auth.users WHERE email = 'alekevin@gmail.com') as auth_users,
  (SELECT COUNT(*) FROM students WHERE email = 'alekevin@gmail.com') as students,
  (SELECT COUNT(*) FROM admin_accounts WHERE email = 'alekevin@gmail.com') as admins;
-- All should be 0
