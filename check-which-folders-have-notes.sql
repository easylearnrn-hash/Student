-- ========================================
-- CHECK: Which folders should we KEEP?
-- ========================================
-- This verifies which folder variant has the most notes linked to it

SELECT 
  f.id,
  f.folder_name,
  f.sort_order,
  COUNT(n.id) as note_count,
  CASE 
    WHEN COUNT(n.id) > 0 THEN '✅ KEEP (has notes)'
    ELSE '🗑️ DELETE (no notes)'
  END as recommendation
FROM note_folders f
LEFT JOIN student_notes n ON 
  f.folder_name = n.category
  AND n.deleted = false
WHERE f.deleted_at IS NULL
  AND f.group_letter IS NULL
  AND LOWER(REGEXP_REPLACE(f.folder_name, ' System$', '', 'i')) IN ('cardiovascular', 'endocrine', 'respiratory')
GROUP BY f.id, f.folder_name, f.sort_order
ORDER BY folder_name, note_count DESC;

-- This will show which variant each note is using
-- If notes use "Cardiovascular System", we should KEEP that and DELETE "Cardiovascular"
