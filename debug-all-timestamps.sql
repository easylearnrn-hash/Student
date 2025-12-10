-- Check all timestamp fields for Dec 7 payments to find the right one
SELECT 
  p.id,
  p.payer_name,
  p.date,
  p.email_date,
  p.created_at,
  p."createdAt",
  -- Show all in LA timezone
  p.date AT TIME ZONE 'America/Los_Angeles' as date_la,
  p.email_date AT TIME ZONE 'America/Los_Angeles' as email_date_la,
  p.created_at AT TIME ZONE 'America/Los_Angeles' as created_at_la,
  p."createdAt" AT TIME ZONE 'America/Los_Angeles' as createdAt_la
FROM payments p
WHERE p.date >= '2025-12-07' AND p.date < '2025-12-08'
ORDER BY p.email_date;
