-- ================================================================
-- FIX: Enforce unique (student_id, for_class) constraint
-- PROBLEM: Multiple payments for same student + date = random winner
-- SOLUTION: Add unique index
-- ================================================================

-- Check for existing duplicates BEFORE creating constraint
SELECT 
  student_id,
  for_class,
  COUNT(*) as duplicate_count,
  array_agg(id) as payment_ids,
  array_agg(amount) as amounts
FROM payments
WHERE student_id IS NOT NULL 
  AND for_class IS NOT NULL
GROUP BY student_id, for_class
HAVING COUNT(*) > 1
ORDER BY duplicate_count DESC;

-- If duplicates exist, you must resolve them first:
-- Option 1: Merge amounts into one payment
-- Option 2: Reassign one payment to different date
-- Option 3: Mark one as ignored/cancelled

-- Create unique index (prevents future duplicates)
CREATE UNIQUE INDEX IF NOT EXISTS unique_student_class_payment 
ON payments(student_id, for_class) 
WHERE student_id IS NOT NULL AND for_class IS NOT NULL;

-- Verify
SELECT 
  indexname,
  indexdef
FROM pg_indexes
WHERE indexname = 'unique_student_class_payment';
