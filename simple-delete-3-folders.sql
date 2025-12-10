-- ========================================
-- SIMPLE CLEANUP: Delete 3 Empty Folders (One at a Time)
-- ========================================
-- Run each DELETE separately to avoid timeout

-- ========================================
-- DELETE #1: Cardiovascular (0 notes)
-- ========================================
UPDATE note_folders
SET deleted_at = NOW()
WHERE id = '46929d5d-cb73-4ce9-b999-fecb665d3252';

-- Expected: 1 row updated


-- ========================================
-- DELETE #2: Endocrine (0 notes)
-- ========================================
UPDATE note_folders
SET deleted_at = NOW()
WHERE id = 'e23d197f-a443-4ec9-8a54-08837a399625';

-- Expected: 1 row updated


-- ========================================
-- DELETE #3: Respiratory (0 notes)
-- ========================================
UPDATE note_folders
SET deleted_at = NOW()
WHERE id = '86fd1834-ae55-493f-9a51-428f637f6105';

-- Expected: 1 row updated


-- ========================================
-- VERIFY: Check for duplicates (should be 0)
-- ========================================
SELECT 
  LOWER(REGEXP_REPLACE(folder_name, ' System$', '', 'i')) as normalized_name,
  COUNT(*) as count,
  STRING_AGG(folder_name, ', ') as variants
FROM note_folders
WHERE deleted_at IS NULL
  AND group_letter IS NULL
GROUP BY normalized_name
HAVING COUNT(*) > 1;

-- Expected: 0 rows (no more duplicates)


-- ========================================
-- COUNT: Final folder totals
-- ========================================
SELECT 
  COUNT(*) as total_folders,
  COUNT(*) FILTER (WHERE group_letter IS NULL) as global_folders,
  COUNT(*) FILTER (WHERE group_letter IS NOT NULL) as group_specific_folders
FROM note_folders
WHERE deleted_at IS NULL;

-- Expected:
-- | total_folders | global_folders | group_specific_folders |
-- | 34            | 30             | 4                      |
