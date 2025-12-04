-- Check which students have auth_user_id linked
SELECT 
  id,
  name,
  email,
  auth_user_id,
  CASE 
    WHEN auth_user_id IS NULL THEN '❌ NO AUTH LINK'
    ELSE '✅ Linked'
  END as auth_status
FROM students
ORDER BY 
  CASE 
    WHEN auth_user_id IS NULL THEN 1
    ELSE 0
  END,
  name;
