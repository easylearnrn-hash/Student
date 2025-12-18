-- CRITICAL FIX: Allow students (anon users) to read groups table
-- This fixes "Schedule not available" error in Student Portal

-- Step 1: Drop ALL existing policies on groups table to avoid conflicts
DROP POLICY IF EXISTS "groups_select_all" ON groups;
DROP POLICY IF EXISTS "groups_select_public" ON groups;
DROP POLICY IF EXISTS "groups_write_admin_only" ON groups;
DROP POLICY IF EXISTS "Enable read access for all users" ON groups;

-- Step 2: Create new policy that allows public (anon) read access
CREATE POLICY "groups_select_public"
ON groups
FOR SELECT
TO public  -- Changed from 'authenticated' to 'public' to allow anon access
USING (true);

-- Step 3: Recreate admin write policy
CREATE POLICY "groups_write_admin_only"
ON groups
FOR ALL
TO authenticated
USING (is_arnoma_admin())
WITH CHECK (is_arnoma_admin());

-- Verify: This should return groups even with anon key
-- Test with: curl -H "apikey: YOUR_ANON_KEY" https://YOUR_PROJECT.supabase.co/rest/v1/groups?select=*
