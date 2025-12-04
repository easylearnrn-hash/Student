-- Verify RLS policies for Payment Records page security
-- Ensure: Admin sees ALL, Students see ONLY their own

-- 1. Check policies on payment_records table
SELECT schemaname, tablename, policyname, permissive, roles, cmd, qual
FROM pg_policies 
WHERE tablename = 'payment_records'
ORDER BY policyname;

-- 2. Check policies on payments table (Zelle)
SELECT schemaname, tablename, policyname, permissive, roles, cmd, qual
FROM pg_policies 
WHERE tablename = 'payments'
ORDER BY policyname;

-- 3. Test: What can a student see?
-- If you log in as a student, they should ONLY see records where:
--   - payment_records: student_id = their ID
--   - payments: linked_student_id = their ID OR resolved_student_name = their name

-- 4. Test: What can admin (you) see?
-- Admin should see ALL records because of admin_accounts check
