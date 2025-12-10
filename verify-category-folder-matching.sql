-- ========================================
-- VERIFY CATEGORY POPULATION & FOLDER MATCHING
-- ========================================
-- Run this AFTER executing populate-category-from-group-name.sql
-- to verify that notes are properly linked to folders.

-- Query 1: Show folders with their note counts (SHOULD SEE NOTES NOW!)
SELECT 
  f.folder_name,
  f.group_letter,
  f.is_current,
  f.sort_order,
  LOWER(REGEXP_REPLACE(f.folder_name, ' System$', '', 'i')) as normalized_name,
  COUNT(n.id) as note_count
FROM note_folders f
LEFT JOIN student_notes n ON 
  LOWER(REGEXP_REPLACE(f.folder_name, ' System$', '', 'i')) = 
  LOWER(REGEXP_REPLACE(n.category, ' System$', '', 'i'))
  AND n.deleted = false
WHERE f.deleted_at IS NULL
  AND f.group_letter IS NULL -- Only global folders
GROUP BY f.id, f.folder_name, f.group_letter, f.is_current, f.sort_order
ORDER BY normalized_name;

-- Expected result: Should see note_count > 0 for "Pharmacology" folder
-- Example:
-- | folder_name  | group_letter | note_count | normalized_name |
-- | Pharmacology | null         | 10         | pharmacology    |

-- Query 2: Notes with their matching folders
SELECT 
  n.id,
  n.title,
  n.category,
  n.class_date,
  n.requires_payment,
  f.folder_name as matched_folder,
  f.id as folder_id
FROM student_notes n
LEFT JOIN note_folders f ON 
  LOWER(REGEXP_REPLACE(f.folder_name, ' System$', '', 'i')) = 
  LOWER(REGEXP_REPLACE(n.category, ' System$', '', 'i'))
  AND f.deleted_at IS NULL
  AND f.group_letter IS NULL
WHERE n.deleted = false
ORDER BY n.class_date DESC;

-- Expected result: All 10 notes should have matched_folder = 'Pharmacology'

-- Query 3: Empty folders (note_count = 0)
SELECT 
  f.id,
  f.folder_name,
  f.group_letter,
  f.is_current,
  f.sort_order
FROM note_folders f
WHERE f.deleted_at IS NULL
  AND f.group_letter IS NULL
  AND NOT EXISTS (
    SELECT 1 
    FROM student_notes n 
    WHERE LOWER(REGEXP_REPLACE(f.folder_name, ' System$', '', 'i')) = 
          LOWER(REGEXP_REPLACE(n.category, ' System$', '', 'i'))
      AND n.deleted = false
  )
ORDER BY f.sort_order;

-- Expected result: 33 empty folders (all except Pharmacology)
-- These will be auto-filtered by student-portal.html if is_current = false

-- Query 4: Duplicate folders that can be soft-deleted
WITH normalized_folders AS (
  SELECT 
    id,
    folder_name,
    group_letter,
    is_current,
    sort_order,
    LOWER(REGEXP_REPLACE(folder_name, ' System$', '', 'i')) as normalized_name,
    ROW_NUMBER() OVER (
      PARTITION BY LOWER(REGEXP_REPLACE(folder_name, ' System$', '', 'i'))
      ORDER BY 
        CASE WHEN group_letter IS NOT NULL THEN 0 ELSE 1 END, -- Group-specific first
        CASE WHEN is_current THEN 0 ELSE 1 END, -- Current second
        sort_order -- Then by sort order
    ) as row_num
  FROM note_folders
  WHERE deleted_at IS NULL
    AND group_letter IS NULL
)
SELECT 
  id,
  folder_name,
  normalized_name,
  'DUPLICATE - SAFE TO DELETE' as status
FROM normalized_folders
WHERE row_num > 1
ORDER BY normalized_name, folder_name;

-- Expected result: Shows duplicates like:
-- | id   | folder_name            | normalized_name | status                    |
-- | xxx  | Cardiovascular         | cardiovascular  | DUPLICATE - SAFE TO DELETE |
-- | xxx  | Endocrine              | endocrine       | DUPLICATE - SAFE TO DELETE |

-- Query 5: FINAL SUMMARY - What student portal will show
WITH folder_stats AS (
  SELECT 
    f.id,
    f.folder_name,
    f.group_letter,
    f.is_current,
    LOWER(REGEXP_REPLACE(f.folder_name, ' System$', '', 'i')) as normalized_name,
    COUNT(n.id) as note_count
  FROM note_folders f
  LEFT JOIN student_notes n ON 
    LOWER(REGEXP_REPLACE(f.folder_name, ' System$', '', 'i')) = 
    LOWER(REGEXP_REPLACE(n.category, ' System$', '', 'i'))
    AND n.deleted = false
  WHERE f.deleted_at IS NULL
    AND f.group_letter IS NULL
  GROUP BY f.id, f.folder_name, f.group_letter, f.is_current
),
deduplicated AS (
  SELECT DISTINCT ON (normalized_name)
    folder_name,
    normalized_name,
    note_count,
    is_current
  FROM folder_stats
  ORDER BY 
    normalized_name,
    CASE WHEN is_current THEN 0 ELSE 1 END,
    note_count DESC
)
SELECT 
  COUNT(*) as total_unique_systems,
  COUNT(*) FILTER (WHERE note_count > 0) as systems_with_notes,
  COUNT(*) FILTER (WHERE note_count = 0 AND NOT is_current) as empty_to_filter,
  COUNT(*) FILTER (WHERE note_count > 0 OR is_current) as final_displayed_count
FROM deduplicated;

-- Expected result:
-- | total_unique_systems | systems_with_notes | empty_to_filter | final_displayed_count |
-- | 34                   | 1                  | 33              | 1                     |
--
-- After adding more notes to other systems, final_displayed_count should increase.
