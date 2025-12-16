-- Find Narine's student.id and verify type
SELECT 
  id,
  pg_typeof(id) as id_type,
  name,
  group_name,
  show_in_grid
FROM students
WHERE name = 'Narine Avetisyan';

-- Check her payment records student_id values
SELECT 
  id as payment_id,
  student_id,
  pg_typeof(student_id) as student_id_type,
  for_class,
  amount
FROM payments
WHERE for_class IN ('2025-12-01', '2025-12-05', '2025-12-08', '2025-12-12')
  AND student_id IS NOT NULL
ORDER BY for_class;
