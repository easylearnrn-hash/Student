-- EMERGENCY: Check for any backup tables or recent deletion records
-- Look for backup tables
SELECT table_name 
FROM information_schema.tables 
WHERE table_schema = 'public' 
AND (table_name LIKE '%backup%' OR table_name LIKE '%old%' OR table_name LIKE '%permissions%')
ORDER BY table_name;

-- Check if there's a way to see recently deleted rows (Supabase audit)
SELECT * FROM pg_stat_user_tables WHERE schemaname = 'public' AND relname = 'student_note_permissions';

-- Check if there are ANY permissions left at all
SELECT COUNT(*) FROM student_note_permissions;

-- Check the most recent permissions that still exist
SELECT 
  snp.*,
  sn.title,
  sn.system_category
FROM student_note_permissions snp
JOIN student_notes sn ON snp.note_id = sn.id
ORDER BY snp.id DESC
LIMIT 100;

-- Check if we deleted by granted_by field - maybe some survived
SELECT DISTINCT granted_by FROM student_note_permissions;

-- CRITICAL: Check if there's a postgres audit log or history
SELECT * FROM pg_stat_activity WHERE query LIKE '%student_note_permissions%';
