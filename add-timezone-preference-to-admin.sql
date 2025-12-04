-- Add timezone preference column to admin_accounts table
-- This allows timezone settings to sync across all devices

-- Add the column if it doesn't exist
ALTER TABLE admin_accounts 
ADD COLUMN IF NOT EXISTS timezone_offset VARCHAR(10) DEFAULT NULL;

-- Values will be: NULL (no offset), '-12' (winter), or '-11' (summer)

-- Verify the change
SELECT column_name, data_type, column_default
FROM information_schema.columns 
WHERE table_name = 'admin_accounts' 
  AND column_name = 'timezone_offset';

-- Check current admin settings
SELECT email, timezone_offset
FROM admin_accounts
ORDER BY email;
