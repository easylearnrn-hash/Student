-- ========================================================
-- RESET for_class TO MATCH date FOR DEC 1-15
-- ========================================================
-- This resets all December 1-15 payments to have for_class = date
-- (unless you want to preserve manual reassignments, see option 2)
-- ========================================================

-- OPTION 1: Reset ALL payments Dec 1-15 (overwrite any manual reassignments)
UPDATE payments
SET for_class = date
WHERE date >= '2025-12-01' 
  AND date <= '2025-12-15';

-- Verify results
SELECT 
  date as payment_date,
  for_class,
  COUNT(*) as count,
  SUM(amount) as total_amount,
  CASE 
    WHEN for_class = date THEN '✅ Matches'
    ELSE '❌ Different: ' || for_class::TEXT
  END as status
FROM payments
WHERE date >= '2025-12-01' 
  AND date <= '2025-12-15'
GROUP BY date, for_class
ORDER BY date DESC, for_class DESC;

-- Show affected payments
SELECT 
  id,
  student_id,
  date as payment_date,
  for_class,
  amount,
  resolved_student_name,
  CASE 
    WHEN for_class = date THEN '✅ Same day'
    ELSE '🔄 Reassigned to ' || for_class::TEXT
  END as status
FROM payments
WHERE date >= '2025-12-01' 
  AND date <= '2025-12-15'
ORDER BY date DESC, for_class DESC;
