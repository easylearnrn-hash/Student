-- Check payment_records from Dec 1-7, 2025
SELECT 
  id,
  student_id,
  date,
  amount,
  status,
  created_at
FROM payment_records
WHERE date >= '2025-12-01' 
  AND date <= '2025-12-07'
ORDER BY date DESC, created_at DESC;

-- Check automated payments from Dec 1-7, 2025
SELECT 
  id,
  student_id,
  linked_student_id,
  resolved_student_name,
  payer_name,
  amount,
  date,
  created_at
FROM payments
WHERE date >= '2025-12-01' 
  AND date <= '2025-12-07'
ORDER BY date DESC, created_at DESC;

-- Combined view showing both manual and automated payments
SELECT 
  'manual' as source,
  pr.id::text,
  pr.student_id::text,
  s.name as student_name,
  pr.date as payment_date,
  pr.amount,
  pr.status,
  pr.created_at
FROM payment_records pr
LEFT JOIN students s ON s.id = pr.student_id
WHERE pr.date >= '2025-12-01' 
  AND pr.date <= '2025-12-07'

UNION ALL

SELECT 
  'automated' as source,
  p.id::text,
  COALESCE(p.linked_student_id, p.student_id)::text as student_id,
  COALESCE(p.resolved_student_name, p.payer_name) as student_name,
  p.date as payment_date,
  p.amount,
  'paid' as status,
  p.created_at
FROM payments p
WHERE p.date >= '2025-12-01' 
  AND p.date <= '2025-12-07'

ORDER BY payment_date DESC, created_at DESC;
