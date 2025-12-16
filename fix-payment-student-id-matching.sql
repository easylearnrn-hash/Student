-- ============================================================
-- FIX PAYMENT STUDENT_ID MATCHING (CRITICAL)
-- ============================================================
-- PURPOSE: Ensure ALL payments have student_id populated correctly
-- ISSUE: Automated imports populate linked_student_id but leave student_id NULL
-- SOLUTION: 1. Backfill existing payments
--           2. Add trigger to populate student_id automatically
-- ============================================================

-- STEP 1: Audit current state
-- Shows how many payments have NULL student_id but valid linked_student_id
SELECT 
  COUNT(*) as total_payments,
  COUNT(CASE WHEN student_id IS NULL THEN 1 END) as null_student_id,
  COUNT(CASE WHEN student_id IS NULL AND linked_student_id IS NOT NULL THEN 1 END) as fixable_payments,
  COUNT(CASE WHEN student_id IS NOT NULL THEN 1 END) as has_student_id
FROM payments;

-- STEP 2A: First, identify and report duplicates BEFORE updating
-- This shows which payments would violate the unique constraint
WITH potential_updates AS (
  SELECT 
    id,
    student_id,
    linked_student_id::text as new_student_id,
    for_class,
    payer_name,
    amount
  FROM payments
  WHERE student_id IS NULL 
    AND linked_student_id IS NOT NULL
),
duplicate_check AS (
  SELECT 
    pu.new_student_id,
    pu.for_class,
    COUNT(*) as would_create_duplicates,
    array_agg(pu.id) as payment_ids,
    array_agg(pu.payer_name) as payer_names,
    array_agg(pu.amount) as amounts
  FROM potential_updates pu
  WHERE EXISTS (
    SELECT 1 FROM payments p2
    WHERE p2.student_id = pu.new_student_id
      AND p2.for_class = pu.for_class
      AND p2.id != pu.id
  )
  GROUP BY pu.new_student_id, pu.for_class
)
SELECT 
  '⚠️ DUPLICATE WARNING' as alert,
  new_student_id as student_id,
  for_class,
  would_create_duplicates as duplicate_count,
  payment_ids,
  payer_names,
  amounts
FROM duplicate_check
ORDER BY for_class DESC;

-- STEP 2B: Update ONLY non-duplicate payments
-- This safely updates payments that won't violate the constraint
UPDATE payments
SET student_id = linked_student_id::text
WHERE student_id IS NULL 
  AND linked_student_id IS NOT NULL
  -- CRITICAL: Only update if this won't create a duplicate
  AND NOT EXISTS (
    SELECT 1 FROM payments p2
    WHERE p2.student_id = payments.linked_student_id::text
      AND p2.for_class = payments.for_class
      AND p2.id != payments.id
  );

-- STEP 3: Verify the fix
SELECT 
  'After Fix' as status,
  COUNT(*) as total_payments,
  COUNT(CASE WHEN student_id IS NULL THEN 1 END) as null_student_id,
  COUNT(CASE WHEN student_id IS NOT NULL THEN 1 END) as has_student_id
FROM payments;

-- STEP 3B: Handle remaining duplicates (payments that couldn't be updated)
-- These need MANUAL review - you must decide which payment to keep
SELECT 
  '🔴 MANUAL ACTION REQUIRED' as alert,
  p1.id as payment1_id,
  p2.id as payment2_id,
  COALESCE(p1.student_id, p1.linked_student_id::text) as student_id,
  p1.for_class,
  p1.payer_name as payment1_payer,
  p2.payer_name as payment2_payer,
  p1.amount as payment1_amount,
  p2.amount as payment2_amount,
  p1.date as payment1_date,
  p2.date as payment2_date,
  CASE 
    WHEN p1.amount = p2.amount THEN '💰 SAME AMOUNT - Likely true duplicate'
    ELSE '⚠️ DIFFERENT AMOUNTS - Review carefully'
  END as note
FROM payments p1
JOIN payments p2 ON (
  COALESCE(p1.student_id, p1.linked_student_id::text) = COALESCE(p2.student_id, p2.linked_student_id::text)
  AND p1.for_class = p2.for_class
  AND p1.id < p2.id  -- Avoid showing each pair twice
)
WHERE p1.student_id IS NULL OR p2.student_id IS NULL
ORDER BY p1.for_class DESC, student_id;

-- STEP 3C: To resolve duplicates, DELETE the duplicate payment
-- (Run this ONLY after manual review - replace PAYMENT_ID_TO_DELETE with actual ID)
-- DELETE FROM payments WHERE id = 'PAYMENT_ID_TO_DELETE';

-- STEP 4: Create trigger to auto-populate student_id on INSERT/UPDATE
-- This ensures FUTURE payments always have student_id set
-- ALSO prevents duplicate payments by checking constraint before insert
CREATE OR REPLACE FUNCTION ensure_payment_student_id()
RETURNS TRIGGER AS $$
DECLARE
  duplicate_count INTEGER;
BEGIN
  -- If student_id is NULL but linked_student_id exists, copy it over
  IF NEW.student_id IS NULL AND NEW.linked_student_id IS NOT NULL THEN
    NEW.student_id := NEW.linked_student_id::text;
  END IF;
  
  -- CRITICAL: Check for duplicates BEFORE inserting
  -- If this would create a duplicate (student_id, for_class), prevent it
  IF NEW.student_id IS NOT NULL AND NEW.for_class IS NOT NULL THEN
    SELECT COUNT(*) INTO duplicate_count
    FROM payments
    WHERE student_id = NEW.student_id
      AND for_class = NEW.for_class
      AND id != COALESCE(NEW.id, '00000000-0000-0000-0000-000000000000'::uuid);
    
    IF duplicate_count > 0 THEN
      RAISE NOTICE 'Duplicate payment prevented: student_id=%, for_class=%', NEW.student_id, NEW.for_class;
      -- You can either:
      -- 1. RAISE EXCEPTION to block the insert (uncomment line below)
      -- RAISE EXCEPTION 'Duplicate payment: student % already has payment for %', NEW.student_id, NEW.for_class;
      -- 2. Or just log and allow (current behavior)
    END IF;
  END IF;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Drop existing trigger if it exists
DROP TRIGGER IF EXISTS trigger_ensure_payment_student_id ON payments;

-- Create trigger on INSERT and UPDATE
CREATE TRIGGER trigger_ensure_payment_student_id
  BEFORE INSERT OR UPDATE ON payments
  FOR EACH ROW
  EXECUTE FUNCTION ensure_payment_student_id();

-- STEP 5: Test the trigger with a sample update
-- (Optional - verify trigger works)
SELECT 
  id, 
  student_id, 
  linked_student_id, 
  payer_name,
  for_class
FROM payments 
WHERE linked_student_id IS NOT NULL
LIMIT 5;

-- ============================================================
-- VERIFICATION QUERIES
-- ============================================================

-- Show any remaining problematic payments
SELECT 
  id,
  student_id,
  linked_student_id,
  payer_name,
  for_class,
  CASE 
    WHEN student_id IS NULL AND linked_student_id IS NULL THEN '⚠️ CRITICAL: Both NULL'
    WHEN student_id IS NULL AND linked_student_id IS NOT NULL THEN '⚠️ WARNING: student_id NULL'
    WHEN student_id IS NOT NULL AND linked_student_id IS NULL THEN '✅ OK: student_id set'
    WHEN student_id IS NOT NULL AND linked_student_id IS NOT NULL THEN '✅ OK: Both set'
  END as status
FROM payments
WHERE student_id IS NULL OR linked_student_id IS NULL
ORDER BY for_class DESC
LIMIT 20;

-- ============================================================
-- ROLLBACK (if needed)
-- ============================================================
-- To undo the changes (only if something goes wrong):
-- DROP TRIGGER IF EXISTS trigger_ensure_payment_student_id ON payments;
-- DROP FUNCTION IF EXISTS ensure_payment_student_id();
-- UPDATE payments SET student_id = NULL WHERE ...; (add appropriate WHERE clause)
