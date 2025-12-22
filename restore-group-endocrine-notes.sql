-- Find which notes were previously posted to which groups
-- by checking for any group-based permissions (where student_id IS NULL)

-- First, check if we have any historical group permissions left
SELECT 
  sn.title,
  sn.system_category,
  snp.group_name,
  snp.student_id,
  snp.granted_at
FROM student_note_permissions snp
JOIN student_notes sn ON snp.note_id = sn.id
WHERE snp.student_id IS NULL  -- Group permissions, not individual
ORDER BY snp.granted_at DESC
LIMIT 100;

-- Check if there's any record in a log table or history
SELECT table_name 
FROM information_schema.tables 
WHERE table_schema = 'public' 
AND table_name LIKE '%log%' OR table_name LIKE '%history%';

-- Alternative: Let's restore ALL Endocrine system notes to Group E
-- Since you said you posted the whole endocrine system for Group E
INSERT INTO student_note_permissions (note_id, group_name, is_accessible, granted_at, granted_by)
SELECT 
  id as note_id,
  'E' as group_name,
  true as is_accessible,
  NOW() as granted_at,
  'group_e_endocrine_restore' as granted_by
FROM student_notes
WHERE system_category = 'Endocrine'
AND is_system_note = true
ON CONFLICT (note_id, student_id, group_name) DO UPDATE
SET is_accessible = true;

-- Verify what was restored
SELECT 
  sn.title,
  sn.system_category,
  snp.group_name
FROM student_note_permissions snp
JOIN student_notes sn ON snp.note_id = sn.id
WHERE snp.granted_by = 'group_e_endocrine_restore';
