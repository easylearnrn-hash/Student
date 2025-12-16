-- =====================================================
-- DELETE class_payments TABLE
-- Single Source of Truth: payments.for_class column
-- =====================================================

-- Drop the table completely
DROP TABLE IF EXISTS class_payments CASCADE;

-- Verify deletion
SELECT EXISTS (
  SELECT FROM information_schema.tables 
  WHERE table_schema = 'public' 
  AND table_name = 'class_payments'
) as table_still_exists;

-- Expected result: table_still_exists = false
