-- ========================================================
-- BACKFILL WRONG FOR_CLASS DATES
-- ========================================================
-- This fixes the 3 payments that have wrong for_class values
-- The trigger is now working correctly for new payments
-- ========================================================

-- Update the 3 payments with wrong for_class values
UPDATE payments
SET for_class = (timezone('America/Los_Angeles', email_date))::date
WHERE id IN (
  '19b35308dd0fac61',  -- Zhaneta: 2025-12-17 → 2025-12-18
  '19b34c1e8567cb63',  -- Husikyan: 2025-12-17 → 2025-12-18
  '19b2a74ac75b1252'   -- Stepan: 2025-12-18 → 2025-12-16
);

-- Verify the fix
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
WHERE id IN (
  '19b35308dd0fac61',
  '19b34c1e8567cb63',
  '19b2a74ac75b1252'
)
ORDER BY email_date DESC;
