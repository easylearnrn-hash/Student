-- ============================================================
-- FIX: Individual Free Access for student_notes
-- Run this in Supabase SQL Editor if students can't see notes
-- that were individually granted via the 🎁 FREE → Individual flow.
-- ============================================================

-- 1. Drop all existing SELECT policies on student_notes
DROP POLICY IF EXISTS "Students can view accessible notes"      ON student_notes;
DROP POLICY IF EXISTS "Students view their group notes"         ON student_notes;
DROP POLICY IF EXISTS "Auth students can view own notes"        ON student_notes;
DROP POLICY IF EXISTS "Students can view notes for their group" ON student_notes;
DROP POLICY IF EXISTS "allow_anon_read_non_deleted"             ON student_notes;
DROP POLICY IF EXISTS "Admin full access to notes"              ON student_notes;
DROP POLICY IF EXISTS "Admins have full access to notes"        ON student_notes;

-- 2. Recreate the student SELECT policy.
--    Students can see notes if ANY of the following is true:
--    a) They have an individual free-access grant in note_free_access
--    b) Their group has a group-level free-access grant in note_free_access
--    c) They have a visible (is_accessible=true) entry in student_note_permissions
--       either directly for them or for their group
--    d) They are an admin
CREATE POLICY "Students can view accessible notes"
ON student_notes FOR SELECT
TO public
USING (
  deleted = false
  AND (
    -- (a) Individual free access grant
    id IN (
      SELECT nfa.note_id
      FROM note_free_access nfa
      INNER JOIN students s
        ON  s.auth_user_id = auth.uid()
         OR lower(trim(s.email)) = lower(trim(auth.jwt() ->> 'email'))
      WHERE nfa.access_type = 'individual'
        AND nfa.student_id = s.id
    )
    OR
    -- (b) Group free access grant
    id IN (
      SELECT nfa.note_id
      FROM note_free_access nfa
      INNER JOIN students s
        ON  s.auth_user_id = auth.uid()
         OR lower(trim(s.email)) = lower(trim(auth.jwt() ->> 'email'))
      WHERE nfa.access_type = 'group'
        AND nfa.group_letter = upper(regexp_replace(coalesce(s.group_name,''), '^[Gg]roup\s*', ''))
    )
    OR
    -- (c) student_note_permissions (group-level or individual)
    id IN (
      SELECT snp.note_id
      FROM student_note_permissions snp
      INNER JOIN students s
        ON  s.auth_user_id = auth.uid()
         OR lower(trim(s.email)) = lower(trim(auth.jwt() ->> 'email'))
      WHERE snp.is_accessible = true
        AND (
          snp.student_id = s.id
          OR (
            snp.student_id IS NULL
            AND upper(regexp_replace(coalesce(snp.group_name,''), '^[Gg]roup\s*', ''))
              = upper(regexp_replace(coalesce(s.group_name,''), '^[Gg]roup\s*', ''))
          )
        )
    )
    OR
    -- (d) Admin bypass
    is_arnoma_admin()
  )
);

-- 3. Recreate admin full-access policy
DROP POLICY IF EXISTS "Admins have full access to notes" ON student_notes;
CREATE POLICY "Admins have full access to notes"
ON student_notes FOR ALL
TO authenticated
USING (is_arnoma_admin())
WITH CHECK (is_arnoma_admin());

-- 4. Ensure note_free_access SELECT policy is also correct
DROP POLICY IF EXISTS "Students can view free access" ON note_free_access;
DROP POLICY IF EXISTS "Students view free access"     ON note_free_access;

CREATE POLICY "Students can view free access"
ON note_free_access FOR SELECT
TO public
USING (
  -- Individual: only this student's own grants
  (
    access_type = 'individual'
    AND student_id IN (
      SELECT id FROM students
      WHERE auth_user_id = auth.uid()
         OR lower(trim(email)) = lower(trim(auth.jwt() ->> 'email'))
    )
  )
  OR
  -- Group: grants for this student's group
  (
    access_type = 'group'
    AND group_letter IN (
      SELECT upper(regexp_replace(coalesce(group_name,''), '^[Gg]roup\s*', ''))
      FROM students
      WHERE auth_user_id = auth.uid()
         OR lower(trim(email)) = lower(trim(auth.jwt() ->> 'email'))
    )
  )
  OR
  is_arnoma_admin()
);
