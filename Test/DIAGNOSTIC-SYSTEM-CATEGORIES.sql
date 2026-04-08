-- ================================================================
-- DIAGNOSTIC 3: All distinct category values in student_notes
-- ================================================================

SELECT
  category,
  COUNT(*) AS note_count
FROM student_notes
WHERE category IS NOT NULL AND category <> ''
  AND (deleted IS NULL OR deleted = FALSE)
GROUP BY category
ORDER BY category;
