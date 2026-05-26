-- ============================================================
-- FIX: New students should NOT see notes that were opened
--      (free for group OR group-accessible) BEFORE they joined.
--
-- Rule: Group-level access only applies to students who existed
--       at the time the access was granted. Individual explicit
--       access (purchased or admin-granted) is unaffected.
--
-- Run in Supabase SQL Editor.
-- ============================================================

-- 1. Ensure created_at exists on note_free_access (idempotent)
ALTER TABLE note_free_access
  ADD COLUMN IF NOT EXISTS created_at TIMESTAMPTZ DEFAULT NOW();

-- 2. Ensure created_at exists on student_note_permissions (idempotent)
ALTER TABLE student_note_permissions
  ADD COLUMN IF NOT EXISTS created_at TIMESTAMPTZ DEFAULT NOW();

-- 3. Drop the current student SELECT policy on student_notes
DROP POLICY IF EXISTS "Students can view accessible notes" ON student_notes;

-- 4. Recreate policy with retroactive-access guard on all group-level paths.
--
--    Path (a)  Individual free-access grant          → no date restriction
--    Path (b)  Group free-access grant               → student.created_at <= nfa.created_at
--    Path (c)  student_note_permissions (individual)  → no date restriction
--    Path (c2) student_note_permissions (group-level) → student.created_at <= snp.created_at
--    Path (d)  Admin bypass                           → always
--
CREATE POLICY "Students can view accessible notes"
ON student_notes FOR SELECT
TO public
USING (
  deleted = false
  AND (
    -- (a) Individual free-access grant — explicit, no date guard
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

    -- (b) Group free-access grant — student must have joined BEFORE access was granted
    id IN (
      SELECT nfa.note_id
      FROM note_free_access nfa
      INNER JOIN students s
        ON  s.auth_user_id = auth.uid()
         OR lower(trim(s.email)) = lower(trim(auth.jwt() ->> 'email'))
      WHERE nfa.access_type = 'group'
        AND nfa.group_letter = upper(regexp_replace(coalesce(s.group_name, ''), '^[Gg]roup\s*', ''))
        AND s.created_at <= nfa.created_at   -- ← NEW: blocks students who joined after the grant
    )

    OR

    -- (c) student_note_permissions — individual explicit access, no date guard
    id IN (
      SELECT snp.note_id
      FROM student_note_permissions snp
      INNER JOIN students s
        ON  s.auth_user_id = auth.uid()
         OR lower(trim(s.email)) = lower(trim(auth.jwt() ->> 'email'))
      WHERE snp.is_accessible = true
        AND snp.student_id = s.id
    )

    OR

    -- (c2) student_note_permissions — group-level access.
    --      Uses student_notes.created_at (when the note was uploaded) as the cutoff date,
    --      because student_note_permissions.created_at is unreliable (column added after the fact,
    --      so all existing rows share the same DEFAULT NOW() timestamp).
    --      Rule: student must have joined BEFORE the note was uploaded to the system.
    EXISTS (
      SELECT 1
      FROM student_note_permissions snp
      INNER JOIN students s
        ON  s.auth_user_id = auth.uid()
         OR lower(trim(s.email)) = lower(trim(auth.jwt() ->> 'email'))
      WHERE snp.note_id = student_notes.id           -- reference the current note row
        AND snp.is_accessible = true
        AND snp.student_id IS NULL
        AND upper(regexp_replace(coalesce(snp.group_name, ''), '^[Gg]roup\s*', ''))
          = upper(regexp_replace(coalesce(s.group_name, ''), '^[Gg]roup\s*', ''))
        AND s.created_at <= student_notes.created_at -- ← student existed before note was uploaded
    )

    OR

    -- (d) Admin bypass
    is_arnoma_admin()
  )
);

-- 5. Also update the note_free_access SELECT policy so new students
--    cannot even see group-level grants they have no right to act on.
DROP POLICY IF EXISTS "Students can view free access" ON note_free_access;
DROP POLICY IF EXISTS "Students view free access"     ON note_free_access;

CREATE POLICY "Students can view free access"
ON note_free_access FOR SELECT
TO public
USING (
  -- Individual grant: only this student's own grants (no date restriction)
  (
    access_type = 'individual'
    AND student_id IN (
      SELECT id FROM students
      WHERE auth_user_id = auth.uid()
         OR lower(trim(email)) = lower(trim(auth.jwt() ->> 'email'))
    )
  )
  OR
  -- Group grant: only if student existed before the grant was created
  (
    access_type = 'group'
    AND group_letter IN (
      SELECT upper(regexp_replace(coalesce(group_name, ''), '^[Gg]roup\s*', ''))
      FROM students
      WHERE (
        auth_user_id = auth.uid()
        OR lower(trim(email)) = lower(trim(auth.jwt() ->> 'email'))
      )
      AND created_at <= note_free_access.created_at  -- ← student joined before grant
    )
  )
  OR
  is_arnoma_admin()
);
