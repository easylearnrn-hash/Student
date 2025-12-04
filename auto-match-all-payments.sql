-- ========================================================
-- AUTO-MATCH ALL UNMATCHED PAYMENTS TO STUDENTS
-- ========================================================
-- This finds all unmatched payments and links them to students
-- by matching payer_name to student names
-- ========================================================

-- Step 1: See what will be matched (DRY RUN)
SELECT 
  p.id as payment_id,
  p.payer_name,
  p.amount,
  p.email_date,
  p.status as current_status,
  s.id as student_id,
  s.name as student_name,
  'WILL BE MATCHED' as action
FROM payments p
INNER JOIN students s ON (
  -- Match if payer_name contains the student's name (case insensitive)
  p.payer_name ILIKE '%' || s.name || '%'
  OR s.name ILIKE '%' || p.payer_name || '%'
)
WHERE p.status = 'unmatched'
  AND p.linked_student_id IS NULL
ORDER BY p.email_date DESC;

-- Step 2: AUTO-MATCH ALL (run this after reviewing above)
UPDATE payments p
SET 
  linked_student_id = s.id,
  resolved_student_name = s.name,
  status = 'matched'
FROM students s
WHERE p.status = 'unmatched'
  AND p.linked_student_id IS NULL
  AND (
    p.payer_name ILIKE '%' || s.name || '%'
    OR s.name ILIKE '%' || p.payer_name || '%'
  );

-- Step 3: Verify results
SELECT 
  COUNT(*) FILTER (WHERE status = 'matched') as matched_count,
  COUNT(*) FILTER (WHERE status = 'unmatched') as unmatched_count,
  COUNT(*) FILTER (WHERE linked_student_id IS NOT NULL) as linked_count,
  COUNT(*) as total_payments
FROM payments;

-- Step 4: Show remaining unmatched payments (need manual review)
SELECT 
  id,
  payer_name,
  student_name,
  amount,
  email_date,
  status
FROM payments
WHERE status = 'unmatched'
ORDER BY email_date DESC;
