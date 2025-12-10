-- First, check what columns exist in note_folders table
SELECT column_name, data_type 
FROM information_schema.columns 
WHERE table_name = 'note_folders'
ORDER BY ordinal_position;
