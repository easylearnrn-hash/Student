-- ============================================================
-- IMMEDIATE BACKSLASH CLEANUP
-- Run this directly to clean row 5 and any other rows with backslashes
-- ============================================================

-- Method 1: Using REPLACE with escaped backslash
UPDATE students
SET aliases = REPLACE(aliases, E'\\', '')
WHERE id = 5;

-- Verify row 5
SELECT id, email, aliases 
FROM students 
WHERE id = 5;

-- Clean ALL rows with backslashes
UPDATE students
SET aliases = REPLACE(aliases, E'\\', '')
WHERE aliases LIKE E'%\\%';

-- Verify all cleaned rows
SELECT id, email, aliases,
  CASE 
    WHEN aliases LIKE E'%\\%' THEN '❌ Still has backslash'
    ELSE '✅ Clean'
  END as status
FROM students
WHERE email LIKE '%antonova%' 
   OR aliases LIKE '%Level Up%'
   OR id = 5;
