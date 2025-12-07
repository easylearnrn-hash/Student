-- Check the actual structure of admin_accounts table
SELECT column_name, data_type, is_nullable
FROM information_schema.columns
WHERE table_name = 'admin_accounts'
ORDER BY ordinal_position;
