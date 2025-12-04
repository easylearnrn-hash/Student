-- ========================================================
-- NUCLEAR OPTION: Force delete auth user
-- ========================================================
-- This deletes the auth.users record directly
-- Supabase will handle cascading to other tables
-- ========================================================

-- Just delete directly from auth.users
-- Supabase's internal triggers should cascade the deletion
DELETE FROM auth.users
WHERE email = 'alekevin@gmail.com';

-- Verify it's gone
SELECT COUNT(*) as user_exists
FROM auth.users
WHERE email = 'alekevin@gmail.com';
-- Should return 0
