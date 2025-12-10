-- ========================================
-- COMPREHENSIVE RLS POLICY AUDIT
-- ========================================
-- This will show ALL policies across ALL tables in your database

-- ============================================================
-- PART 1: All Policies (Grouped by Table)
-- ============================================================
SELECT 
  schemaname,
  tablename,
  policyname,
  permissive,
  roles,
  cmd,
  qual::text as using_clause,
  with_check::text as with_check_clause
FROM pg_policies
WHERE schemaname = 'public'
ORDER BY tablename, cmd, policyname;

-- ============================================================
-- PART 2: Count Policies Per Table
-- ============================================================
SELECT 
  tablename,
  COUNT(*) as policy_count,
  array_agg(DISTINCT cmd ORDER BY cmd) as operations_covered
FROM pg_policies
WHERE schemaname = 'public'
GROUP BY tablename
ORDER BY policy_count DESC, tablename;

-- ============================================================
-- PART 3: Tables with RLS Enabled
-- ============================================================
SELECT 
  schemaname,
  tablename,
  rowsecurity as rls_enabled
FROM pg_tables
WHERE schemaname = 'public'
  AND rowsecurity = true
ORDER BY tablename;

-- ============================================================
-- PART 4: Policies That Query auth.users (PROBLEMATIC!)
-- ============================================================
SELECT 
  tablename,
  policyname,
  cmd,
  qual::text as using_clause
FROM pg_policies
WHERE schemaname = 'public'
  AND (
    qual::text LIKE '%auth.users%' 
    OR with_check::text LIKE '%auth.users%'
  )
ORDER BY tablename, policyname;

-- ============================================================
-- PART 5: Overlapping Policies (Same table + Same operation)
-- ============================================================
SELECT 
  tablename,
  cmd,
  COUNT(*) as num_policies,
  array_agg(policyname) as policy_names
FROM pg_policies
WHERE schemaname = 'public'
GROUP BY tablename, cmd
HAVING COUNT(*) > 1
ORDER BY num_policies DESC, tablename, cmd;

-- ============================================================
-- PART 6: Admin Accounts (Who Has Access?)
-- ============================================================
SELECT 
  auth_user_id,
  email
FROM admin_accounts;

-- ============================================================
-- PART 7: Check if is_arnoma_admin() Function Exists
-- ============================================================
SELECT 
  proname as function_name,
  prosrc as function_body
FROM pg_proc 
WHERE proname = 'is_arnoma_admin';
