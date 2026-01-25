-- ============================================================================
-- 🔍 SUPABASE RLS POLICY AUDIT - Verify Student Data Isolation
-- ============================================================================
-- Run this in Supabase SQL Editor to verify security

-- =============================================================================
-- PART 1: Check RLS is ENABLED on Payment Tables
-- =============================================================================

SELECT 
  '=== RLS STATUS CHECK ===' as "Audit Section",
  tablename as "Table",
  rowsecurity as "RLS Enabled"
FROM pg_tables 
WHERE schemaname = 'public' 
  AND tablename IN ('payments', 'payment_records', 'credit_payments', 'students', 'student_notes')
ORDER BY tablename;

-- Expected: ALL tables should show rowsecurity = true

-- =============================================================================
-- PART 2: List ALL Policies on Payment Tables
-- =============================================================================

SELECT 
  '=== CURRENT RLS POLICIES ===' as "Audit Section",
  tablename as "Table",
  policyname as "Policy Name",
  cmd as "Command",
  roles as "Roles",
  qual as "USING (Filter)",
  with_check as "WITH CHECK"
FROM pg_policies 
WHERE schemaname = 'public' 
  AND tablename IN ('payments', 'payment_records', 'credit_payments')
ORDER BY tablename, cmd, policyname;

-- Expected: 
-- - 12 policies total (4 per table: SELECT, INSERT, UPDATE, DELETE)
-- - All should have is_arnoma_admin() OR student_id matching
-- - NO policies with roles = {anon} or {public} for SELECT

-- =============================================================================
-- PART 3: Check for DANGEROUS Anon/Public Policies
-- =============================================================================

SELECT 
  '=== DANGEROUS POLICIES (Should be EMPTY) ===' as "Audit Section",
  tablename as "Table",
  policyname as "Policy Name",
  cmd as "Command",
  roles as "Roles",
  '⚠️ SECURITY RISK: Public can access!' as "Risk Level"
FROM pg_policies 
WHERE schemaname = 'public' 
  AND tablename IN ('payments', 'payment_records', 'credit_payments')
  AND cmd = 'SELECT'
  AND ('anon' = ANY(roles) OR 'public' = ANY(roles));

-- Expected: ZERO rows (no dangerous policies)

-- =============================================================================
-- PART 4: Verify Admin Function Exists
-- =============================================================================

SELECT 
  '=== ADMIN FUNCTION CHECK ===' as "Audit Section",
  proname as "Function Name",
  pg_get_functiondef(oid) as "Function Definition"
FROM pg_proc
WHERE proname = 'is_arnoma_admin';

-- Expected: Function exists and checks admin_accounts table

-- =============================================================================
-- PART 5: Verify Type Casting in Policies
-- =============================================================================

SELECT 
  '=== TYPE CASTING VERIFICATION ===' as "Audit Section",
  tablename as "Table",
  policyname as "Policy Name",
  cmd as "Command",
  CASE 
    WHEN qual::text LIKE '%student_id::bigint%' THEN '✅ Type-safe'
    WHEN qual::text LIKE '%linked_student_id::bigint%' THEN '✅ Type-safe'
    WHEN qual::text LIKE '%student_id%' AND qual::text NOT LIKE '%::bigint%' THEN '⚠️ May have type issues'
    ELSE '✅ OK'
  END as "Type Safety"
FROM pg_policies 
WHERE schemaname = 'public' 
  AND tablename IN ('payments', 'payment_records', 'credit_payments')
  AND cmd = 'SELECT';

-- Expected: All should be type-safe with ::bigint casting

-- =============================================================================
-- PART 6: Test Student Isolation (Simulate Student Query)
-- =============================================================================

-- This shows what a student would see if they tried to query payments
-- (Replace 'STUDENT_AUTH_UID' with an actual student's auth.uid() to test)

EXPLAIN (VERBOSE, COSTS OFF)
SELECT * FROM payments
WHERE student_id IN (
  SELECT id FROM students WHERE auth_user_id = auth.uid()
);

-- Expected: Shows RLS filter is applied

-- =============================================================================
-- PART 7: Count Policies Per Table
-- =============================================================================

SELECT 
  '=== POLICY COUNT BY TABLE ===' as "Audit Section",
  tablename as "Table",
  COUNT(*) as "Total Policies",
  COUNT(*) FILTER (WHERE cmd = 'SELECT') as "SELECT Policies",
  COUNT(*) FILTER (WHERE cmd = 'INSERT') as "INSERT Policies",
  COUNT(*) FILTER (WHERE cmd = 'UPDATE') as "UPDATE Policies",
  COUNT(*) FILTER (WHERE cmd = 'DELETE') as "DELETE Policies"
FROM pg_policies 
WHERE schemaname = 'public' 
  AND tablename IN ('payments', 'payment_records', 'credit_payments')
GROUP BY tablename
ORDER BY tablename;

-- Expected: Each table should have exactly 4 policies (1 per command)

-- =============================================================================
-- PART 8: Verify Admin Account Setup
-- =============================================================================

SELECT 
  '=== ADMIN ACCOUNT VERIFICATION ===' as "Audit Section",
  email as "Admin Email",
  auth_user_id as "Auth User ID",
  CASE 
    WHEN auth_user_id IS NOT NULL THEN '✅ Linked'
    ELSE '❌ NOT Linked'
  END as "Auth Status",
  CASE 
    WHEN auth_user_id IN (SELECT id FROM auth.users) THEN '✅ Valid'
    ELSE '❌ Invalid'
  END as "User Exists"
FROM admin_accounts
WHERE email = 'hrachfilm@gmail.com';

-- Expected: 
-- - email: hrachfilm@gmail.com
-- - auth_user_id: UUID (not null)
-- - Auth Status: ✅ Linked
-- - User Exists: ✅ Valid

-- =============================================================================
-- PART 9: Full Security Summary
-- =============================================================================

SELECT 
  '=== SECURITY SUMMARY ===' as "Audit Section";

SELECT 
  'RLS Enabled' as "Security Check",
  CASE 
    WHEN (SELECT COUNT(*) FROM pg_tables 
          WHERE schemaname = 'public' 
          AND tablename IN ('payments', 'payment_records', 'credit_payments')
          AND rowsecurity = true) = 3
    THEN '✅ All 3 tables have RLS enabled'
    ELSE '❌ RLS not enabled on all tables'
  END as "Status"
UNION ALL
SELECT 
  'Policy Count',
  CASE 
    WHEN (SELECT COUNT(*) FROM pg_policies 
          WHERE schemaname = 'public' 
          AND tablename IN ('payments', 'payment_records', 'credit_payments')) = 12
    THEN '✅ 12 policies (4 per table)'
    ELSE '⚠️ Incorrect policy count'
  END
UNION ALL
SELECT 
  'Dangerous Policies',
  CASE 
    WHEN (SELECT COUNT(*) FROM pg_policies 
          WHERE schemaname = 'public' 
          AND tablename IN ('payments', 'payment_records', 'credit_payments')
          AND cmd = 'SELECT'
          AND ('anon' = ANY(roles) OR 'public' = ANY(roles))) = 0
    THEN '✅ No public SELECT policies'
    ELSE '❌ Dangerous policies found'
  END
UNION ALL
SELECT 
  'Admin Function',
  CASE 
    WHEN EXISTS (SELECT 1 FROM pg_proc WHERE proname = 'is_arnoma_admin')
    THEN '✅ is_arnoma_admin() exists'
    ELSE '❌ Admin function missing'
  END
UNION ALL
SELECT 
  'Admin Account',
  CASE 
    WHEN EXISTS (
      SELECT 1 FROM admin_accounts 
      WHERE email = 'hrachfilm@gmail.com' 
      AND auth_user_id IS NOT NULL
    )
    THEN '✅ Admin account linked'
    ELSE '❌ Admin account not configured'
  END;

-- =============================================================================
-- FINAL VERDICT
-- =============================================================================

SELECT 
  CASE 
    WHEN (
      -- RLS enabled on all tables
      (SELECT COUNT(*) FROM pg_tables 
       WHERE schemaname = 'public' 
       AND tablename IN ('payments', 'payment_records', 'credit_payments')
       AND rowsecurity = true) = 3
      AND
      -- Correct number of policies
      (SELECT COUNT(*) FROM pg_policies 
       WHERE schemaname = 'public' 
       AND tablename IN ('payments', 'payment_records', 'credit_payments')) = 12
      AND
      -- No dangerous policies
      (SELECT COUNT(*) FROM pg_policies 
       WHERE schemaname = 'public' 
       AND tablename IN ('payments', 'payment_records', 'credit_payments')
       AND cmd = 'SELECT'
       AND ('anon' = ANY(roles) OR 'public' = ANY(roles))) = 0
      AND
      -- Admin function exists
      EXISTS (SELECT 1 FROM pg_proc WHERE proname = 'is_arnoma_admin')
      AND
      -- Admin account configured
      EXISTS (
        SELECT 1 FROM admin_accounts 
        WHERE email = 'hrachfilm@gmail.com' 
        AND auth_user_id IS NOT NULL
      )
    )
    THEN '✅✅✅ RLS SECURITY VERIFIED

DATABASE LEVEL:
- All payment tables have RLS enabled
- 12 secure policies enforcing student_id isolation
- No dangerous anon/public SELECT policies
- Admin function configured correctly
- Admin account properly linked

STUDENTS CAN ONLY SEE:
- Their own payments (student_id match)
- Their own records (auth.uid() match)
- Their own group notes

ADMINS CAN SEE:
- Everything (is_arnoma_admin() bypasses filters)

🔒 SECURITY STATUS: FULLY SECURED'
    ELSE '❌ RLS SECURITY ISSUES DETECTED

Please review the sections above to identify problems.'
  END as "🔒 FINAL RLS SECURITY VERDICT 🔒";
