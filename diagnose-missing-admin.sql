-- ============================================
-- DIAGNOSE THE PROBLEM
-- ============================================

-- STEP 1: Check if hrachfilm@gmail.com exists in students table
SELECT 
  id,
  name,
  email,
  role,
  auth_user_id
FROM students
WHERE email ILIKE '%hrachfilm%' OR email ILIKE '%hrach%';

-- STEP 2: If not found, check ALL students
SELECT 
  id,
  name,
  email,
  role,
  auth_user_id
FROM students
ORDER BY id
LIMIT 20;

-- STEP 3: Check what email you used to create the Supabase Auth account
-- This will show the email in auth.users
SELECT 
  id,
  email,
  created_at
FROM auth.users
WHERE id = '3d03b89d-b62c-47ce-91de-32b1af6d748d';

-- ============================================
-- LIKELY SCENARIOS:
-- ============================================

-- SCENARIO A: Your email in students table is different
-- Solution: Update with the correct email from STEP 2

-- SCENARIO B: You don't have a student record yet
-- Solution: Create one with this SQL:
-- 
-- INSERT INTO students (name, email, role, auth_user_id, show_in_grid)
-- VALUES (
--   'Your Name',
--   'hrachfilm@gmail.com',
--   'admin',
--   '3d03b89d-b62c-47ce-91de-32b1af6d748d',
--   false
-- );

-- SCENARIO C: The email spelling is slightly different
-- Solution: Use the UPDATE below with the correct email from STEP 2
