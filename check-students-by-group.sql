-- Check which students are in which groups

SELECT 
  group_letter,
  COUNT(*) as student_count,
  STRING_AGG(name, ', ' ORDER BY name) as students
FROM students
WHERE show_in_grid = true
  AND group_letter IS NOT NULL
GROUP BY group_letter
ORDER BY group_letter;
