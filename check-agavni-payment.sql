-- Check if Agavni's payment was saved correctly
-- Find Agavni's student_id first
SELECT id, name, email, group_name 
FROM students 
WHERE name ILIKE '%agavni%' OR name ILIKE '%kalamkeryan%';

-- Then check what payments exist for that student_id
-- Replace XXX with the actual id from above
SELECT * FROM payment_records 
WHERE student_id = XXX  -- Replace with actual ID
ORDER BY date DESC
LIMIT 10;

-- Also check if there are any recent payments (last hour)
SELECT * FROM payment_records 
WHERE created_at > NOW() - INTERVAL '1 hour'
ORDER BY created_at DESC;
