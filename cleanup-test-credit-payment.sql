-- Delete the test credit payment record
DELETE FROM credit_payments 
WHERE student_id = 1 
  AND class_date = '2025-12-10'
  AND amount = 50.00;

-- Verify it's deleted
SELECT * FROM credit_payments 
WHERE student_id = 1 
ORDER BY created_at DESC;
