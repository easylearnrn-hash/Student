-- ========================================
-- FIND EXACT DUPLICATE FOLDERS
-- ========================================
-- This shows which folders are duplicates and need cleanup

-- Query 1: Show ALL global folders grouped by normalized name
SELECT 
  LOWER(REGEXP_REPLACE(folder_name, ' System$', '', 'i')) as normalized_name,
  COUNT(*) as duplicate_count,
  STRING_AGG(
    folder_name || ' (ID: ' || id || ', sort: ' || sort_order || ')', 
    ' | ' 
    ORDER BY sort_order
  ) as all_variants
FROM note_folders
WHERE deleted_at IS NULL
  AND group_letter IS NULL
GROUP BY normalized_name
ORDER BY duplicate_count DESC, normalized_name;

-- Expected output will show systems with duplicate_count > 1
-- Example:
-- | normalized_name  | duplicate_count | all_variants                                    |
-- | cardiovascular   | 2               | Cardiovascular (sort: 0) | Cardiovascular System (sort: 15) |
-- | endocrine        | 2               | Endocrine (sort: 3) | Endocrine System (sort: 16)         |


-- Query 2: Count total vs unique systems
SELECT 
  COUNT(*) as total_global_folders,
  COUNT(DISTINCT LOWER(REGEXP_REPLACE(folder_name, ' System$', '', 'i'))) as unique_systems,
  COUNT(*) - COUNT(DISTINCT LOWER(REGEXP_REPLACE(folder_name, ' System$', '', 'i'))) as extra_duplicates
FROM note_folders
WHERE deleted_at IS NULL
  AND group_letter IS NULL;

-- Expected:
-- | total_global_folders | unique_systems | extra_duplicates |
-- | 33                   | 24             | 9                |
--   ↑ what you have       ↑ what you want  ↑ need to delete


-- Query 3: Show ONLY the duplicates (systems with 2+ folder entries)
WITH folder_counts AS (
  SELECT 
    LOWER(REGEXP_REPLACE(folder_name, ' System$', '', 'i')) as normalized_name,
    COUNT(*) as count
  FROM note_folders
  WHERE deleted_at IS NULL
    AND group_letter IS NULL
  GROUP BY normalized_name
  HAVING COUNT(*) > 1
)
SELECT 
  f.id,
  f.folder_name,
  f.sort_order,
  f.is_current,
  LOWER(REGEXP_REPLACE(f.folder_name, ' System$', '', 'i')) as normalized_name,
  ROW_NUMBER() OVER (
    PARTITION BY LOWER(REGEXP_REPLACE(f.folder_name, ' System$', '', 'i'))
    ORDER BY 
      CASE WHEN f.is_current THEN 0 ELSE 1 END,
      f.sort_order ASC
  ) as keep_priority,
  CASE 
    WHEN ROW_NUMBER() OVER (
      PARTITION BY LOWER(REGEXP_REPLACE(f.folder_name, ' System$', '', 'i'))
      ORDER BY 
        CASE WHEN f.is_current THEN 0 ELSE 1 END,
        f.sort_order ASC
    ) = 1 THEN '✅ KEEP'
    ELSE '🗑️ DELETE'
  END as action
FROM note_folders f
INNER JOIN folder_counts fc ON 
  LOWER(REGEXP_REPLACE(f.folder_name, ' System$', '', 'i')) = fc.normalized_name
WHERE f.deleted_at IS NULL
  AND f.group_letter IS NULL
ORDER BY normalized_name, keep_priority;

-- This will show exactly which 9 folders to delete
-- Expected output:
-- | folder_name            | sort_order | action      |
-- | Cardiovascular         | 0          | ✅ KEEP     |
-- | Cardiovascular System  | 15         | 🗑️ DELETE  |
-- | Endocrine              | 3          | ✅ KEEP     |
-- | Endocrine System       | 16         | 🗑️ DELETE  |
-- ... (7 more duplicate pairs)


-- Query 4: Preview the DELETE operation (safe - doesn't actually delete)
WITH duplicates_to_delete AS (
  SELECT 
    f.id,
    f.folder_name,
    f.sort_order,
    LOWER(REGEXP_REPLACE(f.folder_name, ' System$', '', 'i')) as normalized_name,
    ROW_NUMBER() OVER (
      PARTITION BY LOWER(REGEXP_REPLACE(f.folder_name, ' System$', '', 'i'))
      ORDER BY 
        CASE WHEN f.is_current THEN 0 ELSE 1 END,
        f.sort_order ASC
    ) as priority
  FROM note_folders f
  WHERE f.deleted_at IS NULL
    AND f.group_letter IS NULL
)
SELECT 
  id,
  folder_name,
  sort_order,
  normalized_name,
  '🗑️ WILL BE DELETED' as action
FROM duplicates_to_delete
WHERE priority > 1  -- Only rows with priority 2, 3, etc (not the keeper)
ORDER BY normalized_name;

-- This shows the 9 folders that will be soft-deleted
