-- Find Narine's exact student.id from students table
SELECT 
  id,
  pg_typeof(id) as id_type,
  name,
  group_name,
  show_in_grid,
  price_per_class
FROM students
WHERE name = 'Narine Avetisyan';
