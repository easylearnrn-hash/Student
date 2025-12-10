-- ===================================================================
-- CHECK SYSTEMS COUNT IN NOTE_FOLDERS TABLE
-- This will help identify which systems are showing up and why
-- ===================================================================

-- 0. FIRST: Check what columns exist in student_notes table
SELECT column_name, data_type 
FROM information_schema.columns 
WHERE table_name = 'student_notes'
ORDER BY ordinal_position;

-- 1. COUNT ALL FOLDERS (should show 34 based on your logs)
SELECT COUNT(*) as total_folders
FROM note_folders
WHERE deleted_at IS NULL;

-- 2. LIST ALL FOLDERS WITH DETAILS
SELECT 
  id,
  folder_name,
  group_letter,
  is_current,
  sort_order,
  created_at
FROM note_folders
WHERE deleted_at IS NULL
ORDER BY sort_order, folder_name;

-- 3. COUNT UNIQUE FOLDER NAMES (after normalizing)
SELECT COUNT(DISTINCT LOWER(REPLACE(folder_name, ' System', ''))) as unique_normalized_names
FROM note_folders
WHERE deleted_at IS NULL;

-- 4. FIND DUPLICATE FOLDER NAMES (same name, different group_letter)
SELECT 
  LOWER(REPLACE(folder_name, ' System', '')) as normalized_name,
  COUNT(*) as count,
  STRING_AGG(folder_name || ' (group: ' || COALESCE(group_letter, 'null') || ')', ', ') as variations
FROM note_folders
WHERE deleted_at IS NULL
GROUP BY LOWER(REPLACE(folder_name, ' System', ''))
HAVING COUNT(*) > 1
ORDER BY count DESC;

-- 5. SIMPLE: Just count folders per group_letter
SELECT 
  COALESCE(group_letter, 'global') as group_type,
  COUNT(*) as folder_count
FROM note_folders
WHERE deleted_at IS NULL
GROUP BY group_letter
ORDER BY group_letter NULLS FIRST;

-- 6. LIST ALL 34 FOLDERS - GROUPED BY NORMALIZED NAME
SELECT 
  LOWER(REPLACE(folder_name, ' System', '')) as normalized_name,
  STRING_AGG(
    id::text || ': ' || folder_name || ' (group: ' || COALESCE(group_letter, 'null') || ', current: ' || is_current::text || ')', 
    ' | '
  ) as all_variations
FROM note_folders
WHERE deleted_at IS NULL
GROUP BY LOWER(REPLACE(folder_name, ' System', ''))
ORDER BY normalized_name;

-- 7. FIND SYSTEMS MARKED AS CURRENT/ONGOING
SELECT 
  id,
  folder_name,
  group_letter,
  is_current,
  sort_order
FROM note_folders
WHERE deleted_at IS NULL
  AND is_current = TRUE
ORDER BY folder_name;

-- 8. SIMPLE FIX: Just show all 34 folders to see what you have
SELECT 
  id,
  folder_name,
  group_letter,
  is_current,
  sort_order,
  LOWER(REPLACE(folder_name, ' System', '')) as normalized_name
FROM note_folders
WHERE deleted_at IS NULL
ORDER BY 
  LOWER(REPLACE(folder_name, ' System', '')),
  group_letter NULLS FIRST;

-- 9. DELETE DUPLICATES: Keep first occurrence (by id), delete rest with same normalized name
-- (UNCOMMENT TO EXECUTE - BE VERY CAREFUL!)
/*
WITH ranked_folders AS (
  SELECT 
    id,
    folder_name,
    LOWER(REPLACE(folder_name, ' System', '')) as normalized_name,
    ROW_NUMBER() OVER (
      PARTITION BY LOWER(REPLACE(folder_name, ' System', ''))
      ORDER BY 
        CASE WHEN group_letter IS NOT NULL THEN 1 ELSE 2 END, -- Prefer group-specific
        id -- Then by oldest
    ) as rn
  FROM note_folders
  WHERE deleted_at IS NULL
)
UPDATE note_folders
SET deleted_at = NOW()
WHERE id IN (
  SELECT id FROM ranked_folders WHERE rn > 1
);
*/

-- 10. COUNT NOTES PER SYSTEM (using new category column)
SELECT 
  f.folder_name,
  f.group_letter,
  f.is_current,
  COUNT(DISTINCT n.id) as note_count
FROM note_folders f
LEFT JOIN student_notes n ON (
  LOWER(REPLACE(COALESCE(n.category, ''), ' System', '')) = LOWER(REPLACE(f.folder_name, ' System', ''))
)
WHERE f.deleted_at IS NULL
GROUP BY f.id, f.folder_name, f.group_letter, f.is_current
ORDER BY note_count DESC, f.folder_name;

-- 11. FIND EMPTY SYSTEMS (0 notes and not marked as current)
SELECT 
  f.id,
  f.folder_name,
  f.group_letter,
  f.is_current,
  COUNT(DISTINCT n.id) as note_count
FROM note_folders f
LEFT JOIN student_notes n ON (
  LOWER(REPLACE(COALESCE(n.category, ''), ' System', '')) = LOWER(REPLACE(f.folder_name, ' System', ''))
)
WHERE f.deleted_at IS NULL
  AND f.is_current = FALSE
GROUP BY f.id, f.folder_name, f.group_letter, f.is_current
HAVING COUNT(DISTINCT n.id) = 0
ORDER BY f.folder_name;
