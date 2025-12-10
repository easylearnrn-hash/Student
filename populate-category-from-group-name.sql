-- ========================================
-- Populate category column from group_name
-- ========================================
-- This migration copies existing group_name values into the category column
-- so that all 10 existing notes can be properly linked to their systems.

-- Step 1: Copy group_name to category for all existing notes
UPDATE student_notes
SET category = group_name
WHERE category IS NULL AND group_name IS NOT NULL;

-- Step 2: Verify the update
SELECT 
  id,
  title,
  group_name,
  category,
  class_date,
  requires_payment
FROM student_notes
WHERE deleted = false
ORDER BY class_date DESC
LIMIT 20;

-- Expected result: category column should now match group_name
-- Example:
-- | id  | title                    | group_name    | category      | class_date | requires_payment |
-- | 622 | Medication Calculation   | Pharmacology  | Pharmacology  | 2025-12-09 | true             |
-- | 621 | General Pharmacology     | Pharmacology  | Pharmacology  | 2025-12-09 | true             |

-- Step 3: Count notes per category (should match folder expectations)
SELECT 
  category,
  COUNT(*) as note_count,
  COUNT(CASE WHEN requires_payment THEN 1 END) as paid_notes,
  COUNT(CASE WHEN NOT requires_payment THEN 1 END) as free_notes
FROM student_notes
WHERE deleted = false
GROUP BY category
ORDER BY note_count DESC;

-- Expected result: All 10 notes should be grouped by their category
-- Example output:
-- | category              | note_count | paid_notes | free_notes |
-- | Pharmacology          | 10         | 10         | 0          |

-- Step 4: Find any notes still missing category (edge cases)
SELECT 
  id,
  title,
  group_name,
  category,
  class_date
FROM student_notes
WHERE deleted = false 
  AND category IS NULL
ORDER BY created_at DESC;

-- Expected result: Should return 0 rows (all notes should have category now)
