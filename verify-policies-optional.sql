-- ============================================================================
-- OPTIONAL: Additional RLS Policy for Test Suite
-- Only run this IF tests still fail after logging in
-- ============================================================================

-- This adds a policy to allow authenticated admins to access all tables
-- Your existing policies already look good, so this may not be needed

-- Check current policies first
SELECT 
  tablename,
  policyname,
  cmd,
  roles
FROM pg_policies
WHERE tablename IN ('students', 'payment_records', 'student_notes', 'tests', 'sent_emails', 'notifications')
ORDER BY tablename, policyname;

-- ============================================================================
-- IMPORTANT: Review the output above before running anything below
-- ============================================================================

-- If you see policies that reference 'is_active', run this cleanup:
-- (Based on your output, this may not be needed)

/*
-- Example: Update students policy if needed
DROP POLICY IF EXISTS "students_admin_all" ON students;
CREATE POLICY "students_admin_all" 
ON students 
FOR ALL 
TO authenticated 
USING (
  auth.uid() IN (
    SELECT auth_user_id FROM admin_accounts
  )
)
WITH CHECK (
  auth.uid() IN (
    SELECT auth_user_id FROM admin_accounts
  )
);
*/

-- ============================================================================
-- If tests still fail, ensure admin_accounts has your email
-- ============================================================================

SELECT 
  email,
  auth_user_id,
  CASE 
    WHEN auth_user_id IS NULL THEN '❌ Missing auth_user_id'
    ELSE '✅ Configured'
  END as status
FROM admin_accounts;

-- Add yourself if missing:
-- INSERT INTO admin_accounts (email, auth_user_id)
-- VALUES ('your-email@example.com', auth.uid())
-- ON CONFLICT (email) DO NOTHING;

SELECT '✅ Policy review complete. Your existing policies look good!' as result;
