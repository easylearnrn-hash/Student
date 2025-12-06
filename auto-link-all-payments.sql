-- AUTO-LINK ALL PAYMENTS TO STUDENT IDs
-- This will match payment names to student records and set linked_student_id

-- Step 1: Update payments where student_name matches student.name exactly
UPDATE payments p
SET linked_student_id = s.id
FROM students s
WHERE p.linked_student_id IS NULL
  AND p.student_name IS NOT NULL
  AND LOWER(TRIM(p.student_name)) = LOWER(TRIM(s.name));

-- Step 2: Update payments where payer_name matches student.name exactly
UPDATE payments p
SET linked_student_id = s.id
FROM students s
WHERE p.linked_student_id IS NULL
  AND p.payer_name IS NOT NULL
  AND LOWER(TRIM(p.payer_name)) = LOWER(TRIM(s.name));

-- Step 3: Partial name matching (first name + last name contained in student name)
UPDATE payments p
SET linked_student_id = s.id
FROM students s
WHERE p.linked_student_id IS NULL
  AND p.student_name IS NOT NULL
  AND s.name IS NOT NULL
  AND (
    -- All words in payment name appear in student name
    LOWER(s.name) LIKE '%' || REPLACE(LOWER(TRIM(p.student_name)), ' ', '%') || '%'
  );

-- Step 4: Check aliases (if aliases contain the payment name)
UPDATE payments p
SET linked_student_id = s.id
FROM students s
WHERE p.linked_student_id IS NULL
  AND p.student_name IS NOT NULL
  AND s.aliases IS NOT NULL
  AND (
    -- Check if aliases JSON array contains the name
    s.aliases::text ILIKE '%' || p.student_name || '%'
  );

-- Show results
SELECT 
  COUNT(*) FILTER (WHERE linked_student_id IS NOT NULL) as linked_count,
  COUNT(*) FILTER (WHERE linked_student_id IS NULL) as unlinked_count,
  COUNT(*) as total_payments
FROM payments;

-- Show unlinked payments (if any)
SELECT id, payer_name, student_name, amount, date, email_date
FROM payments
WHERE linked_student_id IS NULL
ORDER BY email_date DESC
LIMIT 20;
