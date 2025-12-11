-- Check for students with empty or null name/email
SELECT 
  id,
  name,
  email,
  group_letter,
  created_at,
  show_in_grid
FROM students 
WHERE name IS NULL 
   OR name = '' 
   OR name = '-'
   OR email IS NULL
   OR email = ''
   OR email = '-'
ORDER BY created_at DESC;
