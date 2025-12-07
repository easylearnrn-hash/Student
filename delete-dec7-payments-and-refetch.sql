-- Delete Lusine's Dec 7 payment (id: 19af58bd35306804) to allow re-import with correct timezone
-- The payment was made Dec 6 LA time but stored as Dec 7 due to timezone bug
-- After deletion, re-fetch from Gmail with the UTC date extraction fix

-- Step 1: View the payment to be deleted (verify first)
SELECT id, student_name, payer_name, amount, date, email_date, created_at
FROM payments
WHERE id = '19af58bd35306804';

-- Analysis of this payment:
-- email_date: 2025-12-07 01:22:52+00 (Dec 7, 1:22 AM UTC = Dec 6, 5:22 PM LA time)
-- created_at: 2025-12-06 21:32:05+00 (Dec 6, 9:32 PM UTC = Dec 6, 1:32 PM LA time)
-- date: 2025-12-07 (WRONG - should be 2025-12-06)

-- Step 2: Delete this payment (uncomment to execute)
DELETE FROM payments
WHERE id = '19af58bd35306804';

-- Step 3: Verify deletion
SELECT COUNT(*) as payment_exists
FROM payments
WHERE id = '19af58bd35306804';
-- Expected result: 0 rows

-- Step 4: Delete ALL Dec 7 payments if needed (optional - only if multiple are wrong)
-- SELECT id, student_name, payer_name, amount, date, email_date, created_at
-- FROM payments
-- WHERE date = '2025-12-07';

-- DELETE FROM payments
-- WHERE date = '2025-12-07';

-- ⚠️ AFTER RUNNING THIS:
-- 1. Hard refresh Payment Records page (Cmd+Shift+R)
-- 2. Click "Gmail" button to re-fetch Lusine's payment
-- 3. Payment should now appear with correct Dec 6 date
-- 4. Calendar should show payment on Dec 6 (blue dot), not Dec 7
