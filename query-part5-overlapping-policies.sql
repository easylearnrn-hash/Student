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
