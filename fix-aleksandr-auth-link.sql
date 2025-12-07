-- Link Aleksandr's student record to his auth account
UPDATE students
SET auth_user_id = 'c7b21994-a096-4f16-949b-70548ef6a961'
WHERE id = 72 AND email = 'alekevn@gmail.com';

-- Verify the link was created
SELECT 
  id,
  name,
  email,
  auth_user_id,
  group_name,
  price_per_class
FROM students 
WHERE id = 72;
