-- ========================================================
-- FIX FOR_CLASS TIMEZONE BUG
-- ========================================================
-- Problem: for_class is being set to UTC date instead of LA timezone date
-- Solution: Convert email_date to LA timezone before setting for_class
-- ========================================================

-- Drop existing trigger and function (CASCADE removes dependent trigger automatically)
DROP TRIGGER IF EXISTS set_for_class_default ON payments CASCADE;
DROP TRIGGER IF EXISTS trigger_set_for_class_default ON payments CASCADE;
DROP FUNCTION IF EXISTS set_for_class_default() CASCADE;

-- Create NEW trigger function that converts email_date to LA timezone
CREATE OR REPLACE FUNCTION set_for_class_default()
RETURNS TRIGGER AS $$
BEGIN
  -- If for_class is NULL on INSERT, set it to LA timezone date from email_date
  IF NEW.for_class IS NULL THEN
    -- Convert email_date (which is stored as UTC timestamptz) to LA timezone date
    -- Use timezone() function for proper conversion
    NEW.for_class := (timezone('America/Los_Angeles', NEW.email_date))::date;
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger that fires BEFORE INSERT (naming it to match the old one)
CREATE TRIGGER trigger_set_for_class_default
  BEFORE INSERT ON payments
  FOR EACH ROW
  EXECUTE FUNCTION set_for_class_default();

-- ========================================================
-- VERIFICATION TEST
-- ========================================================

-- Test with a sample timestamp (Dec 19 at 5:58 AM UTC = Dec 18 at 9:58 PM PST)
SELECT 
  '2025-12-19T05:58:51+00:00'::timestamptz as utc_timestamp,
  (timezone('America/Los_Angeles', '2025-12-19T05:58:51+00:00'::timestamptz))::date as la_date,
  'Expected: 2025-12-18' as note;

-- Verify all recent payments have correct for_class
SELECT 
  id,
  payer_name,
  email_date,
  (timezone('America/Los_Angeles', email_date))::date as expected_for_class,
  for_class as actual_for_class,
  CASE 
    WHEN (timezone('America/Los_Angeles', email_date))::date = for_class 
    THEN '✅ CORRECT'
    ELSE '❌ WRONG'
  END as status
FROM payments
WHERE email_date >= '2025-12-17'
ORDER BY email_date DESC
LIMIT 20;
