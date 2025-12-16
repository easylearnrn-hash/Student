-- =====================================================
-- ENSURE for_class COLUMN HAS PROPER DEFAULTS
-- =====================================================

-- 1. Backfill any NULL for_class values to match payment date
UPDATE payments 
SET for_class = date::date
WHERE for_class IS NULL 
  AND date IS NOT NULL;

-- 2. Create trigger to auto-set for_class on new payments
CREATE OR REPLACE FUNCTION set_for_class_default()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.for_class IS NULL AND NEW.date IS NOT NULL THEN
    NEW.for_class := NEW.date::date;
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Drop trigger if exists, then create
DROP TRIGGER IF EXISTS trigger_set_for_class_default ON payments;
CREATE TRIGGER trigger_set_for_class_default
  BEFORE INSERT ON payments
  FOR EACH ROW
  EXECUTE FUNCTION set_for_class_default();

-- Verify backfill
SELECT 
  COUNT(*) as total_payments,
  COUNT(for_class) as has_for_class,
  COUNT(*) - COUNT(for_class) as missing_for_class
FROM payments;
