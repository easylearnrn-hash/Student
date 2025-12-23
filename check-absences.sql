-- Check if Lusine (student_id=10) has any absences
SELECT 
  sa.class_date,
  sa.created_at,
  s.name,
  s.group_name
FROM student_absences sa
JOIN students s ON s.id = sa.student_id
WHERE sa.student_id = 10
ORDER BY sa.class_date DESC;
