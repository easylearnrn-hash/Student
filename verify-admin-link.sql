-- Check if admin account exists with the exact UUID
SELECT 
  id,
  name,
  email,
  role,
  auth_user_id,
  CASE 
    WHEN auth_user_id = '3d03b89d-b62c-47ce-91de-32b1af6d748d' THEN '✅ UUID MATCHES!'
    ELSE '❌ UUID DOES NOT MATCH'
  END as uuid_check
FROM students
WHERE email = 'hrachfilm@gmail.com';

-- Also check what the Supabase Auth user ID actually is
SELECT 
  id as "Auth User ID",
  email as "Email",
  created_at
FROM auth.users
WHERE email = 'hrachfilm@gmail.com';
