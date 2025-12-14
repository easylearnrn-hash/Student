-- Test what the aliases_no_special_chars constraint actually allows
-- Run these one at a time to see which works

-- Test 1: Single word (should work)
UPDATE students
SET aliases = '["Husikyan"]'::jsonb
WHERE name = 'Sona Husikyan';

-- If Test 1 works, try Test 2: Two words with space
-- UPDATE students
-- SET aliases = '["Husikyan Consulting"]'::jsonb
-- WHERE name = 'Sona Husikyan';

-- If Test 2 works, try Test 3: With hyphen
-- UPDATE students
-- SET aliases = '["Husikyan-Consulting"]'::jsonb
-- WHERE name = 'Sona Husikyan';

-- Check result
SELECT id, name, aliases FROM students WHERE name = 'Sona Husikyan';

-- Then check what the actual constraint definition is:
SELECT conname, pg_get_constraintdef(oid) as definition
FROM pg_constraint
WHERE conrelid = 'students'::regclass
  AND conname = 'aliases_no_special_chars';
