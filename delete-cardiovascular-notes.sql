-- Delete all Cardiovascular System notes that have broken paths
-- Run this in Supabase SQL Editor

-- First, let's see what we're about to delete
SELECT id, title, pdf_url, created_at
FROM student_notes
WHERE group_name = 'Cardiovascular System'
  AND is_system_note = true
  AND deleted = false
ORDER BY created_at DESC;

-- Uncomment the line below to actually delete them
-- UPDATE student_notes SET deleted = true WHERE group_name = 'Cardiovascular System' AND is_system_note = true AND deleted = false;

-- After deletion, verify:
-- SELECT COUNT(*) FROM student_notes WHERE group_name = 'Cardiovascular System' AND is_system_note = true AND deleted = false;
