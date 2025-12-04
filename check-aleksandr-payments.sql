-- Check Aleksandr Petrosyan's student record and payments
SELECT 
  id,
  name,
  email,
  group_name,
  balance
FROM students
WHERE name ILIKE '%Aleksandr%' OR name ILIKE '%Petrosyan%';

-- Check payment_records for Aleksandr
SELECT 
  pr.id,
  pr.student_id,
  pr.date,
  pr.status,
  pr.amount,
  pr.payment_method,
  s.name as student_name,
  s.id as actual_student_id
FROM payment_records pr
LEFT JOIN students s ON pr.student_id::text = s.id::text
WHERE s.name ILIKE '%Aleksandr%' OR s.name ILIKE '%Petrosyan%'
ORDER BY pr.date DESC;

-- Check payments table (Zelle) for Aleksandr
SELECT 
  p.id,
  p.student_id,
  p.linked_student_id,
  p.resolved_student_name,
  p.payer_name,
  p.student_name,
  p.amount,
  p.email_date,
  p.status
FROM payments p
WHERE 
  p.payer_name ILIKE '%Aleksandr%' 
  OR p.payer_name ILIKE '%Petrosyan%'
  OR p.student_name ILIKE '%Aleksandr%'
  OR p.student_name ILIKE '%Petrosyan%'
  OR p.resolved_student_name ILIKE '%Aleksandr%'
  OR p.resolved_student_name ILIKE '%Petrosyan%'
ORDER BY p.email_date DESC;
