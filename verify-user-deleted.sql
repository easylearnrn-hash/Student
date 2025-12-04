-- Check if user actually exists
SELECT 
  id,
  email,
  created_at,
  email_confirmed_at,
  deleted_at
FROM auth.users 
WHERE email = 'alekevin@gmail.com';

-- If this returns 0 rows, the user is DELETED
-- The UI is just cached - refresh the page!
