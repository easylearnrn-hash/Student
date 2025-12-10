-- ========================================
-- ONE-CLICK CLEANUP: Delete Duplicates + Extras
-- ========================================
-- This will reduce 33 global folders → 24 global folders
-- by deleting the 3 confirmed duplicates + any extra folders

-- STEP 1: PREVIEW what will be deleted
WITH folders_to_delete AS (
  -- Delete these 3 specific duplicate folders (keep the ones with lower sort_order)
  SELECT id, folder_name, sort_order, 'Duplicate' as reason
  FROM note_folders
  WHERE id IN (
    'd9086ec4-ebd9-44eb-a7dc-f30c1c4f9920',  -- Cardiovascular System (sort: 15) - DELETE
    'ddc50243-c1f0-450a-a4a7-86165b233144',  -- Endocrine System (sort: 16) - DELETE
    '39485084-01ab-43dd-ad23-aa8230c5267f'   -- Respiratory System (sort: 18) - DELETE
  )
  
  UNION ALL
  
  -- Also delete any folders NOT in the expected 24-system list
  SELECT 
    id, 
    folder_name, 
    sort_order, 
    'Not in expected list' as reason
  FROM note_folders
  WHERE deleted_at IS NULL
    AND group_letter IS NULL
    AND LOWER(REGEXP_REPLACE(folder_name, ' System$', '', 'i')) NOT IN (
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
    )
)
SELECT 
  id,
  folder_name,
  sort_order,
  reason,
  '🗑️ WILL BE DELETED' as action
FROM folders_to_delete
ORDER BY reason, sort_order;

-- Run this first to see what will be deleted


-- STEP 2: EXECUTE CLEANUP (uncomment to run)
-- This soft-deletes the duplicate folders
/*
UPDATE note_folders
SET deleted_at = NOW()
WHERE id IN (
  'd9086ec4-ebd9-44eb-a7dc-f30c1c4f9920',  -- Cardiovascular System
  'ddc50243-c1f0-450a-a4a7-86165b233144',  -- Endocrine System
  '39485084-01ab-43dd-ad23-aa8230c5267f'   -- Respiratory System
);
*/

-- Also delete extras not in expected list (uncomment to run)
/*
UPDATE note_folders
SET deleted_at = NOW()
WHERE deleted_at IS NULL
  AND group_letter IS NULL
  AND LOWER(REGEXP_REPLACE(folder_name, ' System$', '', 'i')) NOT IN (
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
  );
*/


-- STEP 3: VERIFY cleanup worked
-- Run this AFTER executing Step 2
SELECT 
  COUNT(*) as total_folders,
  COUNT(*) FILTER (WHERE group_letter IS NULL) as global_folders,
  COUNT(*) FILTER (WHERE group_letter IS NOT NULL) as group_specific_folders,
  COUNT(DISTINCT LOWER(REGEXP_REPLACE(folder_name, ' System$', '', 'i'))) 
    FILTER (WHERE group_letter IS NULL) as unique_global_systems
FROM note_folders
WHERE deleted_at IS NULL;

-- Expected result AFTER cleanup:
-- | total_folders | global_folders | group_specific_folders | unique_global_systems |
-- | 28            | 24             | 4                      | 24                    |


-- STEP 4: List remaining folders in your desired order
-- Run this to see the final 24 folders
WITH expected_order AS (
  SELECT 
    unnest(ARRAY[
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
    ]) as system_name,
    ROW_NUMBER() OVER () as desired_order
)
SELECT 
  eo.desired_order as new_sort_order,
  eo.system_name,
  f.id,
  f.folder_name,
  f.sort_order as old_sort_order,
  CASE 
    WHEN f.id IS NULL THEN '⚠️ MISSING'
    ELSE '✅ EXISTS'
  END as status
FROM expected_order eo
LEFT JOIN note_folders f ON 
  LOWER(REGEXP_REPLACE(f.folder_name, ' System$', '', 'i')) = eo.system_name
  AND f.deleted_at IS NULL
  AND f.group_letter IS NULL
ORDER BY eo.desired_order;


-- ROLLBACK if needed (uncomment to undo deletion)
/*
UPDATE note_folders
SET deleted_at = NULL
WHERE deleted_at >= NOW() - INTERVAL '1 hour';
*/
