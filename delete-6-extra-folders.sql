-- ========================================
-- DELETE 6 EXTRA FOLDERS (One at a Time)
-- ========================================
-- These folders are old/duplicates and not in your expected 24-system list

-- ========================================
-- DELETE #1: Neurological (you have "Neurology")
-- ========================================
UPDATE note_folders
SET deleted_at = NOW()
WHERE id = '3c0df8e9-52b9-4a2d-92a5-61692ebb1cb9';

-- Expected: 1 row updated


-- ========================================
-- DELETE #2: Gastrointestinal (you have "Gastrointestinal & Hepatic System")
-- ========================================
UPDATE note_folders
SET deleted_at = NOW()
WHERE id = 'ada352af-1e1e-4221-a256-256bb5ad3911';

-- Expected: 1 row updated


-- ========================================
-- DELETE #3: Musculoskeletal (you have "Musculoskeletal Disorders")
-- ========================================
UPDATE note_folders
SET deleted_at = NOW()
WHERE id = 'e74ee988-5e7c-4756-b7ac-97158017a45f';

-- Expected: 1 row updated


-- ========================================
-- DELETE #4: Immune (you have "Autoimmune & Infectious Disorders")
-- ========================================
UPDATE note_folders
SET deleted_at = NOW()
WHERE id = '28317652-c7a7-4f98-8bd0-f625e5127389';

-- Expected: 1 row updated


-- ========================================
-- DELETE #5: Hematology (not in your 24-system list)
-- ========================================
UPDATE note_folders
SET deleted_at = NOW()
WHERE id = '2377f338-4f4b-4da5-acab-805694e7e406';

-- Expected: 1 row updated


-- ========================================
-- DELETE #6: Maternal-Newborn (you have "Maternal Health")
-- ========================================
UPDATE note_folders
SET deleted_at = NOW()
WHERE id = '262a4222-84c9-43cb-b454-667b92b300fa';

-- Expected: 1 row updated


-- ========================================
-- VERIFY: Final folder count (should be 24 global + 4 group = 28 total)
-- ========================================
SELECT 
  COUNT(*) as total_folders,
  COUNT(*) FILTER (WHERE group_letter IS NULL) as global_folders,
  COUNT(*) FILTER (WHERE group_letter IS NOT NULL) as group_specific_folders
FROM note_folders
WHERE deleted_at IS NULL;

-- Expected:
-- | total_folders | global_folders | group_specific_folders |
-- | 28            | 24             | 4                      |


-- ========================================
-- VERIFY: List all 24 remaining global folders
-- ========================================
SELECT 
  sort_order,
  folder_name,
  LOWER(REGEXP_REPLACE(folder_name, ' System$', '', 'i')) as normalized_name
FROM note_folders
WHERE deleted_at IS NULL
  AND group_letter IS NULL
ORDER BY sort_order;

-- Expected: 24 rows (your exact 24-system list)


-- ========================================
-- VERIFY: No duplicates remain
-- ========================================
SELECT 
  LOWER(REGEXP_REPLACE(folder_name, ' System$', '', 'i')) as normalized_name,
  COUNT(*) as count
FROM note_folders
WHERE deleted_at IS NULL
  AND group_letter IS NULL
GROUP BY normalized_name
HAVING COUNT(*) > 1;

-- Expected: 0 rows (no duplicates)
