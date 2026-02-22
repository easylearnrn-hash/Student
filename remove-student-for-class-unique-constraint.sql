-- Remove unique constraint on (student_id, for_class) from payments table
-- 
-- REASON: Students can legitimately make multiple payments on the same class date
-- Example: Gohar Hovhannisyan paid $100 twice on 2026-02-08 (at 5:33 PM and 11:23 PM)
-- These are separate transactions with different gmail_ids and confirmation codes
--
-- The gmail_id unique constraint is sufficient to prevent actual duplicates
-- (i.e., the same Gmail message being imported multiple times)

-- Drop BOTH possible constraint names (the actual name is unique_student_class_payment)
ALTER TABLE payments 
DROP CONSTRAINT IF EXISTS payments_student_id_for_class_key;

ALTER TABLE payments 
DROP CONSTRAINT IF EXISTS unique_student_class_payment;

-- Some environments created a UNIQUE INDEX (not a constraint) with the same name.
-- Postgres reports that index name in the 23505 error. Drop it if present.
DROP INDEX IF EXISTS unique_student_class_payment;

-- Verify the constraint was removed
SELECT 
    conname AS constraint_name,
    contype AS constraint_type
FROM pg_constraint
WHERE conrelid = 'payments'::regclass
  AND conname LIKE '%student%';

-- Verify no unique index remains
SELECT indexname
FROM pg_indexes
WHERE tablename = 'payments'
  AND indexname LIKE '%student%';

-- Expected result: Only gmail_id unique constraint should remain
