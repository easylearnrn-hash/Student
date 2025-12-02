-- ============================================
-- LINK YOUR ADMIN ACCOUNT TO STUDENTS TABLE
-- ============================================

-- Linking hrachfilm@gmail.com to admin role
UPDATE students 
SET auth_user_id = '3d03b89d-b62c-47ce-91de-32b1af6d748d',
    role = 'admin'
WHERE email = 'hrachfilm@gmail.com';

-- VERIFY IT WORKED
SELECT id, name, email, role, auth_user_id 
FROM students 
WHERE role = 'admin';

-- Should show your admin account with the UUID linked
