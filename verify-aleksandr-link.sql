-- Final verification: Check if auth_user_id was linked
SELECT 
  id,
  name,
  email,
  auth_user_id,
  group_name,
  price_per_class
FROM students 
WHERE id = 72;

-- This should show:
-- auth_user_id = c7b21994-a096-4f16-949b-70548ef6a961
