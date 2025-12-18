-- Fix missing Group F and empty Group B schedule
-- Run this in Supabase SQL Editor

-- Add Group F (missing from groups table)
INSERT INTO groups (group_name, schedule, one_time_schedules, active, updated_at)
VALUES (
  'F',
  'Saturday: 10:00 AM',  -- Default schedule for Group F (you can change this)
  '[]'::jsonb,
  true,
  NOW()
)
ON CONFLICT (group_name) DO NOTHING;

-- Update Group B to have a schedule (currently empty)
UPDATE groups
SET 
  schedule = 'Monday: 10:00 AM',  -- Default schedule for Group B (you can change this)
  updated_at = NOW()
WHERE group_name = 'B'
  AND (schedule IS NULL OR schedule = '');

-- Verify results
SELECT 
  group_name,
  schedule,
  active,
  updated_at
FROM groups
ORDER BY group_name;
