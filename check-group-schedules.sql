-- ═══════════════════════════════════════════════════════════════
-- CHECK GROUP SCHEDULES - Verify groups table has correct data
-- Run this to see if Calendar is reading the right schedule
-- ═══════════════════════════════════════════════════════════════

-- Show all groups and their schedules
SELECT 
  id,
  group_name,
  schedule,
  one_time_schedules,
  active,
  -- Show which students are in this group
  (
    SELECT COUNT(*)
    FROM students s
    WHERE s.group_name = groups.group_name
  ) as student_count,
  (
    SELECT string_agg(s.name, ', ')
    FROM students s
    WHERE s.group_name = groups.group_name
    LIMIT 10
  ) as sample_students
FROM groups
WHERE active = true
ORDER BY group_name;


-- ═══════════════════════════════════════════════════════════════
-- WHAT TO LOOK FOR:
--
-- Group C schedule should be something like:
--   {"sunday": {"time": "12:00 PM", "active": true}}
-- OR
--   [{"day": "sunday", "time": "12:00 PM"}]
--
-- If schedule is NULL, empty {}, or has wrong days → THAT'S THE PROBLEM
-- Calendar won't know when Group C has classes
-- ═══════════════════════════════════════════════════════════════


-- ═══════════════════════════════════════════════════════════════
-- EXPECTED RESULTS:
-- 
-- Group C should show:
--   schedule: Something like "Sunday 12:00 PM" or {"sunday": "12:00 PM"}
--
-- If schedule is empty or wrong → Calendar won't know Group C = Sunday
-- If schedule is correct → Problem is elsewhere (payment matching logic)
-- ═══════════════════════════════════════════════════════════════
