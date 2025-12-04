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
-- 4. CLEAN BRACKETS [] FROM ALIASES
-- =====================================================
-- This removes [] characters from alias text while keeping the aliases
-- Run this query to fix all students at once:

UPDATE students
SET aliases = (
  SELECT jsonb_agg(
    to_jsonb(
      regexp_replace(elem #>> '{}', '[\[\]]', '', 'g')
    )
  )
  FROM jsonb_array_elements(aliases::jsonb) AS elem
  WHERE (elem #>> '{}') IS NOT NULL
    AND (elem #>> '{}') != ''
    AND length(elem #>> '{}') > 0
)
WHERE aliases IS NOT NULL 
  AND jsonb_typeof(aliases::jsonb) = 'array'
  AND aliases::text != '[]'
  AND (aliases::text LIKE '%[%' OR aliases::text LIKE '%]%');

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
