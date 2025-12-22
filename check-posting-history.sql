-- Check session_logs for any posting activity
SELECT * FROM session_logs 
ORDER BY session_start DESC 
LIMIT 20;

-- Check sent_emails for note posting notifications
SELECT 
  sent_at,
  recipient_email,
  subject,
  email_type
FROM sent_emails 
WHERE subject LIKE '%Note Posted%'
ORDER BY sent_at DESC
LIMIT 50;

-- Check all existing permissions (both group and individual)
SELECT 
  snp.note_id,
  sn.title,
  sn.system_category,
  snp.group_name,
  snp.student_id,
  s.name as student_name,
  snp.granted_at,
  snp.granted_by
FROM student_note_permissions snp
JOIN student_notes sn ON snp.note_id = sn.id
LEFT JOIN students s ON snp.student_id = s.id
ORDER BY snp.granted_at DESC
LIMIT 100;

-- Get count by system and group
SELECT 
  sn.system_category,
  snp.group_name,
  COUNT(*) as note_count,
  MAX(snp.granted_at) as last_posted
FROM student_note_permissions snp
JOIN student_notes sn ON snp.note_id = sn.id
WHERE snp.student_id IS NULL  -- Group permissions only
GROUP BY sn.system_category, snp.group_name
ORDER BY last_posted DESC;
