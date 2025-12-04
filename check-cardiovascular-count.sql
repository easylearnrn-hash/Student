-- Count notes by group_name to see distribution
SELECT group_name, COUNT(*) as count
FROM student_notes
WHERE deleted = false
GROUP BY group_name
ORDER BY count DESC;

-- Specifically check Cardiovascular
SELECT COUNT(*) as cardiovascular_count
FROM student_notes
WHERE deleted = false 
  AND group_name ILIKE '%cardiovascular%';

-- Show all Cardiovascular notes
SELECT id, title, group_name, deleted
FROM student_notes
WHERE group_name ILIKE '%cardiovascular%'
ORDER BY id;
