-- ============================================================
-- CREATE ALL GROUPS A-F WITH DEFAULT SCHEDULES
-- ============================================================

-- Insert groups A-F (will skip if they already exist)
INSERT INTO groups (group_name, schedule, one_time_schedules, active, updated_at)
VALUES 
  ('A', 'Friday: 8:00 AM', '[]'::jsonb, true, NOW()),
  ('B', 'Friday: 8:00 AM', '[]'::jsonb, true, NOW()),
  ('C', 'Friday: 8:00 AM', '[]'::jsonb, true, NOW()),
  ('D', 'Friday: 8:00 AM', '[]'::jsonb, true, NOW()),
  ('E', 'Friday: 8:00 AM', '[]'::jsonb, true, NOW()),
  ('F', 'Friday: 8:00 AM', '[]'::jsonb, true, NOW())
ON CONFLICT DO NOTHING;

-- ============================================================
-- OPTIONAL: CREATE MISSING GROUPS FOR ANY STUDENTS
-- ============================================================

-- Auto-create groups for any student group_name that doesn't exist yet
INSERT INTO groups (group_name, schedule, one_time_schedules, active, updated_at)
SELECT DISTINCT 
  s.group_name,
  'Friday: 8:00 AM',
  '[]'::jsonb,
  true,
  NOW()
FROM students s
WHERE s.group_name IS NOT NULL
  AND s.group_name NOT IN (SELECT group_name FROM groups)
ON CONFLICT DO NOTHING;

-- ============================================================
-- VERIFY FINAL STATE
-- ============================================================

-- Show all groups with student count
SELECT 
  g.group_name,
  g.schedule,
  g.active,
  COUNT(s.id) AS student_count
FROM groups g
LEFT JOIN students s ON g.group_name = s.group_name
GROUP BY g.group_name, g.schedule, g.active
ORDER BY g.group_name;
