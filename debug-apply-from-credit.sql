-- ========================================
-- DEBUG: Apply from Credit Not Working
-- ========================================
-- Run these queries to diagnose why "Apply from Credit" button doesn't work

-- STEP 1: Check if credit_payments table exists and has correct structure
SELECT 
  column_name,
  data_type,
  is_nullable
FROM information_schema.columns
WHERE table_name = 'credit_payments'
ORDER BY ordinal_position;

-- Expected columns:
-- | column_name   | data_type | is_nullable |
-- | id            | bigint    | NO          |
-- | student_id    | bigint    | NO          |
-- | class_date    | date      | NO          |
-- | amount        | numeric   | NO          |
-- | balance_after | numeric   | YES         |
-- | applied_at    | timestamp | YES         |
-- | created_at    | timestamp | YES         |


-- STEP 2: Check RLS policies on credit_payments
SELECT 
  schemaname,
  tablename,
  policyname,
  permissive,
  roles,
  cmd,
  qual,
  with_check
FROM pg_policies
WHERE tablename = 'credit_payments';

-- Should have admin policies that allow INSERT/UPDATE/DELETE


-- STEP 3: Check if admin account has proper access
SELECT 
  email,
  auth_user_id
FROM admin_accounts
WHERE email = '[YOUR_ADMIN_EMAIL]';  -- Replace with your email

-- Should return 1 row with your email


-- STEP 4: Test INSERT permission (THIS IS THE KEY TEST)
-- Try to insert a test record manually
INSERT INTO credit_payments (student_id, class_date, amount, balance_after, applied_at, created_at)
VALUES (
  1,  -- Replace with actual student ID
  '2025-12-10',  -- Today's date
  50,  -- Test amount
  100,  -- Test balance
  NOW(),
  NOW()
);

-- If this FAILS, you have an RLS permission issue
-- If this SUCCEEDS, delete the test record:
-- DELETE FROM credit_payments WHERE student_id = 1 AND class_date = '2025-12-10';


-- STEP 5: Check student balance (make sure student actually has credit)
SELECT 
  id,
  name,
  balance,
  price_per_class
FROM students
WHERE balance > 0
ORDER BY balance DESC
LIMIT 10;

-- Should show students with positive balance (credit)


-- STEP 6: Verify CreditPaymentManager is initialized
-- Run this in Browser Console (Calendar.html page):
/*
console.log('CreditPaymentManager exists?', !!window.CreditPaymentManager);
console.log('CreditPaymentManager methods:', Object.keys(window.CreditPaymentManager || {}));

// Test if applyCreditPayment exists
if (window.CreditPaymentManager) {
  console.log('applyCreditPayment method:', window.CreditPaymentManager.applyCreditPayment);
} else {
  console.error('❌ CreditPaymentManager not loaded!');
}
*/


-- STEP 7: Check if there are any existing credit_payments records
SELECT 
  cp.*,
  s.name as student_name
FROM credit_payments cp
LEFT JOIN students s ON s.id = cp.student_id
ORDER BY cp.created_at DESC
LIMIT 20;

-- Shows recent credit payment applications


-- ========================================
-- COMMON ISSUES & FIXES
-- ========================================

-- Issue 1: RLS blocking INSERT/UPDATE
-- Fix: Run this to give admin full access:
/*
CREATE POLICY "credit_payments_admin_all"
ON credit_payments
FOR ALL
TO authenticated
USING (
  auth.uid() IN (SELECT auth_user_id FROM admin_accounts)
)
WITH CHECK (
  auth.uid() IN (SELECT auth_user_id FROM admin_accounts)
);
*/


-- Issue 2: Table doesn't exist
-- Fix: Create the table:
/*
CREATE TABLE IF NOT EXISTS credit_payments (
  id BIGSERIAL PRIMARY KEY,
  student_id BIGINT NOT NULL REFERENCES students(id),
  class_date DATE NOT NULL,
  amount NUMERIC(10,2) NOT NULL,
  balance_after NUMERIC(10,2),
  applied_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(student_id, class_date)
);

ALTER TABLE credit_payments ENABLE ROW LEVEL SECURITY;
*/


-- Issue 3: CreditPaymentManager not loading
-- Check Browser Console for:
-- - "🚀 Initializing CreditPaymentManager..."
-- - Any JavaScript errors
-- - Network errors when loading credit_payments table
