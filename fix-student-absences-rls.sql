-- FIX: Add RLS policies to allow admin INSERT/UPDATE/DELETE on student_absences table
-- PROBLEM: Calendar.html tries to save absences but RLS blocks with error 42501
-- SOLUTION: Add policies for admin write access

-- Drop existing policies if any (clean slate)
DROP POLICY IF EXISTS "Admins can insert student absences" ON student_absences;
DROP POLICY IF EXISTS "Admins can update student absences" ON student_absences;
DROP POLICY IF EXISTS "Admins can delete student absences" ON student_absences;
DROP POLICY IF EXISTS "Admins can view all student absences" ON student_absences;
DROP POLICY IF EXISTS "Students can view own absences" ON student_absences;

-- ADMIN POLICIES (full CRUD access)
CREATE POLICY "Admins can insert student absences"
ON student_absences
FOR INSERT
TO authenticated
WITH CHECK (
  EXISTS (
    SELECT 1 FROM admin_accounts 
    WHERE admin_accounts.auth_user_id = auth.uid()
  )
);

CREATE POLICY "Admins can update student absences"
ON student_absences
FOR UPDATE
TO authenticated
USING (
  EXISTS (
    SELECT 1 FROM admin_accounts 
    WHERE admin_accounts.auth_user_id = auth.uid()
  )
);

CREATE POLICY "Admins can delete student absences"
ON student_absences
FOR DELETE
TO authenticated
USING (
  EXISTS (
    SELECT 1 FROM admin_accounts 
    WHERE admin_accounts.auth_user_id = auth.uid()
  )
);

CREATE POLICY "Admins can view all student absences"
ON student_absences
FOR SELECT
TO authenticated
USING (
  EXISTS (
    SELECT 1 FROM admin_accounts 
    WHERE admin_accounts.auth_user_id = auth.uid()
  )
);

-- STUDENT POLICIES (read-only for own records)
CREATE POLICY "Students can view own absences"
ON student_absences
FOR SELECT
TO authenticated
USING (
  student_id IN (
    SELECT students.id 
    FROM students 
    WHERE students.auth_user_id = auth.uid()
  )
);

-- NOTE: Students CANNOT insert/update/delete their own absences (admin-only)
