-- Fix Supabase Storage policies for student-notes bucket
-- This allows authenticated users to read files

-- First, check current policies
SELECT * FROM storage.policies WHERE bucket_id = 'student-notes';

-- Drop all existing policies on student-notes bucket
DROP POLICY IF EXISTS "Allow authenticated users to read files" ON storage.objects;
DROP POLICY IF EXISTS "Allow public read access" ON storage.objects;
DROP POLICY IF EXISTS "Allow admins full access" ON storage.objects;

-- Create a simple policy: Allow all authenticated users to read from student-notes
CREATE POLICY "Allow authenticated read access to student-notes"
ON storage.objects FOR SELECT
TO authenticated
USING (bucket_id = 'student-notes');

-- Optional: Also allow anon (non-authenticated) users if students aren't logging in
CREATE POLICY "Allow public read access to student-notes"
ON storage.objects FOR SELECT
TO public
USING (bucket_id = 'student-notes');

-- Verify new policies
SELECT * FROM storage.policies WHERE bucket_id = 'student-notes';
