-- Check Agavni's payment dates to see what's stored vs what's displayed
SELECT 
  id,
  payer_name,
  student_name,
  amount,
  date as stored_date,
  email_date,
  email_date AT TIME ZONE 'America/Los_Angeles' as email_date_la,
  TO_CHAR(email_date AT TIME ZONE 'America/Los_Angeles', 'YYYY-MM-DD') as email_date_la_formatted,
  created_at
FROM payments 
WHERE payer_name ILIKE '%Agavni%'
ORDER BY email_date DESC;
