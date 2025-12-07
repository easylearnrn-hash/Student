-- Fix RLS policies for student_absences and skipped_classes tables
-- Student portal needs read access to calculate unpaid classes correctly

-- ============================================
-- 1. STUDENT_ABSENCES TABLE
-- ============================================

-- Drop existing policies if any
DROP POLICY IF EXISTS "Students can view their own absences" ON student_absences;
DROP POLICY IF EXISTS "Allow students to view their absences" ON student_absences;
DROP POLICY IF EXISTS "Students read their absences" ON student_absences;

-- Enable RLS
ALTER TABLE student_absences ENABLE ROW LEVEL SECURITY;

-- Create new read policy for students (via students table lookup)
CREATE POLICY "Students can read their own absences"
ON student_absences
FOR SELECT
USING (
  student_id IN (
    SELECT id FROM students 
    WHERE auth_user_id = auth.uid()
  )
);

-- Admin access (full control)
DROP POLICY IF EXISTS "Admins can manage all absences" ON student_absences;
CREATE POLICY "Admins can manage all absences"
ON student_absences
FOR ALL
USING (
  auth.uid() IN (
    SELECT auth_user_id FROM admin_accounts WHERE is_active = true
  )
);

-- ============================================
-- 2. SKIPPED_CLASSES TABLE
-- ============================================

-- Drop existing policies if any
DROP POLICY IF EXISTS "Students can view skipped classes" ON skipped_classes;
DROP POLICY IF EXISTS "Allow students to view skipped classes" ON skipped_classes;
DROP POLICY IF EXISTS "Students read skipped classes" ON skipped_classes;

-- Enable RLS
ALTER TABLE skipped_classes ENABLE ROW LEVEL SECURITY;

-- Create read policy for students (via students table lookup)
-- Students need to see cancelled classes for their group
CREATE POLICY "Students can read their group skipped classes"
ON skipped_classes
FOR SELECT
USING (
  group_name IN (
    SELECT COALESCE(group_name, "group") 
    FROM students 
    WHERE auth_user_id = auth.uid()
  )
);

-- Admin access (full control)
DROP POLICY IF EXISTS "Admins can manage all skipped classes" ON skipped_classes;
CREATE POLICY "Admins can manage all skipped classes"
ON skipped_classes
FOR ALL
USING (
  auth.uid() IN (
    SELECT auth_user_id FROM admin_accounts WHERE is_active = true
  )
);

-- ============================================
-- 3. VERIFICATION QUERIES
-- ============================================

-- Check policies are active
SELECT schemaname, tablename, policyname, permissive, roles, cmd, qual
FROM pg_policies
WHERE tablename IN ('student_absences', 'skipped_classes')
ORDER BY tablename, policyname;

-- Verify student can see their data (replace with actual student auth_user_id)
-- SELECT * FROM student_absences WHERE student_id IN (
--   SELECT id FROM students WHERE auth_user_id = 'c7b21994-a096-4f16-949b-70548ef6a961'
-- );

-- SELECT * FROM skipped_classes WHERE group_name IN (
--   SELECT COALESCE(group_name, "group") FROM students WHERE auth_user_id = 'c7b21994-a096-4f16-949b-70548ef6a961'
-- );
