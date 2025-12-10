-- ========================================
-- DEBUG: Check is_arnoma_admin() Function
-- ========================================

-- Step 1: Check if function exists
SELECT 
  proname as function_name,
  pg_get_functiondef(oid) as function_definition
FROM pg_proc 
WHERE proname = 'is_arnoma_admin';

-- Step 2: Test if current user is recognized as admin
SELECT is_arnoma_admin() as am_i_admin;

-- Step 3: Check your admin account record
SELECT 
  auth_user_id,
  email,
  auth.uid() as current_user_id,
  auth.uid() = auth_user_id as is_match
FROM admin_accounts
WHERE email = (SELECT email FROM auth.users WHERE id = auth.uid());

-- Step 4: Check if auth.uid() is in admin_accounts
SELECT 
  auth.uid() as my_auth_uid,
  EXISTS (SELECT 1 FROM admin_accounts WHERE auth_user_id = auth.uid()) as exists_in_admin_accounts,
  (SELECT email FROM auth.users WHERE id = auth.uid()) as my_email;

-- ========================================
-- If is_arnoma_admin() returns FALSE or doesn't exist:
-- ========================================

-- Option A: Create/Replace the function
CREATE OR REPLACE FUNCTION is_arnoma_admin()
RETURNS BOOLEAN AS $$
BEGIN
  RETURN EXISTS (
    SELECT 1 FROM admin_accounts 
    WHERE auth_user_id = auth.uid()
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Option B: Verify admin_accounts has your user_id
-- Get your current auth.uid():
SELECT auth.uid() as my_user_id;

-- Check if you're in admin_accounts:
SELECT * FROM admin_accounts WHERE auth_user_id = auth.uid();

-- If NOT found, add yourself:
-- (Replace 'your-email@gmail.com' with your actual email)
/*
INSERT INTO admin_accounts (auth_user_id, email)
VALUES (
  auth.uid(),
  (SELECT email FROM auth.users WHERE id = auth.uid())
)
ON CONFLICT (auth_user_id) DO NOTHING;
*/
