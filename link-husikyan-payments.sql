-- Link the two unlinked Husikyan Consulting payments to Sona Husikyan
-- Most payments are already linked (linked_student_id = '13'), just need to fix Dec 9 and Dec 11

UPDATE payments
SET 
  linked_student_id = '13',
  resolved_student_name = 'Sona Husikyan'
WHERE payer_name = 'Husikyan Consulting, I.Nc.'
  AND linked_student_id IS NULL;

-- Verify all payments are now linked
SELECT 
  id, 
  payer_name, 
  amount, 
  date, 
  linked_student_id, 
  resolved_student_name,
  CASE 
    WHEN linked_student_id = '13' THEN '✅ Linked'
    ELSE '❌ Not linked'
  END as status
FROM payments
WHERE payer_name = 'Husikyan Consulting, I.Nc.'
ORDER BY date DESC;
