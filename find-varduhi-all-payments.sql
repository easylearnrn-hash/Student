-- Find ALL Varduhi payments in December (including Dec 13)

-- Search by name variations
SELECT 
  id,
  student_id,
  payer_name,
  resolved_student_name,
  amount,
  date as payment_received_date,
  for_class,
  gmail_id,
  created_at,
  updated_at,
  CASE 
    WHEN for_class = date THEN '✅ Original date'
    ELSE '⚠️ Reassigned from ' || date || ' to ' || for_class
  END as status
FROM payments
WHERE (
  LOWER(payer_name) LIKE '%varduhi%' 
  OR LOWER(resolved_student_name) LIKE '%varduhi%'
  OR LOWER(payer_name) LIKE '%nersesyan%'
  OR LOWER(resolved_student_name) LIKE '%nersesyan%'
)
  AND date >= '2025-12-01'
  AND date <= '2025-12-31'
ORDER BY date DESC;

-- Also check if there's a payment with linked_student_id = 42
SELECT 
  id,
  student_id,
  linked_student_id,
  payer_name,
  resolved_student_name,
  amount,
  date as payment_received_date,
  for_class,
  gmail_id,
  updated_at
FROM payments
WHERE linked_student_id = '42'
  AND date >= '2025-12-01'
ORDER BY date DESC;

-- Check all December payments (to see if it might be under a different name)
SELECT 
  id,
  student_id,
  payer_name,
  amount,
  date as payment_received_date,
  for_class,
  gmail_id
FROM payments
WHERE date = '2025-12-13'
ORDER BY payer_name;
