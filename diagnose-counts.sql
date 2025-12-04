-- Check actual counts to verify what the admin portal should show

-- 1. How many notes are NOT deleted?
SELECT COUNT(*) as non_deleted_notes 
FROM student_notes 
WHERE deleted = false;

-- 2. How many notes total (including deleted)?
SELECT COUNT(*) as total_notes 
FROM student_notes;

-- 3. How many notes are deleted?
SELECT COUNT(*) as deleted_notes 
FROM student_notes 
WHERE deleted = true;

-- 4. How many PAID payment records?
SELECT COUNT(*) as paid_payment_records 
FROM payment_records 
WHERE status = 'paid';

-- 5. How many total payment records (all statuses)?
SELECT COUNT(*) as total_payment_records,
       COUNT(*) FILTER (WHERE status = 'paid') as paid,
       COUNT(*) FILTER (WHERE status = 'unpaid') as unpaid,
       COUNT(*) FILTER (WHERE status = 'pending') as pending,
       COUNT(*) FILTER (WHERE status = 'cancelled') as cancelled
FROM payment_records;

-- 6. How many Zelle payments?
SELECT COUNT(*) as zelle_payments 
FROM payments;

-- 7. Total payments that SHOULD show in admin (paid records + all Zelle)
SELECT 
  (SELECT COUNT(*) FROM payment_records WHERE status = 'paid') as paid_records,
  (SELECT COUNT(*) FROM payments) as zelle_payments,
  (SELECT COUNT(*) FROM payment_records WHERE status = 'paid') + (SELECT COUNT(*) FROM payments) as total_should_show;
