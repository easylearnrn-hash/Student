-- Check the actual column names in students table
SELECT column_name, data_type
FROM information_schema.columns
WHERE table_name = 'students' 
AND column_name LIKE '%group%'
ORDER BY ordinal_position;
