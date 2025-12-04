-- Link Aleksandr Petrosyan's payment to his student record

-- Step 1: Get Aleksandr's student ID
SELECT id, name, email FROM students WHERE name ILIKE '%Aleksandr%Petrosyan%';
-- Copy the student ID from above

-- Step 2: Link the payment
UPDATE payments
SET 
  linked_student_id = (SELECT id FROM students WHERE name ILIKE '%Aleksandr%Petrosyan%'),
  resolved_student_name = 'Aleksandr Petrosyan',
  status = 'matched'
WHERE id = '19ae86d6552749a3';

-- Step 3: Verify it worked
SELECT 
  id,
  linked_student_id,
  resolved_student_name,
  payer_name,
  amount,
  status
FROM payments
WHERE id = '19ae86d6552749a3';

-- The linked_student_id should now have a value and status should be 'matched'
