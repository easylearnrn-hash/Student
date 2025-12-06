-- Check storage bucket settings
-- Run this in Supabase SQL Editor

-- Check if student-notes bucket exists and if it's public
SELECT 
  id,
  name,
  public,
  created_at
FROM storage.buckets 
WHERE name = 'student-notes';
