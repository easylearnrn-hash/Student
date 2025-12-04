-- Delete all credit payment records that are causing "Paid from credit" to show
-- This will remove the duplicate payment indicators for Anahit and Milena

-- Option 1: Delete ALL credit payments (use this if you want a clean slate)
DELETE FROM credit_payments;

-- Option 2: Delete only for specific students (Anahit & Milena)
-- Uncomment the lines below if you only want to delete theirs:
/*
DELETE FROM credit_payments 
WHERE student_id IN (
  SELECT id FROM students WHERE name IN ('Anahit Aslanyan', 'Milena Bagramyan')
);
*/

-- Option 3: Delete only for December 2024 (if you want to keep other months)
-- Uncomment the lines below:
/*
DELETE FROM credit_payments 
WHERE created_at >= '2024-12-01' AND created_at < '2025-01-01';
*/

-- After running this, refresh the Calendar and the "Paid from credit" messages will be gone
