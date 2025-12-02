-- Fix RLS policies for student_absences table to enable cross-device sync
-- Run this in Supabase SQL Editor

-- Option 1: Simple - Disable RLS (Quick fix, less secure)
-- Uncomment the line below if you want to completely disable RLS:
-- ALTER TABLE student_absences DISABLE ROW LEVEL SECURITY;

-- Option 2: Recommended - Enable RLS with public access policies
ALTER TABLE student_absences ENABLE ROW LEVEL SECURITY;

-- Drop existing policies if any
DROP POLICY IF EXISTS "Allow public read access" ON student_absences;
DROP POLICY IF EXISTS "Allow public insert access" ON student_absences;
DROP POLICY IF EXISTS "Allow public update access" ON student_absences;
DROP POLICY IF EXISTS "Allow public delete access" ON student_absences;

-- Allow anyone to read absences
CREATE POLICY "Allow public read access" ON student_absences
FOR SELECT USING (true);

-- Allow anyone to insert absences  
CREATE POLICY "Allow public insert access" ON student_absences
FOR INSERT WITH CHECK (true);

-- Allow anyone to update absences
CREATE POLICY "Allow public update access" ON student_absences
FOR UPDATE USING (true);

-- Allow anyone to delete absences
CREATE POLICY "Allow public delete access" ON student_absences
FOR DELETE USING (true);

-- Verify the policies were created
SELECT schemaname, tablename, policyname, permissive, roles, cmd, qual, with_check
FROM pg_policies
WHERE tablename = 'student_absences';
