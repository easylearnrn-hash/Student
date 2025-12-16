-- ============================================================
-- FIX SPECIFIC DUPLICATE: Student 5, Date 2025-11-20
-- ============================================================
-- ERROR: duplicate key value violates unique constraint "unique_student_class_payment"
-- DETAIL: Key (student_id, for_class)=(5, 2025-11-20) already exists.
-- ============================================================

-- STEP 1: Find ALL payments for student 5 on 2025-11-20
SELECT 
  id,
  student_id,
  linked_student_id,
  payer_name,
  resolved_student_name,
  amount,
  for_class,
  date as receipt_date,
  created_at
FROM payments
WHERE (student_id = '5' OR linked_student_id = 5)
  AND for_class = '2025-11-20'
ORDER BY created_at;

-- STEP 2: Identify which payment to KEEP vs DELETE
-- Strategy: Keep the one with student_id populated, delete the one with NULL student_id
WITH duplicate_payments AS (
  SELECT 
    id,
    student_id,
    linked_student_id,
    payer_name,
    amount,
    date as receipt_date,
    created_at,
    CASE 
      WHEN student_id IS NOT NULL THEN 'KEEP (has student_id)'
      WHEN student_id IS NULL AND linked_student_id IS NOT NULL THEN 'DELETE (student_id NULL)'
      ELSE 'UNKNOWN'
    END as action
  FROM payments
  WHERE (student_id = '5' OR linked_student_id = 5)
    AND for_class = '2025-11-20'
)
SELECT 
  action,
  id,
  student_id,
  linked_student_id,
  payer_name,
  amount,
  receipt_date
FROM duplicate_payments
ORDER BY action DESC;

-- STEP 3: Delete the duplicate with NULL student_id
-- (Adjust WHERE clause if needed based on Step 2 results)
DELETE FROM payments
WHERE for_class = '2025-11-20'
  AND linked_student_id = 5
  AND student_id IS NULL;

-- STEP 4: Verify deletion
SELECT 
  COUNT(*) as remaining_payments,
  array_agg(id) as payment_ids
FROM payments
WHERE (student_id = '5' OR linked_student_id = 5)
  AND for_class = '2025-11-20';

-- STEP 5: Now you can safely run the main update
-- This updates the remaining payment to have student_id = '5'
UPDATE payments
SET student_id = '5'
WHERE linked_student_id = 5
  AND for_class = '2025-11-20'
  AND student_id IS NULL;

-- ============================================================
-- GENERAL DUPLICATE CLEANUP (for all students)
-- ============================================================

-- Find ALL duplicates in the system
WITH duplicates AS (
  SELECT 
    COALESCE(student_id, linked_student_id::text) as effective_student_id,
    for_class,
    COUNT(*) as duplicate_count,
    array_agg(id ORDER BY created_at) as payment_ids,
    array_agg(payer_name ORDER BY created_at) as payer_names
  FROM payments
  WHERE for_class IS NOT NULL
  GROUP BY COALESCE(student_id, linked_student_id::text), for_class
  HAVING COUNT(*) > 1
)
SELECT 
  '🔴 DUPLICATE' as alert,
  effective_student_id as student_id,
  for_class,
  duplicate_count,
  payment_ids,
  payer_names
FROM duplicates
ORDER BY for_class DESC;

-- Delete duplicates (keeps oldest, deletes newer ones)
-- WARNING: This deletes payments where student_id IS NULL and linked_student_id matches existing payment
DELETE FROM payments p1
WHERE student_id IS NULL
  AND linked_student_id IS NOT NULL
  AND EXISTS (
    SELECT 1 FROM payments p2
    WHERE p2.student_id = p1.linked_student_id::text
      AND p2.for_class = p1.for_class
      AND p2.created_at < p1.created_at  -- Keep older payment
  );

-- Verify all duplicates are gone
SELECT 
  'After Cleanup' as status,
  COALESCE(student_id, linked_student_id::text) as effective_student_id,
  for_class,
  COUNT(*) as payment_count
FROM payments
WHERE for_class IS NOT NULL
GROUP BY COALESCE(student_id, linked_student_id::text), for_class
HAVING COUNT(*) > 1;
