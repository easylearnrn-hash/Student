-- Check what columns exist in the payments table
SELECT column_name, data_type 
FROM information_schema.columns 
WHERE table_name = 'payments'
ORDER BY ordinal_position;
