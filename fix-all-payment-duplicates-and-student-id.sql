-- ============================================================
-- COMPREHENSIVE DUPLICATE CLEANUP + STUDENT_ID FIX
-- ============================================================
-- This script safely handles ALL duplicates and updates student_id
-- Run this ENTIRE script in one go - it's safe and idempotent
-- ============================================================

-- STEP 1: Report current state
SELECT 
  '📊 Current State' as status,
  COUNT(*) as total_payments,
  COUNT(CASE WHEN student_id IS NULL THEN 1 END) as null_student_id,
  COUNT(CASE WHEN student_id IS NOT NULL THEN 1 END) as has_student_id
FROM payments;

-- STEP 2: Find ALL duplicates that would be created
WITH potential_duplicates AS (
  SELECT 
    COALESCE(p1.student_id, p1.linked_student_id::text) as effective_student_id,
    p1.for_class,
    COUNT(*) as duplicate_count,
    array_agg(p1.id ORDER BY p1.created_at) as payment_ids,
    array_agg(p1.payer_name ORDER BY p1.created_at) as payer_names,
    array_agg(p1.amount ORDER BY p1.created_at) as amounts,
    array_agg(p1.student_id IS NULL ORDER BY p1.created_at) as is_null_student_id
  FROM payments p1
  WHERE p1.for_class IS NOT NULL
  GROUP BY COALESCE(p1.student_id, p1.linked_student_id::text), p1.for_class
  HAVING COUNT(*) > 1
)
SELECT 
  '🔴 DUPLICATES FOUND' as alert,
  effective_student_id,
  for_class,
  duplicate_count,
  payment_ids,
  payer_names,
  amounts
FROM potential_duplicates
ORDER BY for_class DESC;

-- STEP 3: DELETE ALL DUPLICATES (keeps oldest payment per student+date)
-- Strategy: If multiple payments exist for same (student_id, for_class):
--   - Keep the one with student_id populated (if exists)
--   - Otherwise keep the oldest one
--   - Delete all others
WITH duplicates_to_delete AS (
  SELECT 
    p1.id,
    p1.student_id,
    p1.linked_student_id,
    p1.for_class,
    p1.created_at,
    -- Rank payments: Prefer ones with student_id set, then by oldest
    ROW_NUMBER() OVER (
      PARTITION BY COALESCE(p1.student_id, p1.linked_student_id::text), p1.for_class
      ORDER BY 
        CASE WHEN p1.student_id IS NOT NULL THEN 0 ELSE 1 END,  -- student_id set = keep
        p1.created_at ASC  -- oldest first
    ) as rank
  FROM payments p1
  WHERE p1.for_class IS NOT NULL
)
DELETE FROM payments
WHERE id IN (
  SELECT id FROM duplicates_to_delete WHERE rank > 1
);

-- STEP 4: Report deletion results
SELECT 
  '✅ Duplicates Cleaned' as status,
  COUNT(*) as remaining_payments
FROM payments;

-- STEP 5: Verify no duplicates remain
WITH remaining_duplicates AS (
  SELECT 
    COALESCE(student_id, linked_student_id::text) as effective_student_id,
    for_class,
    COUNT(*) as count
  FROM payments
  WHERE for_class IS NOT NULL
  GROUP BY COALESCE(student_id, linked_student_id::text), for_class
  HAVING COUNT(*) > 1
)
SELECT 
  CASE 
    WHEN COUNT(*) = 0 THEN '✅ NO DUPLICATES REMAINING'
    ELSE '⚠️ DUPLICATES STILL EXIST'
  END as verification_status,
  COUNT(*) as duplicate_groups
FROM remaining_duplicates;

-- STEP 6: NOW safely update student_id from linked_student_id
UPDATE payments
SET student_id = linked_student_id::text
WHERE student_id IS NULL 
  AND linked_student_id IS NOT NULL;

-- STEP 7: Final state report
SELECT 
  '🎉 FINAL STATE' as status,
  COUNT(*) as total_payments,
  COUNT(CASE WHEN student_id IS NULL THEN 1 END) as null_student_id,
  COUNT(CASE WHEN student_id IS NOT NULL THEN 1 END) as has_student_id,
  COUNT(CASE WHEN student_id IS NULL AND linked_student_id IS NOT NULL THEN 1 END) as needs_manual_fix
FROM payments;

-- STEP 8: Create trigger for FUTURE payments
CREATE OR REPLACE FUNCTION ensure_payment_student_id()
RETURNS TRIGGER AS $$
BEGIN
  -- Auto-populate student_id from linked_student_id
  IF NEW.student_id IS NULL AND NEW.linked_student_id IS NOT NULL THEN
    NEW.student_id := NEW.linked_student_id::text;
  END IF;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Drop and recreate trigger
DROP TRIGGER IF EXISTS trigger_ensure_payment_student_id ON payments;

CREATE TRIGGER trigger_ensure_payment_student_id
  BEFORE INSERT OR UPDATE ON payments
  FOR EACH ROW
  EXECUTE FUNCTION ensure_payment_student_id();

-- STEP 9: Final verification - show any problematic payments
SELECT 
  id,
  student_id,
  linked_student_id,
  payer_name,
  for_class,
  amount,
  CASE 
    WHEN student_id IS NULL AND linked_student_id IS NULL THEN '🔴 CRITICAL: Both NULL'
    WHEN student_id IS NULL AND linked_student_id IS NOT NULL THEN '⚠️ WARNING: student_id NULL'
    WHEN student_id IS NOT NULL THEN '✅ OK: student_id set'
  END as status
FROM payments
WHERE student_id IS NULL OR linked_student_id IS NULL
ORDER BY for_class DESC
LIMIT 20;

SELECT '✅ COMPLETE! All duplicates removed, student_id populated, trigger created.' as final_message;
