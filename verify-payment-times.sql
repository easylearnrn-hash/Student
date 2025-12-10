-- Verify payment times for Dec 7 payments
SELECT 
  p.id,
  p.payer_name,
  p.date,
  p.email_date,
  p.created_at,
  -- Show the time portion in LA timezone
  p.email_date AT TIME ZONE 'America/Los_Angeles' as email_date_la,
  EXTRACT(HOUR FROM p.email_date AT TIME ZONE 'America/Los_Angeles') as hour_la,
  EXTRACT(MINUTE FROM p.email_date AT TIME ZONE 'America/Los_Angeles') as minute_la
FROM payments p
WHERE p.date >= '2025-12-07' AND p.date < '2025-12-08'
ORDER BY p.email_date;
