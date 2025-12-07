-- Clean up overly permissive RLS policies
-- Keep only the secure student + admin policies

-- ============================================
-- REMOVE INSECURE PUBLIC POLICIES
-- ============================================

-- Remove public access policies from skipped_classes
DROP POLICY IF EXISTS "Public can delete skipped classes" ON skipped_classes;
DROP POLICY IF EXISTS "Public can insert skipped classes" ON skipped_classes;
DROP POLICY IF EXISTS "Public can select skipped_classes" ON skipped_classes;
DROP POLICY IF EXISTS "Public can update skipped classes" ON skipped_classes;
DROP POLICY IF EXISTS "auth_only_skipped_classes" ON skipped_classes;

-- Remove public access policies from student_absences
DROP POLICY IF EXISTS "Allow public delete access" ON student_absences;
DROP POLICY IF EXISTS "Allow public insert access" ON student_absences;
DROP POLICY IF EXISTS "Allow public read access" ON student_absences;
DROP POLICY IF EXISTS "Allow public update access" ON student_absences;
DROP POLICY IF EXISTS "auth_only_student_absences" ON student_absences;

-- Remove duplicate policies (these are redundant with our new policies)
DROP POLICY IF EXISTS "student_absences_select_admin_or_owner" ON student_absences;
DROP POLICY IF EXISTS "student_absences_write_admin_only" ON student_absences;

-- ============================================
-- VERIFY ONLY SECURE POLICIES REMAIN
-- ============================================

-- Should show only 4 policies total:
-- 1. Students can read their own absences
-- 2. Admins can manage all absences
-- 3. Students can read their group skipped classes
-- 4. Admins can manage all skipped classes

SELECT schemaname, tablename, policyname, roles, cmd
FROM pg_policies
WHERE tablename IN ('student_absences', 'skipped_classes')
ORDER BY tablename, policyname;
