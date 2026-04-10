-- ============================================
-- CREATE ADMIN ACCOUNT
-- ============================================
-- This will create YOUR admin account in the students table
-- and link it to your Supabase Auth user
-- ============================================

-- Create your admin record
INSERT INTO students (
  name,
  email,
  role,
  auth_user_id,
  show_in_grid
)
VALUES (
  'Hrach Festa',  -- Change this to your name
  'hrachfilm@gmail.com',
  'admin',
  '3d03b89d-b62c-47ce-91de-32b1af6d748d',
  false  -- Don't show admin in the grid
);

-- Verify it was created
SELECT 
  id,
  name,
  email,
  role,
  auth_user_id,
  '✅ ADMIN ACCOUNT CREATED!' as status
FROM students
WHERE email = 'hrachfilm@gmail.com';

-- ============================================
-- AFTER RUNNING THIS:
-- ============================================
-- 1. Refresh your browser at Login-Portal.html
-- 2. Login with: hrachfilm@gmail.com + your password
-- 3. You should be redirected to Student-Manager.html
-- 4. You should see all 20 students!
-- ============================================
