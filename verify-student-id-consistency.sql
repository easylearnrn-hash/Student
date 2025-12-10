-- Verify student ID consistency across all tables
-- This query checks that student_id references in all tables match actual student IDs

-- 1. Check students table (source of truth)
SELECT 'students' as table_name, id, name, email 
FROM students 
ORDER BY id;

-- 2. Check payment_records - ensure all student_ids exist
SELECT 
  'payment_records' as table_name,
  pr.student_id,
  s.name as student_name,
  COUNT(*) as record_count,
  CASE 
    WHEN s.id IS NULL THEN '❌ ORPHANED'
    ELSE '✅ VALID'
  END as status
FROM payment_records pr
LEFT JOIN students s ON s.id = pr.student_id
GROUP BY pr.student_id, s.name, s.id
ORDER BY pr.student_id;

-- 3. Check payments table - ensure all student_ids and linked_student_ids exist
SELECT 
  'payments' as table_name,
  COALESCE(p.linked_student_id, p.student_id) as effective_student_id,
  s.name as student_name,
  COUNT(*) as record_count,
  CASE 
    WHEN s.id IS NULL THEN '❌ ORPHANED'
    ELSE '✅ VALID'
  END as status
FROM payments p
LEFT JOIN students s ON s.id = COALESCE(p.linked_student_id::bigint, p.student_id::bigint)
GROUP BY COALESCE(p.linked_student_id, p.student_id), s.name, s.id
ORDER BY effective_student_id;

-- 4. Check for mismatched data types
SELECT 
  'Data Type Check' as check_name,
  pg_typeof(id) as students_id_type,
  (SELECT pg_typeof(student_id) FROM payment_records LIMIT 1) as payment_records_student_id_type,
  (SELECT pg_typeof(student_id) FROM payments LIMIT 1) as payments_student_id_type,
  (SELECT pg_typeof(linked_student_id) FROM payments LIMIT 1) as payments_linked_student_id_type
FROM students LIMIT 1;

-- 5. Find any NULL student_ids
SELECT 'payment_records_nulls' as issue, COUNT(*) as count
FROM payment_records
WHERE student_id IS NULL
UNION ALL
SELECT 'payments_nulls' as issue, COUNT(*) as count
FROM payments
WHERE student_id IS NULL AND linked_student_id IS NULL;
