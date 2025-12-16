-- Check recent for_class updates in payments table
-- This will show if the reassignment worked

-- 1. Show all payments with their for_class dates (most recent first)
SELECT 
  id,
  student_id,
  payer_name,
  amount,
  date as payment_date,
  for_class,
  created_at,
  updated_at,
  -- Show if for_class differs from payment date
  CASE 
    WHEN for_class != date THEN '⚠️ REASSIGNED'
    ELSE '✅ Original'
  END as status
FROM payments
ORDER BY updated_at DESC NULLS LAST
LIMIT 20;

-- 2. Count reassigned vs original payments
SELECT 
  CASE 
    WHEN for_class != date THEN 'Reassigned'
    ELSE 'Original Date'
  END as payment_status,
  COUNT(*) as count
FROM payments
GROUP BY payment_status;

-- 3. Show payments updated in the last 5 minutes (recent reassignments)
SELECT 
  id,
  student_id,
  payer_name,
  amount,
  date as payment_date,
  for_class,
  updated_at,
  CASE 
    WHEN for_class != date THEN '⚠️ REASSIGNED from ' || date || ' to ' || for_class
    ELSE '✅ Original'
  END as change_details
FROM payments
WHERE updated_at > NOW() - INTERVAL '5 minutes'
ORDER BY updated_at DESC;

-- 4. Show any NULL for_class values (should be 0 if trigger works)
SELECT 
  COUNT(*) as null_for_class_count,
  CASE 
    WHEN COUNT(*) = 0 THEN '✅ No NULL values - trigger working!'
    ELSE '❌ Found NULL for_class values'
  END as status
FROM payments
WHERE for_class IS NULL;

-- 5. Check Varduhi's December payments (student_id as TEXT)
SELECT 
  id,
  payer_name,
  amount,
  date as payment_received_date,
  for_class,
  created_at,
  updated_at,
  CASE 
    WHEN for_class = date THEN '✅ Original date'
    ELSE '⚠️ Reassigned from ' || date || ' to ' || for_class
  END as status
FROM payments
WHERE student_id = '42'  -- Cast as text
  AND date >= '2025-12-01'
ORDER BY date DESC;

-- 6. Search for Varduhi's payments by name (in case student_id not set)
SELECT 
  id,
  student_id,
  payer_name,
  resolved_student_name,
  amount,
  date as payment_received_date,
  for_class,
  updated_at,
  CASE 
    WHEN for_class = date THEN '✅ Original date'
    ELSE '⚠️ Reassigned from ' || date || ' to ' || for_class
  END as status
FROM payments
WHERE (
  LOWER(payer_name) LIKE '%varduhi%' 
  OR LOWER(resolved_student_name) LIKE '%varduhi%'
  OR LOWER(payer_name) LIKE '%nersesyan%'
  OR LOWER(resolved_student_name) LIKE '%nersesyan%'
)
  AND date >= '2025-12-01'
ORDER BY date DESC;

-- 7. Show the specific payment ID from the console logs
SELECT 
  id,
  student_id,
  payer_name,
  resolved_student_name,
  amount,
  date as payment_received_date,
  for_class,
  gmail_id,
  updated_at,
  CASE 
    WHEN for_class = date THEN '✅ Original date'
    ELSE '⚠️ Reassigned from ' || date || ' to ' || for_class
  END as status
FROM payments
WHERE id = '19b209757e6cf405';  -- The payment ID from your console logs
