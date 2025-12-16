-- Check current timezone setting for admin
SELECT email, timezone_offset, created_at, updated_at 
FROM admin_accounts 
WHERE email = 'hrachfilm@gmail.com';
