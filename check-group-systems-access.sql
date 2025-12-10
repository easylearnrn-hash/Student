-- Check which systems/folders are visible to each group

SELECT 
  nf.folder_name as system_name,
  nf.group_letter,
  nf.is_current,
  nf.sort_order,
  COUNT(sn.id) as note_count
FROM note_folders nf
LEFT JOIN student_notes sn ON sn.category = nf.folder_name AND sn.deleted = false
WHERE nf.group_letter IS NOT NULL  -- Group-specific folders
GROUP BY nf.id, nf.folder_name, nf.group_letter, nf.is_current, nf.sort_order
ORDER BY nf.group_letter, nf.sort_order;

-- Also check free access grants
SELECT 
  access_type,
  group_letter,
  student_id,
  note_id
FROM note_free_access
ORDER BY access_type, group_letter;
