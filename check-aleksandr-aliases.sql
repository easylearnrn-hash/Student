-- Check Aleksandr Petrosyan's aliases
SELECT 
  id,
  name,
  group_name,
  aliases,
  typeof(aliases) as alias_type,
  length(aliases::text) as alias_length,
  aliases::text as alias_text
FROM students
WHERE name = 'Aleksandr Petrosyan';
