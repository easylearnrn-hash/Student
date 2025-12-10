-- ========================================
-- COMPLETE FIX: Before/After Comparison
-- ========================================
-- This shows exactly what will change after running the migration

-- ========================================
-- BEFORE STATE (Current)
-- ========================================
SELECT 
  '❌ BEFORE: Notes without category' as status,
  id,
  title,
  group_name,
  category,
  class_date
FROM student_notes
WHERE deleted = false
ORDER BY class_date DESC
LIMIT 10;

-- Expected output:
-- | status                           | id  | title                    | group_name    | category | class_date |
-- | ❌ BEFORE: Notes without category | 622 | Medication Calculation   | Pharmacology  | null     | 2025-12-09 |
-- | ❌ BEFORE: Notes without category | 621 | General Pharmacology     | Pharmacology  | null     | 2025-12-09 |
-- ... (8 more rows, all with category = null)

-- ========================================
-- RUN THE MIGRATION
-- ========================================
UPDATE student_notes
SET category = group_name
WHERE category IS NULL AND group_name IS NOT NULL;

-- ========================================
-- AFTER STATE (Fixed)
-- ========================================
SELECT 
  '✅ AFTER: Notes WITH category' as status,
  id,
  title,
  group_name,
  category,
  class_date
FROM student_notes
WHERE deleted = false
ORDER BY class_date DESC
LIMIT 10;

-- Expected output:
-- | status                        | id  | title                    | group_name    | category      | class_date |
-- | ✅ AFTER: Notes WITH category | 622 | Medication Calculation   | Pharmacology  | Pharmacology  | 2025-12-09 |
-- | ✅ AFTER: Notes WITH category | 621 | General Pharmacology     | Pharmacology  | Pharmacology  | 2025-12-09 |
-- ... (8 more rows, all with category = group_name)

-- ========================================
-- FOLDER NOTE COUNTS - BEFORE vs AFTER
-- ========================================
-- This shows how the note counts will change

-- BEFORE (all folders show 0 notes):
WITH before_counts AS (
  SELECT 
    f.folder_name,
    COUNT(n.id) FILTER (WHERE n.category IS NOT NULL) as note_count
  FROM note_folders f
  LEFT JOIN student_notes n ON 
    LOWER(REGEXP_REPLACE(f.folder_name, ' System$', '', 'i')) = 
    LOWER(REGEXP_REPLACE(n.category, ' System$', '', 'i'))
    AND n.deleted = false
  WHERE f.deleted_at IS NULL
    AND f.group_letter IS NULL
  GROUP BY f.folder_name
  ORDER BY note_count DESC, folder_name
  LIMIT 5
)
SELECT 
  '❌ BEFORE' as state,
  folder_name,
  note_count
FROM before_counts;

-- Expected output:
-- | state       | folder_name             | note_count |
-- | ❌ BEFORE   | Pharmacology            | 0          |  ← All zeros!
-- | ❌ BEFORE   | Cardiovascular System   | 0          |
-- | ❌ BEFORE   | Endocrine System        | 0          |

-- AFTER (Pharmacology shows 10 notes):
-- Re-run the same query after UPDATE:
WITH after_counts AS (
  SELECT 
    f.folder_name,
    COUNT(n.id) FILTER (WHERE n.category IS NOT NULL) as note_count
  FROM note_folders f
  LEFT JOIN student_notes n ON 
    LOWER(REGEXP_REPLACE(f.folder_name, ' System$', '', 'i')) = 
    LOWER(REGEXP_REPLACE(n.category, ' System$', '', 'i'))
    AND n.deleted = false
  WHERE f.deleted_at IS NULL
    AND f.group_letter IS NULL
  GROUP BY f.folder_name
  ORDER BY note_count DESC, folder_name
  LIMIT 5
)
SELECT 
  '✅ AFTER' as state,
  folder_name,
  note_count
FROM after_counts;

-- Expected output:
-- | state      | folder_name             | note_count |
-- | ✅ AFTER   | Pharmacology            | 10         |  ← Fixed!
-- | ✅ AFTER   | Cardiovascular System   | 0          |
-- | ✅ AFTER   | Endocrine System        | 0          |

-- ========================================
-- STUDENT PORTAL CAROUSEL - BEFORE vs AFTER
-- ========================================

-- BEFORE: All 34 folders filtered (no notes):
SELECT 
  '❌ BEFORE: Carousel Systems' as state,
  COUNT(*) as total_folders,
  COUNT(*) FILTER (WHERE note_count > 0) as systems_with_notes,
  COUNT(*) FILTER (WHERE note_count = 0 AND NOT is_current) as empty_hidden,
  COUNT(*) FILTER (WHERE note_count > 0 OR is_current) as final_displayed
FROM (
  SELECT 
    f.folder_name,
    f.is_current,
    COUNT(n.id) FILTER (WHERE n.category IS NOT NULL) as note_count
  FROM note_folders f
  LEFT JOIN student_notes n ON 
    LOWER(REGEXP_REPLACE(f.folder_name, ' System$', '', 'i')) = 
    LOWER(REGEXP_REPLACE(n.category, ' System$', '', 'i'))
    AND n.deleted = false
  WHERE f.deleted_at IS NULL
    AND f.group_letter IS NULL
  GROUP BY f.id, f.folder_name, f.is_current
) deduplicated;

-- Expected output:
-- | state                          | total_folders | systems_with_notes | empty_hidden | final_displayed |
-- | ❌ BEFORE: Carousel Systems    | 34            | 0                  | 31           | 3               |
--                                                                                      ↑ only ongoing systems

-- AFTER: 1 folder with notes + ongoing:
-- Re-run after UPDATE:
SELECT 
  '✅ AFTER: Carousel Systems' as state,
  COUNT(*) as total_folders,
  COUNT(*) FILTER (WHERE note_count > 0) as systems_with_notes,
  COUNT(*) FILTER (WHERE note_count = 0 AND NOT is_current) as empty_hidden,
  COUNT(*) FILTER (WHERE note_count > 0 OR is_current) as final_displayed
FROM (
  SELECT 
    f.folder_name,
    f.is_current,
    COUNT(n.id) FILTER (WHERE n.category IS NOT NULL) as note_count
  FROM note_folders f
  LEFT JOIN student_notes n ON 
    LOWER(REGEXP_REPLACE(f.folder_name, ' System$', '', 'i')) = 
    LOWER(REGEXP_REPLACE(n.category, ' System$', '', 'i'))
    AND n.deleted = false
  WHERE f.deleted_at IS NULL
    AND f.group_letter IS NULL
  GROUP BY f.id, f.folder_name, f.is_current
) deduplicated;

-- Expected output:
-- | state                        | total_folders | systems_with_notes | empty_hidden | final_displayed |
-- | ✅ AFTER: Carousel Systems   | 34            | 1                  | 30           | 4               |
--                                                 ↑ Pharmacology      ↑ empty hidden  ↑ 1 with notes + 3 ongoing

-- ========================================
-- VERIFICATION: All notes properly linked
-- ========================================
SELECT 
  n.id,
  n.title,
  n.category,
  f.folder_name as matched_folder,
  CASE 
    WHEN f.id IS NOT NULL THEN '✅ LINKED'
    ELSE '❌ NOT LINKED'
  END as link_status
FROM student_notes n
LEFT JOIN note_folders f ON 
  LOWER(REGEXP_REPLACE(f.folder_name, ' System$', '', 'i')) = 
  LOWER(REGEXP_REPLACE(n.category, ' System$', '', 'i'))
  AND f.deleted_at IS NULL
  AND f.group_letter IS NULL
WHERE n.deleted = false
ORDER BY link_status DESC, n.class_date DESC;

-- Expected output (AFTER migration):
-- | id  | title                    | category      | matched_folder | link_status |
-- | 622 | Medication Calculation   | Pharmacology  | Pharmacology   | ✅ LINKED   |
-- | 621 | General Pharmacology     | Pharmacology  | Pharmacology   | ✅ LINKED   |
-- | 620 | Renal Medication         | Pharmacology  | Pharmacology   | ✅ LINKED   |
-- ... (all 10 notes should show ✅ LINKED)
