-- Clean Weird Characters from Student Aliases
-- Run this in Supabase SQL Editor to fix existing data

-- =====================================================
-- 1. CHECK CURRENT ALIASES WITH POTENTIAL ISSUES
-- =====================================================
SELECT 
  id,
  name,
  aliases,
  length(aliases::text) as alias_length,
  CASE 
    WHEN aliases::text ~ '[\u0000-\u001F\u007F-\u009F\u200B-\u200D\uFEFF]' 
    THEN '⚠️ Has control chars'
    ELSE '✅ Clean'
  END as status
FROM students
WHERE aliases IS NOT NULL 
  AND aliases::text != '[]'
  AND aliases::text != 'null'
ORDER BY name;

-- =====================================================
-- 2. VIEW BEATRISA'S CURRENT ALIASES (Example)
-- =====================================================
SELECT 
  id,
  name,
  aliases,
  aliases::text as raw_text
FROM students
WHERE name ILIKE '%beatrisa%' OR name ILIKE '%arushanyan%';

-- =====================================================
-- 3. BACKUP CURRENT ALIASES (OPTIONAL BUT RECOMMENDED)
-- =====================================================
-- Uncomment to create backup table
/*
CREATE TABLE IF NOT EXISTS students_aliases_backup AS
SELECT id, name, aliases, now() as backed_up_at
FROM students
WHERE aliases IS NOT NULL;
*/

-- =====================================================
-- 4. CLEAN ALL ALIASES (AUTOMATIC)
-- =====================================================
-- This will be done automatically by the app on next save
-- But you can force clean all students now:

-- Note: The cleaning will happen automatically when:
-- 1. Student Manager loads students (parseAliasesField)
-- 2. Any student is saved (cleanAliasesForSave)

-- To force immediate cleanup, you can trigger a save in Student Manager:
-- 1. Open Student Manager
-- 2. Edit any student (change a field)
-- 3. Their aliases will be cleaned and saved
-- 4. Repeat for all students with weird aliases

-- =====================================================
-- 5. MANUAL CLEAN SPECIFIC STUDENT (if needed)
-- =====================================================
-- Example: Clean Beatrisa's aliases manually
/*
UPDATE students
SET aliases = jsonb_build_array(
  'Oganes Terterian',
  'Beatrisa Arushanian'
)
WHERE name = 'Beatrisa Arushanyan';
*/

-- =====================================================
-- 6. VERIFY CLEANUP
-- =====================================================
SELECT 
  id,
  name,
  aliases,
  jsonb_array_length(aliases) as alias_count
FROM students
WHERE aliases IS NOT NULL 
  AND aliases::text != '[]'
ORDER BY name;
