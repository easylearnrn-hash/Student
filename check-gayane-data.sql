-- Find Gayane's student record and all her payments
SELECT 'STUDENT RECORD' as source, id, name, group_letter FROM students WHERE name ILIKE '%Gayane%';

SELECT 'MANUAL PAYMENTS' as source, student_id, date, status, amount FROM payment_records WHERE student_id IN (SELECT id FROM students WHERE name ILIKE '%Gayane%');

SELECT 'AUTOMATED PAYMENTS' as source, student_id, linked_student_id, resolved_student_name, payer_name, date, amount FROM payments WHERE resolved_student_name ILIKE '%Gayane%' OR payer_name ILIKE '%Gayane%';

SELECT 'CREDIT PAYMENTS' as source, student_id, class_date, amount FROM credit_payments WHERE student_id IN (SELECT id FROM students WHERE name ILIKE '%Gayane%');
