-- Quick fix: Manually update Lusine's payment date from Dec 7 to Dec 6
-- This is faster than delete + re-import if you just want to fix this one payment

-- Step 1: View current data
SELECT id, student_name, amount, date, email_date, created_at
FROM payments
WHERE id = '19af58bd35306804';

-- Step 2: Update the date field to Dec 6 (uncomment to execute)
UPDATE payments
SET date = '2025-12-06'
WHERE id = '19af58bd35306804';

-- Step 3: Verify the fix
SELECT id, student_name, amount, date, email_date, created_at
FROM payments
WHERE id = '19af58bd35306804';
-- Expected: date should now be 2025-12-06

-- ⚠️ AFTER RUNNING THIS:
-- 1. Hard refresh Student Portal (Cmd+Shift+R)
-- 2. Payment should now show Dec 6 in payment history
-- 3. Calendar should show payment on Dec 6 (no duplicate)

-- NOTE: This is a quick manual fix. The proper long-term solution is to
-- delete and re-import with the Payment Records UTC fix, which will
-- ensure all future payments are stored with correct dates.
