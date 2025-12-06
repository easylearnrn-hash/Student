-- Check what timezone_offset is actually stored in Supabase for your admin account
SELECT 
  email,
  timezone_offset,
  CASE 
    WHEN timezone_offset = '-12' THEN '✅ Winter offset (-12h) is SAVED'
    WHEN timezone_offset = '-11' THEN '✅ Summer offset (-11h) is SAVED'
    WHEN timezone_offset IS NULL THEN '❌ NO OFFSET SAVED (null)'
    ELSE '⚠️ Unexpected value: ' || timezone_offset
  END as status
FROM admin_accounts
WHERE email = (SELECT email FROM auth.users LIMIT 1);

-- If you get no results, run this to see ALL admins:
-- SELECT email, timezone_offset FROM admin_accounts;
