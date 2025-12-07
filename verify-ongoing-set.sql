-- Verify which folder is marked as ongoing
SELECT 
  folder_name,
  is_current,
  CASE 
    WHEN is_current = TRUE THEN '🟡 THIS IS ONGOING!'
    ELSE '⚪ Normal'
  END as status
FROM note_folders
WHERE deleted_at IS NULL
ORDER BY is_current DESC, sort_order;
