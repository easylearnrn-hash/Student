-- Check Group C ongoing system in database
SELECT 
  folder_name,
  group_letter,
  is_current,
  description,
  sort_order,
  created_at
FROM note_folders
WHERE group_letter = 'C'
  OR (group_letter IS NULL AND folder_name IN (
    SELECT folder_name FROM note_folders WHERE group_letter = 'C'
  ))
ORDER BY group_letter NULLS FIRST, folder_name;
