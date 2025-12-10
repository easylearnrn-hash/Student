-- ========================================
-- FIX: Add RLS Policies for credit_payments
-- ========================================
-- This gives admin accounts full access to credit_payments table

-- First, check if policies already exist
SELECT policyname, cmd 
FROM pg_policies 
WHERE tablename = 'credit_payments';

-- If no policies exist, run these:

-- Enable RLS if not already enabled
ALTER TABLE credit_payments ENABLE ROW LEVEL SECURITY;

-- Drop existing policies if any (just to be safe)
DROP POLICY IF EXISTS "credit_payments_admin_all" ON credit_payments;
DROP POLICY IF EXISTS "Admin full access to credit_payments" ON credit_payments;

-- Create new admin policy (allows SELECT, INSERT, UPDATE, DELETE)
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

-- Verify the policy was created
SELECT policyname, cmd, qual, with_check
FROM pg_policies 
WHERE tablename = 'credit_payments';
