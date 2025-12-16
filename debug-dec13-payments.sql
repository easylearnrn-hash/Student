-- Debug: Why isn't Varduhi's Dec 13 payment showing as unmatched?

-- 1. Show Varduhi's Dec 13 payment details
SELECT 
  id,
  student_id,
  payer_name,
  amount,
  date as payment_received_date,
  for_class,
  'This should show fuchsia if student has NO class on for_class date' as note
FROM payments
WHERE id = '19b1bc78d80e9539';

-- 2. Check: Does Varduhi have a class on Dec 13?
-- (Look in Calendar UI - if she has a dot on Dec 13, then she HAS a class)
-- Based on screenshot: YES - Groups C and E both have dots on Dec 13

-- 3. The Logic Problem:
-- Payment: for_class = 2025-12-13
-- Student: HAS class on 2025-12-13
-- Result: NOT unmatched (green dot should show, not fuchsia)

-- 4. But you said she made a payment on Dec 13 when she had NO class
-- This means the PAYMENT was received on Dec 13, but she didn't have class that day
-- So we need to check: payment.date (receipt date) vs class schedule

-- Let me check the actual receipt date:
SELECT 
  id,
  payer_name,
  date as receipt_date,
  for_class as assigned_to_class,
  CASE 
    WHEN date = for_class THEN '✅ Receipt date matches class date'
    ELSE '⚠️ Receipt date (' || date || ') differs from class date (' || for_class || ')'
  END as analysis
FROM payments
WHERE id = '19b1bc78d80e9539';
