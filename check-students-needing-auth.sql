-- 🔍 CHECK WHICH STUDENTS NEED AUTH ACCOUNTS
-- This shows all students who don't have Supabase Auth accounts yet

SELECT 
  id,
  name,
  email,
  role,
  auth_user_id,
  CASE 
    WHEN auth_user_id IS NULL THEN '❌ NEEDS AUTH ACCOUNT'
    ELSE '✅ HAS AUTH ACCOUNT'
  END as status
FROM students
WHERE show_in_grid = true
ORDER BY 
  CASE WHEN auth_user_id IS NULL THEN 0 ELSE 1 END,
  name;

-- 📊 SUMMARY
SELECT 
  COUNT(*) FILTER (WHERE auth_user_id IS NULL) as needs_auth,
  COUNT(*) FILTER (WHERE auth_user_id IS NOT NULL) as has_auth,
  COUNT(*) as total_students
FROM students
WHERE show_in_grid = true;
