-- Check payments received today (December 12, 2025)
SELECT 
  id,
  student_id,
  linked_student_id,
  resolved_student_name,
  payer_name,
  amount,
  date,
  created_at,
  status
FROM payments
WHERE date >= '2025-12-12'
  OR created_at::date >= '2025-12-12'
ORDER BY created_at DESC
LIMIT 10;
