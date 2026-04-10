-- ============================================================
-- DELETE WRONGLY-INSERTED EXCUSED RECORDS
-- These were created by the "Bulk Excuse" button in Calendar-NEW.html
-- and should NOT exist for March 30, 31, April 1, April 2, 2026.
-- Run this in the Supabase SQL Editor.
-- ============================================================

-- ============================================================
-- DIAGNOSE: What payments exist around April 2, 2026?
-- ============================================================

-- All payment_records for Mariam (student_id = 9)
SELECT id, student_id, date, status, amount, payment_method, notes
FROM payment_records
WHERE student_id = '9'
ORDER BY date DESC;

-- All Zelle payments for Mariam (student_id = 9)
SELECT id, student_id, linked_student_id, payer_name, resolved_student_name,
       for_class, for_class_dates, email_date, amount, status
FROM payments
WHERE student_id::text = '9' OR linked_student_id::text = '9'
ORDER BY email_date DESC
LIMIT 20;
