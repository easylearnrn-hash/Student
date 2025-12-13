-- Verify all payments for Gayane Zadourian (student ID 24)

SELECT 'Manual Payments (payment_records)' as source, * FROM payment_records WHERE student_id = 24 AND date >= '2025-12-01';

SELECT 'Automated Payments (payments)' as source, * FROM payments WHERE resolved_student_name ILIKE '%Gayane%' OR payer_name ILIKE '%Gayane%';

SELECT 'Credit Payments (credit_payments)' as source, * FROM credit_payments WHERE student_id = 24 AND class_date >= '2025-12-01';
