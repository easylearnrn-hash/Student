-- Find the 19 payments with NULL student_id AND NULL linked_student_id
-- These payments can't be matched to students!

SELECT 
  id,
  date,
  amount,
  payer_name,
  resolved_student_name,
  student_id,
  linked_student_id,
  created_at
FROM payments
WHERE student_id IS NULL 
  AND linked_student_id IS NULL
ORDER BY date DESC;

-- Show what names these payments have that could be used for matching
SELECT 
  COALESCE(resolved_student_name, payer_name, 'NO NAME') as name_in_payment,
  COUNT(*) as payment_count,
  SUM(amount) as total_amount,
  array_agg(date ORDER BY date) as payment_dates
FROM payments
WHERE student_id IS NULL 
  AND linked_student_id IS NULL
GROUP BY COALESCE(resolved_student_name, payer_name, 'NO NAME')
ORDER BY payment_count DESC;

-- Try to match these NULL payments to existing students by name
SELECT 
  p.id as payment_id,
  p.date,
  p.amount,
  p.payer_name,
  p.resolved_student_name,
  s.id as matched_student_id,
  s.name as matched_student_name,
  CASE
    WHEN s.id IS NOT NULL THEN '✅ CAN BE LINKED'
    ELSE '❌ NO MATCH FOUND'
  END as match_status
FROM payments p
LEFT JOIN students s ON (
  s.name ILIKE p.resolved_student_name 
  OR s.name ILIKE p.payer_name
  OR p.resolved_student_name ILIKE '%' || s.name || '%'
  OR p.payer_name ILIKE '%' || s.name || '%'
)
WHERE p.student_id IS NULL 
  AND p.linked_student_id IS NULL
ORDER BY p.date DESC;
