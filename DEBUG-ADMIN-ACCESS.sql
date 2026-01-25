-- ============================================================================
-- 🚨 EMERGENCY: CHECK WHY ADMIN ACCESS ISN'T WORKING
-- ============================================================================

-- STEP 1: Check if is_arnoma_admin() function exists
SELECT routine_name, routine_type
FROM information_schema.routines
WHERE routine_name = 'is_arnoma_admin';

-- STEP 2: Check if hrachfilm@gmail.com is in admin_accounts
SELECT * FROM admin_accounts WHERE email = 'hrachfilm@gmail.com';

-- STEP 3: Check current authenticated user
SELECT 
  auth.uid() as "Current User ID",
  auth.email() as "Current Email",
  auth.role() as "Current Role";

-- STEP 4: Test if is_arnoma_admin() returns TRUE for you
SELECT is_arnoma_admin() as "Am I Admin?";

-- STEP 5: Check if your auth_user_id matches admin_accounts
SELECT 
  a.email,
  a.auth_user_id as "Admin Table User ID",
  auth.uid() as "Current Auth UID",
  CASE 
    WHEN a.auth_user_id = auth.uid() THEN '✅ MATCH'
    ELSE '❌ MISMATCH'
  END as "ID Match Status"
FROM admin_accounts a
WHERE a.email = 'hrachfilm@gmail.com';

-- STEP 6: If function doesn't exist or is broken, recreate it
CREATE OR REPLACE FUNCTION is_arnoma_admin()
RETURNS BOOLEAN AS $$
BEGIN
  RETURN EXISTS (
    SELECT 1 
    FROM admin_accounts 
    WHERE auth_user_id = auth.uid()
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- STEP 7: Test again
SELECT is_arnoma_admin() as "Am I Admin NOW?";

-- STEP 8: If still FALSE, manually add your auth_user_id to admin_accounts
INSERT INTO admin_accounts (auth_user_id, email)
VALUES (
  auth.uid(),
  'hrachfilm@gmail.com'
)
ON CONFLICT (auth_user_id) 
DO UPDATE SET email = EXCLUDED.email;

-- STEP 9: Final verification
SELECT 
  'Admin Check' as "Test",
  is_arnoma_admin() as "Result",
  CASE 
    WHEN is_arnoma_admin() THEN '✅ YOU CAN NOW ACCESS PAYMENT RECORDS'
    ELSE '❌ STILL BROKEN - CHECK CONSOLE'
  END as "Status";

-- STEP 10: If you're authenticated, show what payments you can see
SELECT COUNT(*) as "Payments You Can Access"
FROM payments;

SELECT COUNT(*) as "Payment Records You Can Access"  
FROM payment_records;

SELECT COUNT(*) as "Credit Payments You Can Access"
FROM credit_payments;
