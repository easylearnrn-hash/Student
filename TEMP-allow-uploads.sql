-- TEMPORARY: Disable RLS on student-notes bucket to test uploads
-- This allows anyone to upload - ONLY for testing!

-- Option 1: Make the bucket public (not recommended for production)
UPDATE storage.buckets 
SET public = true 
WHERE name = 'student-notes';

-- Option 2: Add a permissive upload policy for testing
CREATE POLICY "Allow all uploads for testing"
ON storage.objects
FOR INSERT
TO public
WITH CHECK (bucket_id = 'student-notes');

-- After testing, you can remove this policy with:
-- DROP POLICY "Allow all uploads for testing" ON storage.objects;
