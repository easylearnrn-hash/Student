-- ============================================================
-- ARNOMA SUPABASE SQL HELP GUIDE
-- Complete reference for all database queries you might need
-- ============================================================

-- ============================================================
-- 1. DATABASE STRUCTURE QUERIES
-- ============================================================

-- See ALL tables in your database
SELECT table_name 
FROM information_schema.tables 
WHERE table_schema = 'public' 
ORDER BY table_name;

-- See structure of a SPECIFIC table (replace 'students' with any table name)
SELECT column_name, data_type, is_nullable, column_default
FROM information_schema.columns 
WHERE table_name = 'students' 
ORDER BY ordinal_position;

-- See structure of ALL tables at once
SELECT table_name, column_name, data_type, is_nullable
FROM information_schema.columns 
WHERE table_schema = 'public' 
ORDER BY table_name, ordinal_position;

-- Count how many rows in each table
SELECT 
  schemaname,
  tablename,
  n_tup_ins as total_rows
FROM pg_stat_user_tables
ORDER BY tablename;


-- ============================================================
-- 2. TIMEZONE OFFSET QUERIES
-- ============================================================

-- Check if -12h or -11h timezone is ON or OFF
SELECT 
  email, 
  timezone_offset,
  CASE 
    WHEN timezone_offset = '-12' THEN '✅ Winter offset ON (-12h)'
    WHEN timezone_offset = '-11' THEN '✅ Summer offset ON (-11h)'
    WHEN timezone_offset IS NULL THEN '❌ Offset OFF (null)'
    ELSE '⚠️ Unknown value: ' || timezone_offset
  END as status
FROM admin_accounts
WHERE email = 'hrachfilm@gmail.com';

-- Manually turn ON -12h winter offset
UPDATE admin_accounts 
SET timezone_offset = '-12' 
WHERE email = 'hrachfilm@gmail.com';

-- Manually turn ON -11h summer offset
UPDATE admin_accounts 
SET timezone_offset = '-11' 
WHERE email = 'hrachfilm@gmail.com';

-- Manually turn OFF timezone offset
UPDATE admin_accounts 
SET timezone_offset = NULL 
WHERE email = 'hrachfilm@gmail.com';


-- ============================================================
-- 3. ADMIN ACCOUNTS QUERIES
-- ============================================================

-- See ALL admin accounts
SELECT email, auth_user_id, timezone_offset, name, role 
FROM admin_accounts 
ORDER BY email;

-- Check if a specific email is an admin
SELECT * FROM admin_accounts 
WHERE email = 'hrachfilm@gmail.com';

-- Add a new admin account (replace email and auth_user_id)
INSERT INTO admin_accounts (email, auth_user_id, name, role)
VALUES ('newadmin@gmail.com', 'paste-auth-user-id-here', 'Admin Name', 'admin');

-- Remove an admin account
DELETE FROM admin_accounts 
WHERE email = 'email-to-remove@gmail.com';


-- ============================================================
-- 4. STUDENTS QUERIES
-- ============================================================

-- See ALL students
SELECT id, name, email, group_name, balance, show_in_grid, price_per_class
FROM students 
ORDER BY name;

-- Count total students
SELECT COUNT(*) as total_students FROM students;

-- See only ACTIVE students (show_in_grid = true)
SELECT name, email, group_name, balance 
FROM students 
WHERE show_in_grid = true 
ORDER BY name;

-- See only INACTIVE students
SELECT name, email, group_name, balance 
FROM students 
WHERE show_in_grid = false 
ORDER BY name;

-- Find students by group (replace 'A' with group letter)
SELECT name, email, balance, price_per_class 
FROM students 
WHERE group_name = 'A' 
ORDER BY name;

-- Find students with negative balance (owe money)
SELECT name, email, balance 
FROM students 
WHERE balance < 0 
ORDER BY balance;

-- Find students with positive balance (credit)
SELECT name, email, balance 
FROM students 
WHERE balance > 0 
ORDER BY balance DESC;

-- Search for a specific student by name
SELECT * FROM students 
WHERE name ILIKE '%search-name-here%';

-- Update student's balance
UPDATE students 
SET balance = 100 
WHERE email = 'student@email.com';


-- ============================================================
-- 5. STUDENT SESSIONS QUERIES (Online Status & Study Time)
-- ============================================================

-- See ALL currently active sessions
SELECT 
  s.name as student_name,
  ss.session_start,
  ss.last_activity,
  ss.is_active,
  EXTRACT(EPOCH FROM (NOW() - ss.session_start)) / 3600 as hours_online
FROM student_sessions ss
JOIN students s ON s.id = ss.student_id
WHERE ss.is_active = true
ORDER BY ss.session_start DESC;

-- See who was online in the last 10 minutes (truly active)
SELECT 
  s.name as student_name,
  ss.last_activity,
  EXTRACT(EPOCH FROM (NOW() - ss.last_activity)) / 60 as minutes_ago
FROM student_sessions ss
JOIN students s ON s.id = ss.student_id
WHERE ss.is_active = true 
  AND ss.last_activity > NOW() - INTERVAL '10 minutes'
ORDER BY ss.last_activity DESC;

-- Clear ALL student sessions (use this to reset false online statuses)
DELETE FROM student_sessions;

-- Clear sessions for a specific student
DELETE FROM student_sessions 
WHERE student_id = (SELECT id FROM students WHERE email = 'student@email.com');

-- See total study time for each student (all sessions ever)
SELECT 
  s.name,
  COUNT(ss.id) as total_sessions,
  SUM(EXTRACT(EPOCH FROM (ss.session_end - ss.session_start)) / 3600) as total_hours
FROM students s
LEFT JOIN student_sessions ss ON s.id = ss.student_id
GROUP BY s.name
ORDER BY total_hours DESC NULLS LAST;


-- ============================================================
-- 6. PAYMENT RECORDS QUERIES
-- ============================================================

-- See ALL payment records
SELECT id, student_name, amount, status, class_date, created_at
FROM payment_records 
ORDER BY created_at DESC 
LIMIT 100;

-- Count payments by status
SELECT status, COUNT(*) as count 
FROM payment_records 
GROUP BY status 
ORDER BY count DESC;

-- See payments for a specific student
SELECT class_date, amount, status, created_at 
FROM payment_records 
WHERE student_name ILIKE '%student-name%' 
ORDER BY class_date DESC;

-- Find all UNPAID records
SELECT student_name, class_date, amount 
FROM payment_records 
WHERE status = 'unpaid' 
ORDER BY class_date DESC;

-- Find all PAID records from last 30 days
SELECT student_name, class_date, amount, created_at 
FROM payment_records 
WHERE status = 'paid' 
  AND created_at > NOW() - INTERVAL '30 days' 
ORDER BY created_at DESC;

-- Total revenue (sum of all paid records)
SELECT SUM(amount) as total_revenue 
FROM payment_records 
WHERE status = 'paid';


-- ============================================================
-- 7. PAYMENTS (ZELLE) QUERIES
-- ============================================================

-- See ALL Zelle payments
SELECT id, sender_name, amount, payment_date, resolved_student_name, gmail_id
FROM payments 
ORDER BY payment_date DESC 
LIMIT 100;

-- Find unmatched Zelle payments (not linked to a student)
SELECT sender_name, amount, payment_date 
FROM payments 
WHERE resolved_student_name IS NULL 
ORDER BY payment_date DESC;

-- Find Zelle payments for a specific student
SELECT sender_name, amount, payment_date, gmail_id 
FROM payments 
WHERE resolved_student_name ILIKE '%student-name%' 
ORDER BY payment_date DESC;

-- Total Zelle revenue
SELECT SUM(amount) as total_zelle_revenue FROM payments;


-- ============================================================
-- 8. PDF NOTES QUERIES
-- ============================================================

-- See ALL PDF notes
SELECT id, title, class_date, folder_id, requires_payment, created_at
FROM student_notes 
ORDER BY class_date DESC;

-- See notes that require payment
SELECT title, class_date, folder_id 
FROM student_notes 
WHERE requires_payment = true 
ORDER BY class_date DESC;

-- See free notes (no payment required)
SELECT title, class_date, folder_id 
FROM student_notes 
WHERE requires_payment = false 
ORDER BY class_date DESC;

-- Count notes by folder
SELECT folder_id, COUNT(*) as note_count 
FROM student_notes 
GROUP BY folder_id 
ORDER BY note_count DESC;

-- Find notes by title keyword
SELECT title, class_date, requires_payment 
FROM student_notes 
WHERE title ILIKE '%search-keyword%' 
ORDER BY class_date DESC;


-- ============================================================
-- 9. GROUPS & SCHEDULES QUERIES
-- ============================================================

-- See ALL groups and their schedules
SELECT group_name, schedule, created_at 
FROM groups 
ORDER BY group_name;

-- Count students per group
SELECT g.group_name, COUNT(s.id) as student_count
FROM groups g
LEFT JOIN students s ON s.group_name = g.group_name
GROUP BY g.group_name
ORDER BY student_count DESC;


-- ============================================================
-- 10. EMAIL QUERIES
-- ============================================================

-- See last 50 sent emails
SELECT 
  email_type,
  recipient_email,
  subject,
  delivery_status,
  created_at
FROM sent_emails 
ORDER BY created_at DESC 
LIMIT 50;

-- Count emails by type
SELECT email_type, COUNT(*) as count 
FROM sent_emails 
GROUP BY email_type 
ORDER BY count DESC;

-- Check email delivery status
SELECT 
  email_type,
  delivery_status,
  COUNT(*) as count 
FROM sent_emails 
GROUP BY email_type, delivery_status 
ORDER BY email_type, delivery_status;


-- ============================================================
-- 11. MAINTENANCE & CLEANUP QUERIES
-- ============================================================

-- See database size
SELECT 
  pg_size_pretty(pg_database_size(current_database())) as database_size;

-- See size of each table
SELECT 
  tablename,
  pg_size_pretty(pg_total_relation_size(schemaname||'.'||tablename)) as size
FROM pg_tables
WHERE schemaname = 'public'
ORDER BY pg_total_relation_size(schemaname||'.'||tablename) DESC;

-- Find duplicate students (same email)
SELECT email, COUNT(*) as count 
FROM students 
GROUP BY email 
HAVING COUNT(*) > 1;

-- Find old sessions (more than 7 days old)
SELECT COUNT(*) as old_sessions 
FROM student_sessions 
WHERE session_start < NOW() - INTERVAL '7 days';

-- Delete old sessions (cleanup)
DELETE FROM student_sessions 
WHERE session_start < NOW() - INTERVAL '7 days';


-- ============================================================
-- 12. QUICK REFERENCE COMMANDS
-- ============================================================

-- Refresh the page data (no SQL needed, just use the web interface)
-- But if you want to verify data is fresh, use:
SELECT NOW() as current_time;

-- Check if RLS (Row Level Security) is enabled on a table
SELECT tablename, rowsecurity 
FROM pg_tables 
WHERE schemaname = 'public' 
  AND tablename = 'students';

-- See all active database connections
SELECT COUNT(*) as active_connections 
FROM pg_stat_activity 
WHERE state = 'active';


-- ============================================================
-- NOTES:
-- ============================================================
-- • Replace 'hrachfilm@gmail.com' with your actual admin email
-- • Replace 'student-name' with actual student names when searching
-- • Be careful with DELETE queries - they can't be undone!
-- • Always test UPDATE queries with SELECT first to see what you're changing
-- • Use LIMIT to avoid loading too many rows at once
-- ============================================================
