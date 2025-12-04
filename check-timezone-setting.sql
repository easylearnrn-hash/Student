if you wanna check if the -12 timezone is on or off in supabase
-- Check current timezone setting for your admin account
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
