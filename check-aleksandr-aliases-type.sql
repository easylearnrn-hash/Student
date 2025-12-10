-- Check Aleksandr's actual aliases column type and value
SELECT 
  id,
  name,
  group_name,
  aliases,
  pg_typeof(aliases) as aliases_type,
  aliases::text as aliases_text,
  LENGTH(aliases::text) as text_length
FROM students
WHERE id = 72;
