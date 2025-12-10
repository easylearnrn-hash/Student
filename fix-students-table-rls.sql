-- ========================================
-- FIX: Students Table RLS for Credit Application
-- ========================================
-- Issue: "permission denied for table users" when updating student balance
-- Root cause: RLS policy blocking UPDATE on students table

-- Step 1: Check existing policies on students table
SELECT 
  policyname,
  cmd,
  qual,
  with_check
FROM pg_policies 
WHERE tablename = 'students';

-- Step 2: Check if admin can update students
-- (This should work if RLS is properly configured)

-- Step 3: Fix - Add/Update admin policy for students table
-- Drop old policies that might be blocking updates
DROP POLICY IF EXISTS "students_update_admin" ON students;
DROP POLICY IF EXISTS "Admin can update students" ON students;

-- Create comprehensive admin policy for all operations
CREATE POLICY "students_admin_all"
ON students
FOR ALL
TO authenticated
USING (
  auth.uid() IN (SELECT auth_user_id FROM admin_accounts)
)
WITH CHECK (
  auth.uid() IN (SELECT auth_user_id FROM admin_accounts)
);

-- Step 4: Verify the policy was created
SELECT 
  policyname,
  cmd,
  roles,
  qual,
  with_check
FROM pg_policies 
WHERE tablename = 'students'
ORDER BY policyname;

-- Step 5: Test UPDATE permission
-- Replace 16 with Sirarpi's actual student ID
-- Replace 400 with desired new balance
/*
UPDATE students 
SET balance = 400 
WHERE id = 16;

-- If successful, verify:
SELECT id, name, balance 
FROM students 
WHERE id = 16;
*/
