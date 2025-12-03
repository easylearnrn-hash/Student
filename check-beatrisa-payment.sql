-- Check Beatrisa's Payment Status
-- Run this in Supabase SQL Editor

-- =====================================================
-- 1. CHECK STUDENT RECORD
-- =====================================================
SELECT 
  id,
  name,
  group_name,
  price_per_class,
  balance,
  aliases,
  show_in_grid
FROM students
WHERE name ILIKE '%beatrisa%' OR name ILIKE '%arushanyan%';

-- =====================================================
-- 2. CHECK PAYMENTS TABLE (Zelle/Gmail payments)
-- =====================================================
SELECT 
  id,
  email_date,
  amount,
  sender_name,
  resolved_student_name,
  student_id,
  linked_student_id,
  created_at
FROM payments
WHERE 
  sender_name ILIKE '%beatrisa%' 
  OR sender_name ILIKE '%arushanyan%'
  OR sender_name ILIKE '%oganes%'
  OR sender_name ILIKE '%terterian%'
  OR resolved_student_name ILIKE '%beatrisa%'
  OR resolved_student_name ILIKE '%arushanyan%'
  OR resolved_student_name ILIKE '%oganes%'
  OR resolved_student_name ILIKE '%terterian%'
ORDER BY email_date DESC
LIMIT 10;

-- =====================================================
-- 3. CHECK PAYMENT_RECORDS TABLE (Manual entries)
-- =====================================================
SELECT 
  id,
  student_id,
  date,
  amount,
  status,
  notes,
  created_at
FROM payment_records
WHERE student_id = (
  SELECT id FROM students 
  WHERE name ILIKE '%beatrisa%arushanyan%' 
  LIMIT 1
)
ORDER BY date DESC
LIMIT 10;

-- =====================================================
-- 4. CHECK IF PAYMENT IS LINKED TO STUDENT
-- =====================================================
SELECT 
  p.id,
  p.email_date,
  p.amount,
  p.sender_name,
  p.resolved_student_name,
  p.student_id,
  p.linked_student_id,
  s.id as actual_student_id,
  s.name as actual_student_name
FROM payments p
LEFT JOIN students s ON (
  p.linked_student_id = s.id 
  OR p.student_id = s.id
)
WHERE 
  s.name ILIKE '%beatrisa%arushanyan%'
  OR p.sender_name ILIKE '%beatrisa%'
  OR p.sender_name ILIKE '%oganes%'
ORDER BY p.email_date DESC
LIMIT 5;

-- =====================================================
-- 5. EXPECTED RESULTS
-- =====================================================
-- You should see:
-- 1. Student record with id, aliases array
-- 2. Payment(s) from Gmail with email_date around Dec 2
-- 3. linked_student_id or student_id matching student's id
-- 
-- If linked_student_id is NULL:
--   → Payment exists but not linked to student
--   → Calendar can't match it
--
-- If payment doesn't exist at all:
--   → Gmail sync didn't save it to database
--   → Need to re-sync from Payment Records page
