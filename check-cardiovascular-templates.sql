-- Check how many templates exist for Cardiovascular folder
SELECT 
  nf.folder_name,
  nf.id as folder_id,
  COUNT(nt.id) as template_count
FROM note_folders nf
LEFT JOIN note_templates nt ON nt.folder_id = nf.id
WHERE nf.folder_name = 'Cardiovascular'
  AND nf.deleted_at IS NULL
GROUP BY nf.folder_name, nf.id;

-- Check actual notes assigned to student
SELECT 
  COUNT(*) as assigned_notes_count,
  COUNT(CASE WHEN read = true THEN 1 END) as viewed_count,
  COUNT(CASE WHEN requires_payment = false THEN 1 END) as paid_count
FROM student_notes
WHERE system LIKE '%Cardiovascular%';

-- If template_count is 0 but you have 23 notes, that's the issue!
-- SOLUTION: Either populate note_templates OR assume all posted notes = 100%
