-- STEP 1: Verify current state
SELECT 
  id,
  name,
  email,
  auth_user_id,
  group_name,
  price_per_class,
  show_in_grid
FROM students 
WHERE id = 72;

-- STEP 2: Link the auth account (if not already linked)
UPDATE students
SET auth_user_id = 'c7b21994-a096-4f16-949b-70548ef6a961'
WHERE id = 72 AND email = 'alekevn@gmail.com';

-- STEP 3: Verify the link
SELECT 
  id,
  name,
  email,
  auth_user_id,
  group_name
FROM students 
WHERE auth_user_id = 'c7b21994-a096-4f16-949b-70548ef6a961';

-- STEP 4: Check RLS policies on students table
SELECT 
  schemaname,
  tablename,
  policyname,
  permissive,
  roles,
  cmd,
  qual,
  with_check
FROM pg_policies 
WHERE tablename = 'students';

-- STEP 5: Ensure student can read their own record
-- This grants SELECT permission to authenticated users for their own record
DROP POLICY IF EXISTS "Students can view own record" ON students;

CREATE POLICY "Students can view own record"
ON students
FOR SELECT
TO authenticated
USING (auth_user_id = auth.uid());
