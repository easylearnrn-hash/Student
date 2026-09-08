-- ============================================================
-- FIX: One-time cross-group class students (Calendar "Add Student")
--      cannot see notes posted to the OTHER group's class date.
--
-- ROOT CAUSE: student_note_permissions / note_free_access / student_notes
-- SELECT policies only allow a student to see group-wide rows where
-- group_name/group_letter matches their OWN home group. There is no
-- clause for a one-time enrollment into a different group.
--
-- SAFETY: This is STRICTLY ADDITIVE. Every existing OR-branch below is
-- copied byte-for-byte from the currently live policies (verified against
-- FIX-LUSINE-NOTES-COMPLETE.sql STEP 1 for student_note_permissions, and
-- FIX-NEW-STUDENT-NO-RETROACTIVE-ACCESS.sql for note_free_access and
-- student_notes — the most recently applied versions of each). Only ONE
-- new OR-branch is appended per policy. No existing access path is
-- removed, narrowed, or reordered, so no student who currently has access
-- loses it. The new branch only ADDS visibility, and only when a real
-- payment_records row proves the student was manually enrolled
-- (payment_method='manual_enrollment') into that exact group for that
-- exact class_date. It does NOT bypass the payment lock — that stays
-- enforced client-side in student-portal.html / Protected-PDF-Viewer.html
-- exactly as before, so unpaid one-time students still see the note
-- LOCKED, never unlocked, by this change alone.
--
-- Run in Supabase SQL Editor. Idempotent — safe to run multiple times.
-- ============================================================

BEGIN;

-- ============================================================
-- STEP 1: student_note_permissions SELECT policy
-- ============================================================
DROP POLICY IF EXISTS "Students can read own permissions" ON student_note_permissions;

CREATE POLICY "Students can read own permissions"
ON student_note_permissions FOR SELECT
TO authenticated
USING (
  -- (unchanged) Individual rows assigned to this specific student
  student_id IN (
    SELECT id
    FROM students
    WHERE auth_user_id = auth.uid()
       OR lower(trim(email)) = lower(trim(auth.jwt() ->> 'email'))
  )
  OR
  -- (unchanged) Group-wide rows (student_id IS NULL) — match any format: "E" or "Group E"
  (
    student_id IS NULL
    AND (
      group_name IN (
        SELECT group_name
        FROM students
        WHERE auth_user_id = auth.uid()
           OR lower(trim(email)) = lower(trim(auth.jwt() ->> 'email'))
      )
      OR
      group_name IN (
        SELECT REPLACE(group_name, 'Group ', '')
        FROM students
        WHERE auth_user_id = auth.uid()
           OR lower(trim(email)) = lower(trim(auth.jwt() ->> 'email'))
      )
      OR
      group_name IN (
        SELECT 'Group ' || REPLACE(group_name, 'Group ', '')
        FROM students
        WHERE auth_user_id = auth.uid()
           OR lower(trim(email)) = lower(trim(auth.jwt() ->> 'email'))
      )
    )
  )
  OR
  -- NEW: one-time cross-group class (Calendar "Add Student"). Group-wide row
  -- only, visible when a payment_records manual_enrollment row proves this
  -- student was added to this exact group for this exact class_date.
  -- Paid or not — visibility only; payment lock stays client-side.
  (
    student_id IS NULL
    AND class_date IS NOT NULL
    AND EXISTS (
      SELECT 1
      FROM payment_records pr
      INNER JOIN students s
        ON  s.auth_user_id = auth.uid()
         OR lower(trim(s.email)) = lower(trim(auth.jwt() ->> 'email'))
      WHERE pr.student_id = s.id
        AND lower(trim(pr.payment_method)) = 'manual_enrollment'
        AND pr.notes IS NOT NULL
        AND upper(regexp_replace(trim(pr.notes), '^[Gg]roup\s*', ''))
          = upper(regexp_replace(trim(student_note_permissions.group_name), '^[Gg]roup\s*', ''))
        AND pr.date = student_note_permissions.class_date
    )
  )
  OR
  -- (unchanged) Admin bypass
  is_arnoma_admin()
);

-- ============================================================
-- STEP 2: note_free_access SELECT policy
-- ============================================================
DROP POLICY IF EXISTS "Students can view free access" ON note_free_access;

CREATE POLICY "Students can view free access"
ON note_free_access FOR SELECT
TO public
USING (
  -- (unchanged) Individual grant — no date restriction
  (
    access_type = 'individual'
    AND student_id IN (
      SELECT id FROM students
      WHERE auth_user_id = auth.uid()
         OR lower(trim(email)) = lower(trim(auth.jwt() ->> 'email'))
    )
  )
  OR
  -- (unchanged) Group grant — only if student existed before the grant was created
  (
    access_type = 'group'
    AND group_letter IN (
      SELECT upper(regexp_replace(coalesce(group_name, ''), '^[Gg]roup\s*', ''))
      FROM students
      WHERE (
        auth_user_id = auth.uid()
        OR lower(trim(email)) = lower(trim(auth.jwt() ->> 'email'))
      )
      AND created_at <= note_free_access.created_at
    )
  )
  OR
  -- NEW: one-time cross-group class free-access grant, visible when the
  -- student has a matching manual_enrollment for this exact group + class_date.
  (
    access_type = 'group'
    AND class_date IS NOT NULL
    AND EXISTS (
      SELECT 1
      FROM payment_records pr
      INNER JOIN students s
        ON  s.auth_user_id = auth.uid()
         OR lower(trim(s.email)) = lower(trim(auth.jwt() ->> 'email'))
      WHERE pr.student_id = s.id
        AND lower(trim(pr.payment_method)) = 'manual_enrollment'
        AND pr.notes IS NOT NULL
        AND upper(regexp_replace(trim(pr.notes), '^[Gg]roup\s*', ''))
          = upper(regexp_replace(trim(note_free_access.group_letter), '^[Gg]roup\s*', ''))
        AND pr.date = note_free_access.class_date
    )
  )
  OR
  -- (unchanged) Admin bypass
  is_arnoma_admin()
);

-- ============================================================
-- STEP 3: student_notes SELECT policy
-- ============================================================
DROP POLICY IF EXISTS "Students can view accessible notes" ON student_notes;

CREATE POLICY "Students can view accessible notes"
ON student_notes FOR SELECT
TO public
USING (
  deleted = false
  AND (
    -- (unchanged, a) Individual free-access grant — explicit, no date guard
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

    -- (unchanged, b) Group free-access grant — student must have joined BEFORE access was granted
    id IN (
      SELECT nfa.note_id
      FROM note_free_access nfa
      INNER JOIN students s
        ON  s.auth_user_id = auth.uid()
         OR lower(trim(s.email)) = lower(trim(auth.jwt() ->> 'email'))
      WHERE nfa.access_type = 'group'
        AND nfa.group_letter = upper(regexp_replace(coalesce(s.group_name, ''), '^[Gg]roup\s*', ''))
        AND s.created_at <= nfa.created_at
    )

    OR

    -- (unchanged, c) student_note_permissions — individual explicit access, no date guard
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

    -- (unchanged, c2) student_note_permissions — group-level access, retroactive guard
    EXISTS (
      SELECT 1
      FROM student_note_permissions snp
      INNER JOIN students s
        ON  s.auth_user_id = auth.uid()
         OR lower(trim(s.email)) = lower(trim(auth.jwt() ->> 'email'))
      WHERE snp.note_id = student_notes.id
        AND snp.is_accessible = true
        AND snp.student_id IS NULL
        AND upper(regexp_replace(coalesce(snp.group_name, ''), '^[Gg]roup\s*', ''))
          = upper(regexp_replace(coalesce(s.group_name, ''), '^[Gg]roup\s*', ''))
        AND s.created_at <= student_notes.created_at
    )

    OR

    -- NEW (e): one-time cross-group class — group-level permission row whose
    -- class_date matches a manual_enrollment for that exact group. No join-date
    -- guard here (it's a one-off class visit, not ongoing group membership).
    EXISTS (
      SELECT 1
      FROM student_note_permissions snp
      INNER JOIN students s
        ON  s.auth_user_id = auth.uid()
         OR lower(trim(s.email)) = lower(trim(auth.jwt() ->> 'email'))
      INNER JOIN payment_records pr
        ON  pr.student_id = s.id
        AND lower(trim(pr.payment_method)) = 'manual_enrollment'
        AND pr.notes IS NOT NULL
        AND upper(regexp_replace(trim(pr.notes), '^[Gg]roup\s*', ''))
          = upper(regexp_replace(coalesce(snp.group_name, ''), '^[Gg]roup\s*', ''))
        AND pr.date = snp.class_date
      WHERE snp.note_id = student_notes.id
        AND snp.is_accessible = true
        AND snp.student_id IS NULL
    )

    OR

    -- (unchanged, d) Admin bypass
    is_arnoma_admin()
  )
);

COMMIT;

-- ============================================================
-- VERIFICATION (read-only — safe to run anytime)
-- ============================================================
-- Confirm all three policies exist and are attached to the right tables/roles:
SELECT tablename, policyname, roles, cmd
FROM pg_policies
WHERE schemaname = 'public'
  AND tablename IN ('student_note_permissions', 'note_free_access', 'student_notes')
  AND policyname IN (
    'Students can read own permissions',
    'Students can view free access',
    'Students can view accessible notes'
  )
ORDER BY tablename;

-- ============================================================
-- ROLLBACK (only if this causes an unexpected issue):
-- Re-run the CREATE POLICY blocks above but delete the three
-- "-- NEW" branches (and their preceding "OR") to restore the
-- exact pre-existing behavior. Nothing else needs to change.
-- ============================================================
