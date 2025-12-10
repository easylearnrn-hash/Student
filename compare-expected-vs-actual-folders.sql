-- ========================================
-- COMPARE DATABASE FOLDERS TO EXPECTED LIST
-- ========================================
-- This shows which folders exist in database but NOT in your expected 24-system list

-- Your expected 24 systems (normalized):
WITH expected_systems AS (
  SELECT unnest(ARRAY[
    'medical terminology',
    'human anatomy',
    'medication suffixes and drug classes',
    'cardiovascular',
    'endocrine',
    'gastrointestinal & hepatic',
    'respiratory',
    'renal',
    'fluids, electrolytes & nutrition',
    'eye disorders',
    'eent',
    'burns and skin',
    'reproductive and sexual health',
    'maternal health',
    'pediatrics',
    'medical-surgical care',
    'mental health',
    'autoimmune & infectious disorders',
    'neurology',
    'cancer',
    'musculoskeletal disorders',
    'psycho-social aspects',
    'nursing skills and fundamentals',
    'pharmacology'
  ]) as expected_name
),
actual_folders AS (
  SELECT 
    id,
    folder_name,
    LOWER(REGEXP_REPLACE(folder_name, ' System$', '', 'i')) as normalized_name,
    sort_order,
    is_current
  FROM note_folders
  WHERE deleted_at IS NULL
    AND group_letter IS NULL
)
-- Query 1: Folders in DATABASE but NOT in your expected list
SELECT 
  af.id,
  af.folder_name,
  af.normalized_name,
  af.sort_order,
  '❌ NOT IN EXPECTED LIST' as status
FROM actual_folders af
WHERE af.normalized_name NOT IN (SELECT expected_name FROM expected_systems)
ORDER BY af.sort_order;

-- Query 2: Expected systems NOT in database
WITH expected_systems AS (
  SELECT unnest(ARRAY[
    'medical terminology',
    'human anatomy',
    'medication suffixes and drug classes',
    'cardiovascular',
    'endocrine',
    'gastrointestinal & hepatic',
    'respiratory',
    'renal',
    'fluids, electrolytes & nutrition',
    'eye disorders',
    'eent',
    'burns and skin',
    'reproductive and sexual health',
    'maternal health',
    'pediatrics',
    'medical-surgical care',
    'mental health',
    'autoimmune & infectious disorders',
    'neurology',
    'cancer',
    'musculoskeletal disorders',
    'psycho-social aspects',
    'nursing skills and fundamentals',
    'pharmacology'
  ]) as expected_name
),
actual_folders AS (
  SELECT 
    LOWER(REGEXP_REPLACE(folder_name, ' System$', '', 'i')) as normalized_name
  FROM note_folders
  WHERE deleted_at IS NULL
    AND group_letter IS NULL
)
SELECT 
  es.expected_name,
  '⚠️ MISSING FROM DATABASE' as status
FROM expected_systems es
WHERE es.expected_name NOT IN (SELECT normalized_name FROM actual_folders);

-- Query 3: Full comparison side-by-side
WITH expected_systems AS (
  SELECT unnest(ARRAY[
    'medical terminology',
    'human anatomy',
    'medication suffixes and drug classes',
    'cardiovascular',
    'endocrine',
    'gastrointestinal & hepatic',
    'respiratory',
    'renal',
    'fluids, electrolytes & nutrition',
    'eye disorders',
    'eent',
    'burns and skin',
    'reproductive and sexual health',
    'maternal health',
    'pediatrics',
    'medical-surgical care',
    'mental health',
    'autoimmune & infectious disorders',
    'neurology',
    'cancer',
    'musculoskeletal disorders',
    'psycho-social aspects',
    'nursing skills and fundamentals',
    'pharmacology'
  ]) as expected_name,
  ROW_NUMBER() OVER () as expected_order
),
actual_folders AS (
  SELECT 
    folder_name,
    LOWER(REGEXP_REPLACE(folder_name, ' System$', '', 'i')) as normalized_name,
    sort_order
  FROM note_folders
  WHERE deleted_at IS NULL
    AND group_letter IS NULL
)
SELECT 
  es.expected_order,
  es.expected_name as expected_system,
  af.folder_name as actual_folder_name,
  af.sort_order as actual_sort_order,
  CASE 
    WHEN af.folder_name IS NULL THEN '⚠️ MISSING'
    ELSE '✅ EXISTS'
  END as status
FROM expected_systems es
LEFT JOIN actual_folders af ON es.expected_name = af.normalized_name
ORDER BY es.expected_order;

-- This will show exactly which folders need to be:
-- 1. Deleted (not in expected list)
-- 2. Created (in expected list but missing from database)
