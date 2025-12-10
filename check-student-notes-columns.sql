-- Check what columns exist in student_notes table
SELECT column_name, data_type 
FROM information_schema.columns 
WHERE table_name = 'student_notes'
ORDER BY ordinal_position;
