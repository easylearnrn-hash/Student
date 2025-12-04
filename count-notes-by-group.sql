-- Count notes by group_name to see the breakdown
SELECT group_name, COUNT(*) as note_count
FROM student_notes
WHERE deleted = false
GROUP BY group_name
ORDER BY note_count DESC;

-- Total count
SELECT COUNT(*) as total_notes
FROM student_notes
WHERE deleted = false;
