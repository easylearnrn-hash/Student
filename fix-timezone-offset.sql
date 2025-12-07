-- Fix timezone offset corruption in admin_accounts
-- The -12h offset is shifting payment dates incorrectly
-- This resets all admin timezone_offset to NULL (no offset)

UPDATE admin_accounts
SET timezone_offset = NULL
WHERE timezone_offset IN ('-12', '-11');

-- Verify the fix
SELECT email, timezone_offset
FROM admin_accounts
WHERE timezone_offset IS NOT NULL;
