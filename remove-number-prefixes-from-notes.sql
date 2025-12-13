-- Remove number prefixes (1., 2., 3., etc.) from student note titles
-- This cleans up note names like "1. 🚨 Abuse & Violence" to "🚨 Abuse & Violence"

-- Update all notes that start with a number followed by a period and space
UPDATE student_notes
SET title = REGEXP_REPLACE(title, '^\d+\.\s+', '', 'g')
WHERE title ~ '^\d+\.\s+';

-- Verify the changes
SELECT 
  id, 
  title,
  system_category,
  created_at
FROM student_notes
WHERE system_category IN (
  'Psycho-Social Aspects',
  'Musculoskeletal Disorders',
  'Nursing Skills and Fundamentals'
)
ORDER BY system_category, title;

-- Show count of updated notes
SELECT COUNT(*) as updated_count
FROM student_notes
WHERE title !~ '^\d+\.\s+';
