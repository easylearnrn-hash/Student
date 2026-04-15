-- ============================================================
-- FIX ALL NOTES ACCESS — COMPLETE IDEMPOTENT PATCH
-- Run this once in Supabase SQL Editor → will fix Lusine and all students
-- Safe to run multiple times (uses DROP IF EXISTS + CREATE)
-- ============================================================
-- Fixes three layers:
--   1. student_note_permissions RLS  → group rows (student_id IS NULL) now visible
--   2. note_free_access RLS          → group rows (access_type='group') now visible
--   3. student_notes RLS             → actual note records visible via permission tables
--   4. class_date column             → add to note_free_access if missing
-- ============================================================

BEGIN;

-- ============================================================
-- STEP 0: Add missing class_date column to note_free_access
-- ============================================================
ALTER TABLE note_free_access
  ADD COLUMN IF NOT EXISTS class_date DATE;

-- ============================================================
-- STEP 1: FIX student_note_permissions SELECT policy
-- Handles "E" / "Group E" group_name format mismatch
-- ============================================================
DROP POLICY IF EXISTS "Students can read own permissions" ON student_note_permissions;
DROP POLICY IF EXISTS "Students can read their own permissions" ON student_note_permissions;
DROP POLICY IF EXISTS "Authenticated can manage permissions" ON student_note_permissions;

CREATE POLICY "Students can read own permissions"
ON student_note_permissions FOR SELECT
TO authenticated
USING (
  -- Individual rows assigned to this specific student
  student_id IN (
    SELECT id FROM students WHERE auth_user_id = auth.uid()
  )
  OR
  -- Group-wide rows (student_id IS NULL) — match any format: "E" or "Group E"
  (
    student_id IS NULL
    AND (
      group_name IN (
        SELECT group_name FROM students WHERE auth_user_id = auth.uid()
      )
      OR
      group_name IN (
        SELECT REPLACE(group_name, 'Group ', '') FROM students WHERE auth_user_id = auth.uid()
      )
      OR
      group_name IN (
        SELECT 'Group ' || REPLACE(group_name, 'Group ', '') FROM students WHERE auth_user_id = auth.uid()
      )
    )
  )
  OR
  is_arnoma_admin()
);

-- ============================================================
-- STEP 2: FIX note_free_access SELECT policy
-- ============================================================
DROP POLICY IF EXISTS "Students can view free access" ON note_free_access;
DROP POLICY IF EXISTS "Students view free access" ON note_free_access;
DROP POLICY IF EXISTS "Public can view free access" ON note_free_access;
DROP POLICY IF EXISTS "Allow anon read" ON note_free_access;

CREATE POLICY "Students can view free access"
ON note_free_access FOR SELECT
TO public
USING (
  -- Individual access for this specific student
  student_id IN (
    SELECT id FROM students WHERE auth_user_id = auth.uid()
  )
  OR
  -- Group access: match any format "E" or "Group E"
  (
    access_type = 'group'
    AND group_letter IN (
      SELECT REPLACE(REPLACE(group_name, 'Group ', ''), 'group ', '')
      FROM students
      WHERE auth_user_id = auth.uid()
    )
  )
  OR
  is_arnoma_admin()
);

-- ============================================================
-- STEP 3: FIX student_notes SELECT policy
-- student_notes.group_name = system folder name ("Maternal Health"),
-- NOT the group letter — so we must check permission tables, not group_name directly
-- ============================================================
DROP POLICY IF EXISTS "Auth students can view own notes" ON student_notes;
DROP POLICY IF EXISTS "Students can view accessible notes" ON student_notes;
DROP POLICY IF EXISTS "allow_anon_read_non_deleted" ON student_notes;
DROP POLICY IF EXISTS "Students can view notes for their group" ON student_notes;
DROP POLICY IF EXISTS "Admin full access to notes" ON student_notes;
DROP POLICY IF EXISTS "Admins have full access to notes" ON student_notes;

CREATE POLICY "Students can view accessible notes"
ON student_notes FOR SELECT
TO public
USING (
  deleted = false
  AND (
    -- Check 1: in note_free_access for this student individually OR by group
    id IN (
      SELECT nfa.note_id
      FROM note_free_access nfa
      LEFT JOIN students s ON s.auth_user_id = auth.uid()
      WHERE (
        (nfa.access_type = 'individual' AND nfa.student_id = s.id)
        OR
        (nfa.access_type = 'group'
          AND nfa.group_letter = REPLACE(REPLACE(s.group_name, 'Group ', ''), 'group ', ''))
      )
    )
    OR
    -- Check 2: in student_note_permissions for this student OR this student's group
    id IN (
      SELECT snp.note_id
      FROM student_note_permissions snp
      LEFT JOIN students s ON s.auth_user_id = auth.uid()
      WHERE snp.is_accessible = true
        AND (
          snp.student_id = s.id
          OR
          (snp.student_id IS NULL AND (
            snp.group_name = s.group_name
            OR snp.group_name = REPLACE(s.group_name, 'Group ', '')
            OR snp.group_name = 'Group ' || REPLACE(s.group_name, 'Group ', '')
          ))
        )
    )
    OR
    is_arnoma_admin()
  )
);

CREATE POLICY "Admins have full access to notes"
ON student_notes FOR ALL
TO authenticated
USING (is_arnoma_admin())
WITH CHECK (is_arnoma_admin());

-- ============================================================
-- VERIFICATION — these will return results you can inspect
-- ============================================================
SELECT tablename, policyname, roles, cmd
FROM pg_policies
WHERE schemaname = 'public'
  AND tablename IN ('student_note_permissions', 'note_free_access', 'student_notes')
ORDER BY tablename, policyname;

COMMIT;
