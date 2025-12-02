-- 📋 STEP 1: Run this to see which students need accounts
-- Copy the results - you'll need the emails for Step 2

SELECT 
  id,
  name,
  email,
  CASE 
    WHEN auth_user_id IS NULL THEN '❌ NEEDS ACCOUNT'
    ELSE '✅ HAS ACCOUNT'
  END as status
FROM students
WHERE show_in_grid = true
ORDER BY 
  CASE WHEN auth_user_id IS NULL THEN 0 ELSE 1 END,
  name;

-- 📊 Summary
SELECT 
  COUNT(*) FILTER (WHERE auth_user_id IS NULL) as "❌ Need Accounts",
  COUNT(*) FILTER (WHERE auth_user_id IS NOT NULL) as "✅ Have Accounts",
  COUNT(*) as "Total Students"
FROM students
WHERE show_in_grid = true;


-- ================================================================
-- 📝 STEP 2: After creating auth user in Supabase Dashboard
-- ================================================================
-- Replace the values below and run for EACH student:

-- TEMPLATE (DO NOT RUN AS-IS):
-- UPDATE students 
-- SET auth_user_id = 'PASTE-UUID-FROM-SUPABASE-HERE',
--     role = 'student'
-- WHERE email = 'paste-student-email-here';


-- ================================================================
-- ✅ EXAMPLE (how it should look when filled in):
-- ================================================================
-- UPDATE students 
-- SET auth_user_id = 'a1b2c3d4-e5f6-7890-abcd-ef1234567890',
--     role = 'student'
-- WHERE email = 'student@example.com';


-- ================================================================
-- 🧪 VERIFY AFTER UPDATE:
-- ================================================================
-- Run this to confirm the student was linked:

SELECT 
  id,
  name, 
  email,
  auth_user_id,
  role
FROM students
WHERE email = 'paste-student-email-here';
-- Should show the UUID you just added
