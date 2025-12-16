-- Simple query to check Narine's December payments
SELECT 
  p.id,
  p.date::date as when_received,
  TO_CHAR(p.date, 'Day') as received_day,
  p.for_class as allocated_to_date,
  TO_CHAR(p.for_class, 'Day') as allocated_day,
  (p.for_class - p.date::date) as days_apart,
  p.amount,
  CASE 
    WHEN p.for_class = p.date::date THEN '✅ Same day'
    ELSE '⚠️ Reassigned (' || (p.for_class - p.date::date) || ' days)'
  END as status
FROM payments p
JOIN students s ON p.student_id::bigint = s.id
WHERE s.name = 'Narine Avetisyan'
  AND p.date >= '2025-12-01' 
  AND p.date < '2025-12-16'
ORDER BY p.date;
