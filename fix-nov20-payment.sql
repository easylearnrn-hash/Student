-- Fix the Nov 20 payment that's incorrectly linked to student ID 5
UPDATE payments
SET 
  linked_student_id = '13',
  resolved_student_name = 'Sona Husikyan'
WHERE id = '19aa4730285f9d46'
  AND payer_name = 'Husikyan Consulting, I.Nc.';

-- Verify the fix
SELECT 
  id, 
  payer_name, 
  amount, 
  date, 
  linked_student_id, 
  resolved_student_name,
  CASE 
    WHEN linked_student_id = '13' THEN '✅ Linked to Sona'
    ELSE '❌ Wrong student: ' || linked_student_id
  END as status
FROM payments
WHERE payer_name = 'Husikyan Consulting, I.Nc.'
ORDER BY date DESC;
