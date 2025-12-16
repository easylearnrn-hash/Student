-- First, let's see what columns actually exist in the students table
SELECT column_name, data_type 
FROM information_schema.columns 
WHERE table_name = 'students'
ORDER BY ordinal_position;

-- Then check Varduhi's record with all columns
SELECT *
FROM students
WHERE LOWER(name) LIKE '%varduhi%'
LIMIT 1;
