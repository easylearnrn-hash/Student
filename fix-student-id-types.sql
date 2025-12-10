-- CRITICAL: Fix student_id type mismatches across tables
-- The students.id is bigint, but payments table has text fields
-- This causes matching issues in Calendar and other modules

-- Step 1: Check current data types
SELECT 
  'students.id' as field,
  'bigint' as current_type,
  COUNT(*) as records,
  MIN(id) as min_id,
  MAX(id) as max_id
FROM students
UNION ALL
SELECT 
  'payment_records.student_id' as field,
  'bigint' as current_type,
  COUNT(*) as records,
  MIN(student_id) as min_id,
  MAX(student_id) as max_id
FROM payment_records
UNION ALL
SELECT 
  'payments.student_id (non-null)' as field,
  'text' as current_type,
  COUNT(CASE WHEN student_id IS NOT NULL THEN 1 END) as records,
  MIN(CASE WHEN student_id ~ '^\d+$' THEN student_id::bigint END) as min_id,
  MAX(CASE WHEN student_id ~ '^\d+$' THEN student_id::bigint END) as max_id
FROM payments
UNION ALL
SELECT 
  'payments.linked_student_id (non-null)' as field,
  'text' as current_type,
  COUNT(CASE WHEN linked_student_id IS NOT NULL THEN 1 END) as records,
  MIN(CASE WHEN linked_student_id ~ '^\d+$' THEN linked_student_id::bigint END) as min_id,
  MAX(CASE WHEN linked_student_id ~ '^\d+$' THEN linked_student_id::bigint END) as max_id
FROM payments;

-- Step 2: Check for invalid text values in payments table
-- (values that can't be converted to bigint)
SELECT 
  'Invalid student_id values' as issue,
  student_id,
  COUNT(*) as occurrences
FROM payments
WHERE student_id IS NOT NULL 
  AND student_id !~ '^\d+$'  -- Not numeric
GROUP BY student_id
UNION ALL
SELECT 
  'Invalid linked_student_id values' as issue,
  linked_student_id,
  COUNT(*) as occurrences
FROM payments
WHERE linked_student_id IS NOT NULL 
  AND linked_student_id !~ '^\d+$'  -- Not numeric
GROUP BY linked_student_id;

-- Step 3: Verify all text IDs match actual student records
SELECT 
  'Orphaned payment student_ids' as issue,
  p.student_id,
  COUNT(*) as payments_count
FROM payments p
LEFT JOIN students s ON s.id = p.student_id::bigint
WHERE p.student_id IS NOT NULL
  AND p.student_id ~ '^\d+$'
  AND s.id IS NULL
GROUP BY p.student_id
UNION ALL
SELECT 
  'Orphaned payment linked_student_ids' as issue,
  p.linked_student_id,
  COUNT(*) as payments_count
FROM payments p
LEFT JOIN students s ON s.id = p.linked_student_id::bigint
WHERE p.linked_student_id IS NOT NULL
  AND p.linked_student_id ~ '^\d+$'
  AND s.id IS NULL
GROUP BY p.linked_student_id;

-- Step 4: ONLY RUN THIS IF STEP 2 & 3 SHOW NO ISSUES
-- Convert payments.student_id from text to bigint
-- ALTER TABLE payments ALTER COLUMN student_id TYPE bigint USING student_id::bigint;

-- Step 5: ONLY RUN THIS IF STEP 2 & 3 SHOW NO ISSUES  
-- Convert payments.linked_student_id from text to bigint
-- ALTER TABLE payments ALTER COLUMN linked_student_id TYPE bigint USING linked_student_id::bigint;

-- Step 6: After conversion, verify consistency
-- SELECT 
--   'Post-migration check' as status,
--   (SELECT pg_typeof(id) FROM students LIMIT 1) as students_id_type,
--   (SELECT pg_typeof(student_id) FROM payment_records LIMIT 1) as payment_records_type,
--   (SELECT pg_typeof(student_id) FROM payments LIMIT 1) as payments_student_id_type,
--   (SELECT pg_typeof(linked_student_id) FROM payments LIMIT 1) as payments_linked_type;
