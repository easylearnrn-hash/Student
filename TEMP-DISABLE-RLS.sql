-- TEMPORARY: Disable RLS to unblock admin access
-- Run this to fix the 403 permission errors

ALTER TABLE student_notes DISABLE ROW LEVEL SECURITY;
ALTER TABLE student_note_permissions DISABLE ROW LEVEL SECURITY;
ALTER TABLE students DISABLE ROW LEVEL SECURITY;
ALTER TABLE payments DISABLE ROW LEVEL SECURITY;
ALTER TABLE payment_records DISABLE ROW LEVEL SECURITY;
ALTER TABLE admin_accounts DISABLE ROW LEVEL SECURITY;

-- Show success
SELECT '✅ RLS disabled - you can now access all tables' as status;
