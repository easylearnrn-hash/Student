-- ============================================================
-- CREATE ADMIN ACCOUNT FOR HRACH
-- ============================================================
-- This creates an entry in admin_accounts table
-- You still need to create the auth user in Supabase Dashboard

-- First, check if admin already exists
SELECT * FROM admin_accounts WHERE email = 'hrachfilm@gmail.com';

-- If not exists, insert admin account
INSERT INTO admin_accounts (email, name, role, created_at)
VALUES (
  'hrachfilm@gmail.com',
  'Hrach',
  'super_admin',
  NOW()
)
ON CONFLICT (email) DO NOTHING;

-- Verify it was created
SELECT * FROM admin_accounts WHERE email = 'hrachfilm@gmail.com';

-- ============================================================
-- NEXT STEPS (DO THIS IN SUPABASE DASHBOARD):
-- ============================================================
-- 1. Go to Supabase Dashboard → Authentication → Users
-- 2. Click "Invite User" or "Add User"
-- 3. Email: hrachfilm@gmail.com
-- 4. Password: (set a password)
-- 5. Click "Create User"
-- 6. Come back and try logging in again
-- ============================================================
