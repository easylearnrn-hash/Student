-- Check December 15 Group C payments
-- Students: Lusine Hovhannisyan (32), Varduhi Nersesyan (37), Anahit Hovhannisyan (40), 
--           Ofelya Minasyan (41), Taguhi Barseghyan (42)

-- First, verify student IDs
SELECT id, name, group_name 
FROM students 
WHERE name IN (
  'Lusine Hovhannisyan',
  'Varduhi Nersesyan',
  'Anahit Hovhannisyan',
  'Ofelya Minasyan',
  'Taguhi Barseghyan'
)
ORDER BY name;

-- Check payments for Dec 15 with for_class = 2025-12-15
SELECT 
  id,
  student_id,
  linked_student_id,
  payer_name,
  resolved_student_name,
  amount,
  for_class,
  date as receipt_date
FROM payments
WHERE for_class = '2025-12-15'
ORDER BY payer_name;

-- Check if there are payments with these payer names but different student_id
SELECT 
  id,
  student_id,
  linked_student_id,
  payer_name,
  resolved_student_name,
  amount,
  for_class,
  date as receipt_date
FROM payments
WHERE (
  payer_name ILIKE '%Lusine%' OR
  payer_name ILIKE '%Varduhi%' OR
  payer_name ILIKE '%Anahit%' OR
  payer_name ILIKE '%Ofelya%' OR
  payer_name ILIKE '%Taguhi%' OR
  resolved_student_name ILIKE '%Lusine%' OR
  resolved_student_name ILIKE '%Varduhi%' OR
  resolved_student_name ILIKE '%Anahit%' OR
  resolved_student_name ILIKE '%Ofelya%' OR
  resolved_student_name ILIKE '%Taguhi%'
)
AND for_class >= '2025-12-01'
ORDER BY for_class, payer_name;
