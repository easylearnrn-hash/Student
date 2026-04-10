-- ============================================================================
-- EMERGENCY: REMOVE NARINE FROM ADMIN ACCOUNTS
-- ============================================================================
-- Run this ONLY if Narine appears in admin_accounts table

-- Step 1: Check what we're about to delete
SELECT 
  '⚠️ ABOUT TO REMOVE:' as "Warning",
  auth_user_id,
  email,
  timezone_offset
FROM admin_accounts
WHERE LOWER(email) LIKE '%narine%' OR LOWER(email) LIKE '%avetisyan%';

-- Step 2: Delete Narine from admin_accounts
DELETE FROM admin_accounts
WHERE LOWER(email) LIKE '%narine%' OR LOWER(email) LIKE '%avetisyan%';

-- Step 3: Verify removal
SELECT 
  '✅ REMAINING ADMINS:' as "Status",
  auth_user_id,
  email,
  timezone_offset
FROM admin_accounts
ORDER BY email;

-- Step 4: Confirm Narine is gone
SELECT 
  CASE 
    WHEN COUNT(*) = 0 THEN '✅ Narine successfully removed from admin_accounts'
    ELSE '❌ Narine STILL in admin_accounts - try again!'
  END as "Final Check"
FROM admin_accounts
WHERE LOWER(email) LIKE '%narine%' OR LOWER(email) LIKE '%avetisyan%';
