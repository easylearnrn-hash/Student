-- ========================================
-- CORRECTED CLEANUP: Delete Empty Duplicates + Reorder
-- ========================================
-- DELETE these 3 folders (they have 0 notes):
--   - Cardiovascular (sort: 0) - 0 notes
--   - Endocrine (sort: 3) - 0 notes
--   - Respiratory (sort: 1) - 0 notes
--
-- KEEP these 3 folders (they have all the notes):
--   - Cardiovascular System (sort: 15) - 23 notes
--   - Endocrine System (sort: 16) - 13 notes
--   - Respiratory System (sort: 18) - 16 notes
--
-- Result: 33 global folders → 30 global folders

-- ========================================
-- STEP 1: PREVIEW - Show what will be deleted
-- ========================================
SELECT 
  id,
  folder_name,
  sort_order,
  '🗑️ WILL BE DELETED (0 notes)' as action
FROM note_folders
WHERE id IN (
  '46929d5d-cb73-4ce9-b999-fecb665d3252',  -- Cardiovascular (0 notes)
  'e23d197f-a443-4ec9-8a54-08837a399625',  -- Endocrine (0 notes)
  '86fd1834-ae55-493f-9a51-428f637f6105'   -- Respiratory (0 notes)
)
ORDER BY sort_order;

-- Expected output:
-- | id                                   | folder_name    | sort_order | action                        |
-- | 46929d5d-cb73-4ce9-b999-fecb665d3252 | Cardiovascular | 0          | 🗑️ WILL BE DELETED (0 notes) |
-- | 86fd1834-ae55-493f-9a51-428f637f6105 | Respiratory    | 1          | 🗑️ WILL BE DELETED (0 notes) |
-- | e23d197f-a443-4ec9-8a54-08837a399625 | Endocrine      | 3          | 🗑️ WILL BE DELETED (0 notes) |


-- ========================================
-- STEP 2: EXECUTE DELETION (uncomment to run)
-- ========================================
/*
UPDATE note_folders
SET deleted_at = NOW()
WHERE id IN (
  '46929d5d-cb73-4ce9-b999-fecb665d3252',  -- Cardiovascular (empty)
  'e23d197f-a443-4ec9-8a54-08837a399625',  -- Endocrine (empty)
  '86fd1834-ae55-493f-9a51-428f637f6105'   -- Respiratory (empty)
);
*/


-- ========================================
-- STEP 3: UPDATE SORT ORDER to 1-24
-- ========================================
-- Reorder the remaining 30 folders to 1-24 in your desired sequence

/*
-- Update each folder's sort_order individually
UPDATE note_folders SET sort_order = 1  WHERE id = '63beae0e-56fc-440d-80d5-f5620e504bad'; -- Medical Terminology
UPDATE note_folders SET sort_order = 2  WHERE id = 'd7fecc1e-cddc-4427-b6da-169cda3784c8'; -- Human Anatomy
UPDATE note_folders SET sort_order = 3  WHERE id = '3fa86c9d-bbe2-4161-9fb2-875529ba8f44'; -- Medication Suffixes and Drug Classes
UPDATE note_folders SET sort_order = 4  WHERE id = 'd9086ec4-ebd9-44eb-a7dc-f30c1c4f9920'; -- Cardiovascular System (23 notes)
UPDATE note_folders SET sort_order = 5  WHERE id = 'ddc50243-c1f0-450a-a4a7-86165b233144'; -- Endocrine System (13 notes)
UPDATE note_folders SET sort_order = 6  WHERE id = '5c3b9413-c7f8-4ea6-8185-55405027933b'; -- Gastrointestinal & Hepatic System
UPDATE note_folders SET sort_order = 7  WHERE id = '39485084-01ab-43dd-ad23-aa8230c5267f'; -- Respiratory System (16 notes)
UPDATE note_folders SET sort_order = 8  WHERE id = '051ee672-2b00-4e5d-aef8-a9504822a1e0'; -- Renal
UPDATE note_folders SET sort_order = 9  WHERE id = '5e633755-e0a1-433b-85cf-f8ee8ae47608'; -- Fluids, Electrolytes & Nutrition
UPDATE note_folders SET sort_order = 10 WHERE id = 'b7698eed-8c21-409d-8138-f39219047d7b'; -- Eye Disorders
UPDATE note_folders SET sort_order = 11 WHERE id = 'a0816f2d-fed4-4f34-b0e1-74b3ee79e41b'; -- EENT
UPDATE note_folders SET sort_order = 12 WHERE id = '65a3b536-f479-4d2a-9919-09415efd80e5'; -- Burns and Skin
UPDATE note_folders SET sort_order = 13 WHERE id = 'ef675f42-539b-4a2c-b540-45c48c97426c'; -- Reproductive and Sexual Health System
UPDATE note_folders SET sort_order = 14 WHERE id = '2b0e70b4-8733-49bb-9776-44856649f19a'; -- Maternal Health
UPDATE note_folders SET sort_order = 15 WHERE id = '0013ba77-dbca-4a1e-9277-d00a6b505dc9'; -- Pediatrics
UPDATE note_folders SET sort_order = 16 WHERE id = 'cf0c5f78-4bc3-4404-a456-9d1e121acd60'; -- Medical-Surgical Care
UPDATE note_folders SET sort_order = 17 WHERE id = '7f7c307b-aa1c-4eaf-a978-ea38e286a913'; -- Mental Health
UPDATE note_folders SET sort_order = 18 WHERE id = '83319e81-cb34-49c7-b7b8-8c0cb231133c'; -- Autoimmune & Infectious Disorders
UPDATE note_folders SET sort_order = 19 WHERE id = 'c3b3b8ee-4207-4b1a-88f9-80fd7346f416'; -- Neurology
UPDATE note_folders SET sort_order = 20 WHERE id = '814c969a-bfc4-4b4c-b65c-b6ac88f5adb7'; -- Cancer
UPDATE note_folders SET sort_order = 21 WHERE id = 'bd7c0755-c410-48a1-a8f7-7f34a23cdc8e'; -- Musculoskeletal Disorders
UPDATE note_folders SET sort_order = 22 WHERE id = '318c2b19-ea2a-4484-993f-84491a2acc25'; -- Psycho-Social Aspects
UPDATE note_folders SET sort_order = 23 WHERE id = 'f3dc23f2-f5da-410e-85e5-7c2b04fc602f'; -- Nursing Skills and Fundamentals
UPDATE note_folders SET sort_order = 24 WHERE id = '6c4f8d85-9fd4-4269-bfbc-e251700b5c7d'; -- Pharmacology
*/


-- ========================================
-- STEP 4: VERIFY final state
-- ========================================
-- Run this AFTER executing Steps 2 & 3

-- 4A: Check folder counts
SELECT 
  COUNT(*) as total_folders,
  COUNT(*) FILTER (WHERE group_letter IS NULL) as global_folders,
  COUNT(*) FILTER (WHERE group_letter IS NOT NULL) as group_specific_folders
FROM note_folders
WHERE deleted_at IS NULL;

-- Expected result AFTER Step 2 & 3:
-- | total_folders | global_folders | group_specific_folders |
-- | 34            | 30             | 4                      |


-- 4B: Show final folders in correct order
SELECT 
  sort_order,
  id,
  folder_name,
  LOWER(REGEXP_REPLACE(folder_name, ' System$', '', 'i')) as normalized_name,
  '✅ FINAL' as status
FROM note_folders
WHERE deleted_at IS NULL
  AND group_letter IS NULL
ORDER BY sort_order
LIMIT 24;

-- Expected: 30 rows total, first 24 sorted 1-24 in your desired sequence


-- 4C: Check for duplicate normalized names (should be 0 after deletion)
SELECT 
  LOWER(REGEXP_REPLACE(folder_name, ' System$', '', 'i')) as normalized_name,
  COUNT(*) as count,
  STRING_AGG(folder_name || ' (' || sort_order || ')', ', ' ORDER BY sort_order) as variants
FROM note_folders
WHERE deleted_at IS NULL
  AND group_letter IS NULL
GROUP BY normalized_name
HAVING COUNT(*) > 1;

-- Expected AFTER Step 2: 0 rows (no duplicates)


-- 4D: Verify notes are still linked correctly
SELECT 
  f.folder_name,
  COUNT(n.id) as note_count
FROM note_folders f
LEFT JOIN student_notes n ON 
  f.folder_name = n.category
  AND n.deleted = false
WHERE f.deleted_at IS NULL
  AND f.group_letter IS NULL
  AND f.folder_name IN ('Cardiovascular System', 'Endocrine System', 'Respiratory System')
GROUP BY f.folder_name
ORDER BY f.folder_name;

-- Expected:
-- | folder_name           | note_count |
-- | Cardiovascular System | 23         |
-- | Endocrine System      | 13         |
-- | Respiratory System    | 16         |


-- ========================================
-- ROLLBACK if needed (uncomment to undo)
-- ========================================
/*
UPDATE note_folders
SET deleted_at = NULL
WHERE deleted_at >= NOW() - INTERVAL '1 hour';
*/
