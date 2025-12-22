-- CRITICAL FIX: Remove incorrect bulk permissions and restore based on actual student purchases
-- Problem: We posted all notes to all groups, but students should only see what they paid for

-- Step 1: Clear the bulk restore we just did (all records with granted_by = 'admin_restore')
DELETE FROM student_note_permissions
WHERE granted_by = 'admin_restore';

-- Step 2: Check what students actually purchased
-- This query shows which students bought which notes
SELECT 
  s.name as student_name,
  SUBSTRING(s.group_name, 7, 1) as group_letter,
  sn.title as note_title,
  np.status as purchase_status,
  np.created_at as purchased_at
FROM note_purchases np
JOIN students s ON np.student_id = s.id
JOIN student_notes sn ON np.note_id = sn.id
WHERE np.status = 'completed'
ORDER BY s.name, np.created_at DESC;

-- Step 3: Recreate permissions ONLY for students who actually purchased
-- This restores individual student access based on their purchases
INSERT INTO student_note_permissions (note_id, student_id, group_name, is_accessible, granted_at, granted_by)
SELECT 
  np.note_id,
  np.student_id,
  SUBSTRING(s.group_name, 7, 1) as group_name,
  true as is_accessible,
  NOW() as granted_at,
  'purchase_restore' as granted_by
FROM note_purchases np
JOIN students s ON np.student_id = s.id
WHERE np.status = 'completed'
ON CONFLICT (note_id, student_id, group_name) DO UPDATE
SET is_accessible = true, granted_at = NOW();

-- Verify: Show which students now have access to which notes
SELECT 
  s.name as student_name,
  SUBSTRING(s.group_name, 7, 1) as group_letter,
  sn.title as note_title,
  snp.is_accessible
FROM student_note_permissions snp
JOIN students s ON snp.student_id = s.id
JOIN student_notes sn ON snp.note_id = sn.id
WHERE snp.student_id IS NOT NULL
ORDER BY s.name, sn.title
LIMIT 50;
