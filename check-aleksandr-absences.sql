-- Check if Aleksandr has any absences recorded
SELECT * FROM student_absences
WHERE student_id = 72
ORDER BY class_date DESC;

-- Check if there are any cancelled classes for Group A
SELECT * FROM skipped_classes
WHERE group_name = 'A'
ORDER BY class_date DESC;
