-- ============================================================
-- Check if Ani Abovyan has admin access accidentally
-- ============================================================

-- 1. Check student record for Ani Abovyan
SELECT 
  id,
  name,
  email,
  status,
  created_at
FROM students
WHERE name ILIKE '%Ani%Abovyan%'
   OR email = 'hrachfilm@gmail.com';

-- 2. Check if student email is in admin_accounts table
SELECT 
  id,
  email,
  is_active,
  created_at
FROM admin_accounts
WHERE email IN (
  SELECT email 
  FROM students 
  WHERE name ILIKE '%Ani%Abovyan%'
);

-- 3. Check all admin accounts
SELECT 
  id,
  email,
  is_active,
  created_at
FROM admin_accounts
ORDER BY created_at DESC;

-- 4. Find any students with admin email
SELECT 
  id,
  name,
  email,
  status
FROM students
WHERE email = 'hrachfilm@gmail.com';

-- ============================================================
-- RECOMMENDED FIXES:
-- ============================================================

-- If student has admin email, update it to their actual email:
-- UPDATE students 
-- SET email = 'ani.abovyan@example.com'  -- Replace with actual email
-- WHERE name ILIKE '%Ani%Abovyan%' AND email = 'hrachfilm@gmail.com';

-- If student is accidentally in admin_accounts, remove them:
-- DELETE FROM admin_accounts
-- WHERE email IN (
--   SELECT email FROM students WHERE name ILIKE '%Ani%Abovyan%'
-- );
