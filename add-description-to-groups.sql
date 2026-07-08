-- Add description column to groups table
-- Run in Supabase SQL Editor

ALTER TABLE groups
  ADD COLUMN IF NOT EXISTS description TEXT;

-- Optional: verify
SELECT id, group_name, description FROM groups ORDER BY id;
