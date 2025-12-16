-- ========================================================
-- FIX FOR_CLASS COLUMN TO AUTO-DEFAULT TO PAYMENT DATE
-- ========================================================
-- Problem: for_class column is NULL for all payments
-- Solution: Set DEFAULT to payment date & backfill existing NULLs
-- ========================================================

-- STEP 1: Backfill existing NULL for_class values with payment date
UPDATE payments
SET for_class = date
WHERE for_class IS NULL;

-- STEP 2: Set DEFAULT for future inserts
-- Note: PostgreSQL doesn't support DEFAULT with another column directly
-- So we'll use a trigger instead

-- Drop trigger if exists
DROP TRIGGER IF EXISTS set_for_class_default ON payments;
DROP FUNCTION IF EXISTS set_for_class_default();

-- Create trigger function
CREATE OR REPLACE FUNCTION set_for_class_default()
RETURNS TRIGGER AS $$
BEGIN
  -- If for_class is NULL on INSERT, set it to the payment date
  IF NEW.for_class IS NULL THEN
    NEW.for_class := NEW.date;
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger that fires BEFORE INSERT
CREATE TRIGGER set_for_class_default
  BEFORE INSERT ON payments
  FOR EACH ROW
  EXECUTE FUNCTION set_for_class_default();

-- ========================================================
-- VERIFICATION
-- ========================================================

-- Check that all payments now have for_class set
SELECT 
  COUNT(*) as total_payments,
  COUNT(for_class) as with_for_class,
  COUNT(*) - COUNT(for_class) as missing_for_class
FROM payments;

-- Show sample of recent payments
SELECT 
  id, 
  student_id, 
  date as payment_date, 
  for_class, 
  amount,
  resolved_student_name,
  CASE 
    WHEN for_class = date THEN '✅ Same day'
    WHEN for_class IS NULL THEN '❌ NULL'
    ELSE '🔄 Reassigned to ' || for_class::TEXT
  END as status
FROM payments
WHERE date >= '2025-12-01'
ORDER BY date DESC
LIMIT 20;
