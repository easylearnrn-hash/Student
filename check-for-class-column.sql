-- Check if for_class column exists in payments table
SELECT column_name, data_type, is_nullable, column_default
FROM information_schema.columns
WHERE table_name = 'payments' 
  AND column_name = 'for_class';

-- Show sample payment with for_class value
SELECT id, student_id, date, for_class, amount, resolved_student_name
FROM payments
WHERE date >= '2025-12-01'
ORDER BY date DESC
LIMIT 10;
