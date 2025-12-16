-- ========================================================
-- PAYMENT CONSOLIDATION MIGRATION
-- ========================================================
-- Consolidates payment_records, credit_payments, and 
-- manual_payment_moves into a single `payments` table
-- with a `for_class` column for reassignments
-- ========================================================

-- ========================================================
-- STEP 1: Add for_class column to payments table
-- ========================================================

ALTER TABLE payments 
ADD COLUMN IF NOT EXISTS for_class DATE;

COMMENT ON COLUMN payments.for_class IS 
'The class date this payment covers. If NULL, payment applies to the class on/before the payment date (auto-allocation). If set, payment is manually assigned to this specific class.';

-- ========================================================
-- STEP 2: Migrate manual_payment_moves into for_class
-- ========================================================
-- This transfers all payment reassignments into the new column
-- Logic: Find payments made on `from_date` and mark them as covering `to_date`

-- First, let's see what we're working with
SELECT COUNT(*) as total_moves FROM manual_payment_moves;

-- Migrate each move by updating the payment's for_class
-- NOTE: This assumes payments on from_date should cover to_date
DO $$
DECLARE
  move_record RECORD;
  matching_payment RECORD;
BEGIN
  FOR move_record IN 
    SELECT DISTINCT ON (student_id, from_date, to_date, amount) 
      student_id, from_date, to_date, amount, created_at
    FROM manual_payment_moves 
    ORDER BY student_id, from_date, to_date, amount, created_at DESC
  LOOP
    -- Find payment(s) made on from_date for this student
    FOR matching_payment IN
      SELECT id 
      FROM payments 
      WHERE (student_id::TEXT = move_record.student_id::TEXT
             OR linked_student_id::TEXT = move_record.student_id::TEXT)
        AND date = move_record.from_date
        AND amount >= move_record.amount * 0.95  -- Allow 5% variance for rounding
        AND amount <= move_record.amount * 1.05
      LIMIT 1
    LOOP
      -- Update payment to cover the to_date class
      UPDATE payments
      SET for_class = move_record.to_date
      WHERE id = matching_payment.id;
      
      RAISE NOTICE 'Migrated: Student %, Payment on % → covers class %', 
        move_record.student_id, move_record.from_date, move_record.to_date;
    END LOOP;
  END LOOP;
END $$;

-- ========================================================
-- STEP 3: Migrate payment_records into payments
-- ========================================================
-- Merge legacy manual payment records into main payments table
-- Generate UUIDs for id column since it has no default

INSERT INTO payments (
  id,
  student_id,
  amount,
  date,
  email_date,
  payer_name,
  resolved_student_name,
  for_class  -- Manual records apply to exact date
)
SELECT 
  gen_random_uuid() as id,  -- Generate UUID for id column
  pr.student_id::TEXT,  -- Cast to TEXT to match payments.student_id
  pr.amount,
  pr.date,
  (pr.date || 'T12:00:00')::TIMESTAMPTZ,  -- Cast to timestamp with timezone
  s.name as payer_name,
  s.name as resolved_student_name,
  pr.date as for_class  -- Manual payments apply to exact class date
FROM payment_records pr
LEFT JOIN students s ON s.id = pr.student_id
WHERE NOT EXISTS (
  -- Avoid duplicates if payment already exists
  SELECT 1 FROM payments p
  WHERE p.student_id::TEXT = pr.student_id::TEXT
    AND p.date = pr.date
    AND p.amount = pr.amount
)
ON CONFLICT DO NOTHING;

-- ========================================================
-- STEP 4: Migrate credit_payments into payments
-- ========================================================
-- Credit applications become payment records with for_class set
-- Generate UUIDs for id column since it has no default

INSERT INTO payments (
  id,
  student_id,
  amount,
  date,
  email_date,
  payer_name,
  resolved_student_name,
  for_class  -- Credit always applies to exact class
)
SELECT 
  gen_random_uuid() as id,  -- Generate UUID for id column
  cp.student_id::TEXT,  -- Cast to TEXT to match payments.student_id
  cp.amount,
  cp.class_date,
  (cp.class_date || 'T12:00:00')::TIMESTAMPTZ,  -- Cast to timestamp with timezone
  s.name as payer_name,
  s.name as resolved_student_name,
  cp.class_date as for_class
FROM credit_payments cp
LEFT JOIN students s ON s.id = cp.student_id::BIGINT
WHERE NOT EXISTS (
  SELECT 1 FROM payments p
  WHERE p.student_id::TEXT = cp.student_id::TEXT
    AND p.date = cp.class_date
)
ON CONFLICT DO NOTHING;

-- ========================================================
-- STEP 5: Verify migration
-- ========================================================

-- Check payment counts
SELECT 
  'Total payments' as metric,
  COUNT(*) as count 
FROM payments
UNION ALL
SELECT 
  'With for_class assigned',
  COUNT(*) 
FROM payments 
WHERE for_class IS NOT NULL
UNION ALL
SELECT 
  'Auto-allocated (for_class NULL)',
  COUNT(*) 
FROM payments 
WHERE for_class IS NULL;

-- Sample migrated payments
SELECT 
  id,
  student_id,
  date as payment_date,
  for_class as covers_class,
  amount,
  CASE 
    WHEN for_class IS NULL THEN 'Auto'
    WHEN for_class = date THEN 'Exact match'
    ELSE 'Reassigned'
  END as allocation_type
FROM payments
WHERE for_class IS NOT NULL
LIMIT 10;

-- ========================================================
-- STEP 6: Update indexes for performance
-- ========================================================

-- Index for fast class coverage lookups
CREATE INDEX IF NOT EXISTS idx_payments_for_class 
ON payments(for_class) 
WHERE for_class IS NOT NULL;

-- Composite index for student + class date queries
CREATE INDEX IF NOT EXISTS idx_payments_student_for_class 
ON payments(student_id, for_class) 
WHERE for_class IS NOT NULL;

-- Index for date range queries
CREATE INDEX IF NOT EXISTS idx_payments_date_for_class 
ON payments(date, for_class);

-- ========================================================
-- STEP 7: Create helper view for easy querying
-- ========================================================

CREATE OR REPLACE VIEW payment_coverage AS
SELECT 
  p.id,
  p.student_id,
  COALESCE(s.name, p.resolved_student_name, p.payer_name, 'Unmatched Payment') as student_name,
  p.date as payment_date,
  COALESCE(p.for_class, p.date) as class_covered,
  p.amount,
  p.payer_name,
  CASE 
    WHEN p.for_class IS NULL THEN 'auto'
    WHEN p.for_class = p.date THEN 'exact'
    WHEN p.for_class < p.date THEN 'forward'
    WHEN p.for_class > p.date THEN 'backward'
  END as allocation_type
FROM payments p
LEFT JOIN students s ON s.id::TEXT = p.student_id
ORDER BY p.date DESC;

COMMENT ON VIEW payment_coverage IS 
'Shows all payments with their covered class dates. Uses for_class if set, otherwise defaults to payment date (auto-allocation).';

-- ========================================================
-- VERIFICATION QUERIES
-- ========================================================

-- Find reassigned payments
SELECT * FROM payment_coverage 
WHERE allocation_type IN ('forward', 'backward')
LIMIT 20;

-- Check student payment coverage for December 2025
SELECT 
  student_name,
  class_covered,
  SUM(amount) as total_paid,
  COUNT(*) as payment_count,
  string_agg(DISTINCT allocation_type, ', ') as allocation_types
FROM payment_coverage
WHERE class_covered >= '2025-12-01' 
  AND class_covered < '2026-01-01'
GROUP BY student_name, class_covered
ORDER BY student_name, class_covered;

-- ========================================================
-- OPTIONAL: Archive old tables (DO NOT RUN YET)
-- ========================================================
-- Only run these after confirming Calendar.html works perfectly

-- CREATE TABLE payment_records_archive AS SELECT * FROM payment_records;
-- CREATE TABLE credit_payments_archive AS SELECT * FROM credit_payments;
-- CREATE TABLE manual_payment_moves_archive AS SELECT * FROM manual_payment_moves;

-- DROP TABLE payment_records;
-- DROP TABLE credit_payments;
-- DROP TABLE manual_payment_moves;
