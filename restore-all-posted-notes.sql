-- RESTORE ALL POSTED NOTES
-- This will recreate permissions for all system notes to all groups (A, C, D, E)
-- Run this to make all previously posted notes show as "posted" again

-- First, let's see what we have
SELECT COUNT(*) as total_notes FROM student_notes WHERE is_system_note = true;

-- Insert permissions for all system notes to all groups
-- This assumes notes were previously posted to all groups
INSERT INTO student_note_permissions (note_id, group_name, is_accessible, granted_at, granted_by)
SELECT 
  sn.id as note_id,
  g.group_name,
  true as is_accessible,
  NOW() as granted_at,
  'admin_restore' as granted_by
FROM student_notes sn
CROSS JOIN (
  SELECT 'A' as group_name
  UNION ALL SELECT 'C'
  UNION ALL SELECT 'D'
  UNION ALL SELECT 'E'
) g
WHERE sn.is_system_note = true
ON CONFLICT (note_id, student_id, group_name) DO NOTHING;

-- Verify the restore
SELECT 
  group_name,
  COUNT(*) as notes_posted
FROM student_note_permissions
GROUP BY group_name
ORDER BY group_name;

-- Show sample of restored permissions
SELECT 
  snp.note_id,
  sn.title,
  snp.group_name,
  snp.granted_at
FROM student_note_permissions snp
JOIN student_notes sn ON snp.note_id = sn.id
ORDER BY snp.granted_at DESC
LIMIT 20;
