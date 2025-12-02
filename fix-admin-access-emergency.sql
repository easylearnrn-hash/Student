-- ============================================
-- EMERGENCY: FIX ADMIN ACCESS
-- ============================================
-- Run this to restore your admin access immediately!
-- ============================================

-- STEP 1: Check if your admin account is linked
SELECT 
  id,
  name,
  email,
  role,
  auth_user_id,
  CASE 
    WHEN auth_user_id IS NULL THEN '❌ NOT LINKED - This is the problem!'
    WHEN role IS NULL OR role != 'admin' THEN '❌ ROLE NOT SET - This is the problem!'
    ELSE '✅ Looks good'
  END as status
FROM students
WHERE email = 'hrachfilm@gmail.com';

-- STEP 2: Force link your admin account and set role
-- Replace with your actual UUID if different
UPDATE students 
SET 
  auth_user_id = '3d03b89d-b62c-47ce-91de-32b1af6d748d',
  role = 'admin'
WHERE email = 'hrachfilm@gmail.com';

-- STEP 3: Verify it worked
SELECT 
  id,
  name,
  email,
  role,
  auth_user_id,
  CASE 
    WHEN auth_user_id = '3d03b89d-b62c-47ce-91de-32b1af6d748d' AND role = 'admin' 
    THEN '✅ ADMIN ACCESS RESTORED!'
    ELSE '❌ Still broken - check UUID'
  END as status
FROM students
WHERE email = 'hrachfilm@gmail.com';

-- ============================================
-- IF THIS DOESN'T WORK, DISABLE RLS AGAIN
-- ============================================
-- Uncomment these lines to disable RLS and restore access:

-- ALTER TABLE students DISABLE ROW LEVEL SECURITY;
-- ALTER TABLE payment_records DISABLE ROW LEVEL SECURITY;
-- ALTER TABLE payments DISABLE ROW LEVEL SECURITY;
-- ALTER TABLE student_notes DISABLE ROW LEVEL SECURITY;
-- ALTER TABLE schedule_changes DISABLE ROW LEVEL SECURITY;
-- ALTER TABLE groups DISABLE ROW LEVEL SECURITY;
