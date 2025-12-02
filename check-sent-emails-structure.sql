-- Check the actual structure of sent_emails table
-- Run this in Supabase SQL Editor to see what columns exist

SELECT column_name, data_type, is_nullable
FROM information_schema.columns
WHERE table_name = 'sent_emails'
ORDER BY ordinal_position;
