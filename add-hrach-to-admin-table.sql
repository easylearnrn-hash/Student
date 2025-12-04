-- Check if hrachfilm@gmail.com is in admin_accounts table
SELECT * FROM admin_accounts WHERE email = 'hrachfilm@gmail.com';

-- If it returns no results, run this to add you:
INSERT INTO admin_accounts (email, name, role, created_at)
VALUES (
  'hrachfilm@gmail.com',
  'Hrach',
  'super_admin',
  NOW()
)
ON CONFLICT (email) DO UPDATE SET role = 'super_admin';
