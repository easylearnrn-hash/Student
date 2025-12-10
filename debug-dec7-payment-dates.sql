-- Debug: Show exact payment dates and student linkage for Dec 7 students
SELECT 
  p.id,
  p.date,
  p.student_id,
  p.linked_student_id,
  p.resolved_student_name,
  p.payer_name,
  p.amount,
  s.id as student_table_id,
  s.name as student_table_name
FROM payments p
LEFT JOIN students s ON (
  p.student_id::text = s.id::text 
  OR p.linked_student_id::text = s.id::text
  OR p.resolved_student_name = s.name
)
WHERE p.date >= '2025-12-07' AND p.date < '2025-12-08'
ORDER BY p.date;

-- Also check manual payment_records
SELECT 
  pr.id,
  pr.date,
  pr.student_id,
  pr.amount,
  pr.status,
  s.id as student_table_id,
  s.name as student_table_name
FROM payment_records pr
LEFT JOIN students s ON pr.student_id = s.id
WHERE pr.date >= '2025-12-07' AND pr.date < '2025-12-08'
ORDER BY pr.date;
