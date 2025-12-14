-- Fix Sona Husikyan's alias - use TEXT format, not JSONB
-- The aliases column is TEXT with comma separators, constraint blocks quotes/brackets

-- Option 1: Single alias (simplest)
UPDATE students
SET aliases = 'Husikyan Consulting'
WHERE name = 'Sona Husikyan';

-- OR Option 2: Multiple aliases with comma separator
-- UPDATE students
-- SET aliases = 'Husikyan Consulting, Husikyan Consulting I Nc'
-- WHERE name = 'Sona Husikyan';

-- Verify the update
SELECT id, name, aliases, group_name 
FROM students 
WHERE name = 'Sona Husikyan';
