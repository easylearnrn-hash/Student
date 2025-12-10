-- ============================================================
-- CLEAN ALIASES: Remove brackets, pipes, and add validation
-- ============================================================
-- This SQL will:
-- 1. Remove all bracket characters [ ] from aliases column
-- 2. Replace ||| pipe separators with comma-space
-- 3. Add a CHECK constraint to prevent brackets in future entries
-- ============================================================

-- Step 1: Replace ||| with comma-space separator
UPDATE students
SET aliases = REPLACE(aliases, '|||', ', ')
WHERE aliases IS NOT NULL
  AND aliases LIKE '%|||%';

-- Step 2: Clean existing aliases - remove [ ] characters
UPDATE students
SET aliases = REPLACE(REPLACE(aliases, '[', ''), ']', '')
WHERE aliases IS NOT NULL
  AND (aliases LIKE '%[%' OR aliases LIKE '%]%');

-- Step 3: Also remove quotes if they appear
UPDATE students
SET aliases = REPLACE(REPLACE(aliases, '"', ''), '''', '')
WHERE aliases IS NOT NULL
  AND (aliases LIKE '%"%' OR aliases LIKE '%''%');

-- Step 3.5: Remove backslash escape characters (use double backslash in SQL)
UPDATE students
SET aliases = REPLACE(aliases, E'\\', '')
WHERE aliases IS NOT NULL
  AND aliases LIKE E'%\\%';

-- Step 4: Clean up any double commas or trailing/leading commas that might result
UPDATE students
SET aliases = TRIM(BOTH ',' FROM REGEXP_REPLACE(aliases, ',+', ',', 'g'))
WHERE aliases IS NOT NULL
  AND (aliases LIKE '%,,%' OR aliases LIKE ',%' OR aliases LIKE '%,');

-- Step 5: Normalize spacing after commas (ensure comma-space format)
UPDATE students
SET aliases = REGEXP_REPLACE(aliases, ',\s*', ', ', 'g')
WHERE aliases IS NOT NULL
  AND aliases LIKE '%,%';

-- Step 6: Set to NULL if aliases becomes empty string after cleaning
UPDATE students
SET aliases = NULL
WHERE aliases = '' OR aliases = '[]';

-- Step 7: Add CHECK constraint to prevent brackets, quotes, and pipes in future
-- Note: This will fail if constraint already exists, which is fine
DO $$ 
BEGIN
  -- First drop old constraint if it exists
  ALTER TABLE students DROP CONSTRAINT IF EXISTS aliases_no_brackets;
  
  -- Add new constraint with pipes restriction
  ALTER TABLE students 
  ADD CONSTRAINT aliases_no_special_chars 
  CHECK (
    aliases IS NULL 
    OR (
      aliases NOT LIKE '%[%' 
      AND aliases NOT LIKE '%]%'
      AND aliases NOT LIKE '%"%'
      AND aliases NOT LIKE '%|||%'
      AND aliases NOT LIKE E'%\\%'
    )
  );
EXCEPTION
  WHEN duplicate_object THEN 
    -- Constraint already exists, ignore
    RAISE NOTICE 'Constraint aliases_no_special_chars already exists, skipping...';
END $$;

-- Step 8: Verify the cleanup
SELECT 
  id,
  name,
  aliases,
  CASE 
    WHEN aliases IS NULL THEN 'NULL (empty)'
    WHEN aliases LIKE '%[%' OR aliases LIKE '%]%' THEN '❌ Still has brackets!'
    WHEN aliases LIKE '%"%' THEN '❌ Still has quotes!'
    WHEN aliases LIKE '%|||%' THEN '❌ Still has pipes!'
    WHEN aliases LIKE E'%\\%' THEN '❌ Still has backslashes!'
    ELSE '✅ Clean'
  END as status
FROM students
ORDER BY 
  CASE 
    WHEN aliases LIKE '%[%' OR aliases LIKE '%]%' THEN 1
    WHEN aliases LIKE '%"%' THEN 2
    WHEN aliases LIKE '%|||%' THEN 3
    WHEN aliases LIKE E'%\\%' THEN 4
    WHEN aliases IS NOT NULL THEN 3
    ELSE 4
  END,
  name;
