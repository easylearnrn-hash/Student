-- ================================================================
-- ADD ANON POLICY TO note_free_access FOR IMPERSONATION MODE
-- ================================================================
-- 
-- PROBLEM: During admin impersonation, student-portal uses anon key
-- The existing RLS policy checks auth.uid() which is NULL for anon
-- This blocks the free access query during impersonation
--
-- SOLUTION: Add policy allowing anon SELECT (query still filters by student_id/group)
-- ================================================================

-- Add anon read policy for impersonation mode
CREATE POLICY "Allow anon read for impersonation"
  ON note_free_access
  FOR SELECT
  TO anon
  USING (true);

-- Verify all policies exist
SELECT 
  schemaname,
  tablename,
  policyname,
  permissive,
  roles,
  cmd,
  qual
FROM pg_policies 
WHERE tablename = 'note_free_access'
ORDER BY policyname;
