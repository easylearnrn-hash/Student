-- Check which note folders are marked as ongoing/current
SELECT 
  id,
  folder_name,
  is_current,
  sort_order,
  CASE 
    WHEN is_current = TRUE THEN '🟡 ONGOING'
    WHEN is_current = FALSE THEN '⚪ Normal'
    ELSE '⚠️ NULL (needs fix)'
  END as status
FROM note_folders
WHERE deleted_at IS NULL
ORDER BY sort_order;

-- Quick check: Which folder is currently marked as ongoing?
SELECT 
  folder_name,
  is_current
FROM note_folders
WHERE deleted_at IS NULL
  AND is_current = TRUE;
