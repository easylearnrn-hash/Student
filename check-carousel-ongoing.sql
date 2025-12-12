-- Check which systems are marked as ongoing (is_current = true)
SELECT 
  folder_name,
  group_letter,
  is_current,
  created_at
FROM note_folders
WHERE deleted_at IS NULL
  AND is_current = TRUE
ORDER BY group_letter, folder_name;
