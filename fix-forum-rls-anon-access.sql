-- FIX: Allow students (anon users) to read forum messages
-- This fixes admin messages not showing up for students

-- Drop existing restrictive policy
DROP POLICY IF EXISTS "forum_messages_select_all" ON forum_messages;

-- Create new policy that allows public (anon) read access to forum
CREATE POLICY "forum_messages_select_public"
ON forum_messages
FOR SELECT
TO public  -- Changed from 'authenticated' to 'public' to allow anon access
USING (true);

-- Verify: This should show all messages including admin posts
