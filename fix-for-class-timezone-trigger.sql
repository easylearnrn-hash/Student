-- ================================================================
-- FIX: Timezone-safe for_class default trigger
-- PROBLEM: Old trigger used date::date which can shift by 1 day
-- SOLUTION: Convert to LA timezone before extracting date
-- ================================================================

-- Drop old trigger FIRST, then function (CASCADE not needed)
DROP TRIGGER IF EXISTS trigger_set_for_class_default ON payments;
DROP FUNCTION IF EXISTS set_for_class_default() CASCADE;

-- Create timezone-safe function
CREATE OR REPLACE FUNCTION set_for_class_default()
RETURNS TRIGGER AS $$
BEGIN
  -- Only set for_class if it's NULL
  IF NEW.for_class IS NULL THEN
    -- Convert receipt timestamp to LA timezone, then extract date
    NEW.for_class = (NEW.date AT TIME ZONE 'America/Los_Angeles')::date;
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger
CREATE TRIGGER trigger_set_for_class_default
  BEFORE INSERT OR UPDATE ON payments
  FOR EACH ROW
  EXECUTE FUNCTION set_for_class_default();

-- Verify
SELECT 
  'Trigger created successfully' as status,
  tgname as trigger_name,
  tgrelid::regclass as table_name
FROM pg_trigger 
WHERE tgname = 'trigger_set_for_class_default';
