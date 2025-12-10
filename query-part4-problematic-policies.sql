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
