-- Check Aleksandr's auth linkage
SELECT 
  id,
  name,
  email,
  auth_user_id,
  group_name,
  price_per_class
FROM students 
WHERE id = 72 OR email = 'alekevn@gmail.com';

-- Check if there's an auth user for this email
SELECT 
  id,
  email,
  created_at,
  last_sign_in_at
FROM auth.users
WHERE email = 'alekevn@gmail.com';
