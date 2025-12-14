-- Check the actual schema of the payments table
SELECT column_name, data_type, is_nullable
FROM information_schema.columns
WHERE table_name = 'payments'
ORDER BY ordinal_position;

-- Also show a sample payment record to see the structure
SELECT *
FROM payments
WHERE payer_name = 'Husikyan Consulting, I.Nc.'
LIMIT 1;
