-- Check if Narine is marked absent on her class dates
SELECT 
  sa.student_id,
  s.name,
  sa.class_date
FROM student_absences sa
JOIN students s ON s.id = sa.student_id
WHERE s.name = 'Narine Avetisyan'
  AND sa.class_date IN ('2025-12-01', '2025-12-05', '2025-12-08', '2025-12-12')
ORDER BY sa.class_date;
