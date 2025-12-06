-- ========================================================
-- UPDATE STORAGE POLICIES SAFELY
-- ========================================================
-- This drops and recreates storage policies to avoid conflicts
-- ========================================================

-- Drop existing policies if they exist
DROP POLICY IF EXISTS "Admin can upload notes" ON storage.objects;
DROP POLICY IF EXISTS "Admin can update notes" ON storage.objects;
DROP POLICY IF EXISTS "Admin can delete notes" ON storage.objects;
DROP POLICY IF EXISTS "Students can read notes" ON storage.objects;

-- Policy 1: Admin can upload
CREATE POLICY "Admin can upload notes"
  ON storage.objects FOR INSERT
  WITH CHECK (
    bucket_id = 'student-notes' AND
    EXISTS (
      SELECT 1 FROM admin_accounts 
      WHERE auth_user_id = auth.uid()
    )
  );

-- Policy 2: Admin can update
CREATE POLICY "Admin can update notes"
  ON storage.objects FOR UPDATE
  USING (
    bucket_id = 'student-notes' AND
    EXISTS (
      SELECT 1 FROM admin_accounts 
      WHERE auth_user_id = auth.uid()
    )
  );

-- Policy 3: Admin can delete
CREATE POLICY "Admin can delete notes"
  ON storage.objects FOR DELETE
  USING (
    bucket_id = 'student-notes' AND
    EXISTS (
      SELECT 1 FROM admin_accounts 
      WHERE auth_user_id = auth.uid()
    )
  );

-- Policy 4: Students can read (download) notes
CREATE POLICY "Students can read notes"
  ON storage.objects FOR SELECT
  USING (
    bucket_id = 'student-notes' AND
    EXISTS (
      SELECT 1 FROM students
      WHERE auth_user_id = auth.uid()
    )
  );

-- ========================================================
-- ✅ Storage policies updated successfully!
-- ========================================================
