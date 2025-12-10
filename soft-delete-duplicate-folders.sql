-- ========================================
-- SOFT-DELETE DUPLICATE FOLDERS
-- ========================================
-- This removes duplicate folder entries while keeping one "canonical" folder
-- for each normalized system name.
--
-- PRIORITY ORDER (which folder to KEEP):
-- 1. Group-specific folders (group_letter IS NOT NULL) - KEEP these always
-- 2. Folders marked as current (is_current = true)
-- 3. Folders with lowest sort_order (earlier in admin-defined order)
--
-- SAFE: Uses soft-delete (deleted_at timestamp), can be reversed

-- STEP 1: Preview what will be deleted
-- Run this first to see which folders will be removed
WITH ranked_folders AS (
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
        CASE WHEN group_letter IS NOT NULL THEN 0 ELSE 1 END, -- Group-specific FIRST (KEEP)
        CASE WHEN is_current THEN 0 ELSE 1 END,                -- Current second (KEEP)
        sort_order ASC                                          -- Lower sort_order third (KEEP)
    ) as priority_rank
  FROM note_folders
  WHERE deleted_at IS NULL
)
SELECT 
  id,
  folder_name,
  group_letter,
  is_current,
  sort_order,
  normalized_name,
  CASE 
    WHEN priority_rank = 1 THEN '✅ KEEP (Primary)'
    ELSE '🗑️ DELETE (Duplicate)'
  END as action
FROM ranked_folders
WHERE normalized_name IN (
  -- Only show systems with duplicates
  SELECT normalized_name 
  FROM ranked_folders 
  GROUP BY normalized_name 
  HAVING COUNT(*) > 1
)
ORDER BY normalized_name, priority_rank;

-- Expected output:
-- | folder_name            | group_letter | is_current | sort_order | action             |
-- | Cardiovascular         | null         | false      | 0          | ✅ KEEP (Primary)  |
-- | Cardiovascular System  | null         | false      | 15         | 🗑️ DELETE (Dup)   |
-- | Endocrine              | null         | false      | 3          | ✅ KEEP (Primary)  |
-- | Endocrine System       | null         | false      | 16         | 🗑️ DELETE (Dup)   |
-- | Endocrine System       | E            | true       | 16         | ✅ KEEP (Group E)  |  ← NOT deleted (group-specific)
-- | Eye Disorders          | null         | false      | 20         | ✅ KEEP (Primary)  |
-- | Eye Disorders          | C            | true       | 20         | ✅ KEEP (Group C)  |  ← NOT deleted (group-specific)
-- ... etc


-- STEP 2: Execute soft-delete (ONLY RUN AFTER REVIEWING STEP 1!)
-- This marks duplicates as deleted by setting deleted_at = NOW()

-- UNCOMMENT THE LINES BELOW TO EXECUTE:
/*
WITH ranked_folders AS (
  SELECT 
    id,
    LOWER(REGEXP_REPLACE(folder_name, ' System$', '', 'i')) as normalized_name,
    ROW_NUMBER() OVER (
      PARTITION BY LOWER(REGEXP_REPLACE(folder_name, ' System$', '', 'i'))
      ORDER BY 
        CASE WHEN group_letter IS NOT NULL THEN 0 ELSE 1 END,
        CASE WHEN is_current THEN 0 ELSE 1 END,
        sort_order ASC
    ) as priority_rank
  FROM note_folders
  WHERE deleted_at IS NULL
)
UPDATE note_folders
SET deleted_at = NOW()
WHERE id IN (
  SELECT id 
  FROM ranked_folders 
  WHERE priority_rank > 1  -- Delete all except rank 1 (the keeper)
);
*/

-- STEP 3: Verify deletion (after uncommenting and running Step 2)
-- Check how many folders remain per system
SELECT 
  LOWER(REGEXP_REPLACE(folder_name, ' System$', '', 'i')) as normalized_name,
  COUNT(*) as folder_count,
  STRING_AGG(folder_name || ' (' || COALESCE(group_letter, 'global') || ')', ', ') as folders
FROM note_folders
WHERE deleted_at IS NULL
GROUP BY normalized_name
HAVING COUNT(*) > 1  -- Show only systems that STILL have duplicates
ORDER BY normalized_name;

-- Expected: 0 rows (no duplicates remaining, except group-specific folders which are intentional)

-- STEP 4: Check final folder count
SELECT 
  COUNT(*) as total_folders,
  COUNT(*) FILTER (WHERE group_letter IS NULL) as global_folders,
  COUNT(*) FILTER (WHERE group_letter IS NOT NULL) as group_specific_folders
FROM note_folders
WHERE deleted_at IS NULL;

-- Expected output (approximate):
-- | total_folders | global_folders | group_specific_folders |
-- | 27            | 24             | 3                      |
--   ↑ ~24 unique systems + 3 group-specific (A, C, E, D) = 27-28 total


-- ========================================
-- ROLLBACK (if you made a mistake)
-- ========================================
-- This reverses the soft-delete by clearing deleted_at

-- UNCOMMENT TO RESTORE DELETED FOLDERS:
/*
UPDATE note_folders
SET deleted_at = NULL
WHERE deleted_at >= NOW() - INTERVAL '1 hour';  -- Only restore folders deleted in last hour
*/
