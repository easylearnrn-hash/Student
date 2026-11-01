-- ============================================================
-- ⚠️ TESTED ON PRODUCTION 2026-11-01 — DOES NOT FIX THE SLOWNESS. DO NOT RUN EXPECTING A SPEED-UP.
--   Applied, A/B timed with the portal's real queries as a real student, then rolled back:
--     student_notes (85 rows)   6.3 s  ->  6.2 s   (no change)
--     other note queries        unchanged;  admin DB time ~10% better (0.72 s -> 0.65 s)
--   Row-level access was identical before/after for 25 sampled principals (admin, anon, 23 students),
--   so it is safe, just pointless. The cause is NOT these three policies. It is that every student-side
--   subquery scans `students` once per row (hundreds of times), and the `students` table's own access
--   rules call the VOLATILE plpgsql function is_arnoma_admin() several times per row. Fixing that means
--   changing the policies/function on `students` (and likely `payment_records`), not this file.
--   Restore the original policies with FIX-ONE-TIME-CROSS-GROUP-NOTE-ACCESS.sql if this was ever applied.
-- ============================================================
-- ============================================================
-- PERF FIX: student_notes / student_note_permissions / note_free_access
--           SELECT policies are slow (3-5 s per portal load).
--
-- MEASURED (real student login, client-side timings; other tables ~0.3 s):
--   student_note_permissions  count  ~2.7 s
--   note_free_access (group)  count  ~1.5 s
--   student_notes             any row ~4.0 s (it inherits the two above,
--                                      because policy sub-selects on those tables
--                                      are themselves filtered by THEIR policies)
--
-- LIKELY CAUSE (verify with STEP 0): the "one-time cross-group class" branch added by
-- FIX-ONE-TIME-CROSS-GROUP-NOTE-ACCESS.sql is a CORRELATED EXISTS that runs once per row,
-- each time joining students (OR on email) and payment_records (which has its own RLS).
-- auth.uid()/auth.jwt()/is_arnoma_admin() are also re-evaluated per row.
--
-- WHAT THIS CHANGES (access is meant to stay IDENTICAL, only the query shape changes):
--   1. The cross-group branch becomes an UNCORRELATED "(group, date) IN (my manual
--      enrollments)" set that Postgres computes ONCE per query instead of per row.
--      Same rule: a payment_records row with payment_method='manual_enrollment', whose
--      notes = the group and whose date = the class_date, for one of MY student rows.
--   2. auth.uid(), auth.jwt() and is_arnoma_admin() are wrapped in (SELECT ...) so they
--      are evaluated once per query (standard Supabase RLS performance guidance).
--   3. "my student ids" is expressed as  student_id IN (SELECT id FROM students ...)
--      instead of re-joining students inside every branch.
--   Every other OR-branch is copied from FIX-ONE-TIME-CROSS-GROUP-NOTE-ACCESS.sql.
--
-- NOT CHANGED: payment lock (stays client-side), admin bypass, table schemas, data.
-- ONLY ADDITIVE EXTRA: one optional index on students(lower(trim(email))) (STEP 1).
--
-- HOW TO USE (Supabase SQL Editor, in this order):
--   STEP 0  Confirm the live policies match FIX-ONE-TIME-CROSS-GROUP-NOTE-ACCESS.sql
--           (if they differ, STOP and send me the output — I will adapt this file).
--   STEP 0b (optional) EXPLAIN ANALYZE "before" for a record.
--   STEP 2  Run the policy block (it is one transaction; it either fully applies or not).
--   STEP 3  Re-run EXPLAIN, then test in the portal with a real student login AND an
--           admin impersonation. Compare notes shown / locked vs before.
--   ROLLBACK  Re-run FIX-ONE-TIME-CROSS-GROUP-NOTE-ACCESS.sql (restores the old policies).
-- ============================================================


-- ============================================================
-- STEP 0: dump the CURRENT policies and compare with
--         FIX-ONE-TIME-CROSS-GROUP-NOTE-ACCESS.sql (read-only)
-- ============================================================
SELECT tablename, policyname, cmd, roles, qual
FROM pg_policies
WHERE schemaname = 'public'
  AND tablename IN ('student_note_permissions', 'note_free_access', 'student_notes')
  AND cmd IN ('SELECT', 'ALL')
ORDER BY tablename, policyname;

-- Table sizes (tells us how much per-row work the old policy was doing)
SELECT 'student_notes' AS t, count(*) FROM student_notes
UNION ALL SELECT 'student_note_permissions', count(*) FROM student_note_permissions
UNION ALL SELECT 'note_free_access', count(*) FROM note_free_access
UNION ALL SELECT 'payment_records', count(*) FROM payment_records
UNION ALL SELECT 'students', count(*) FROM students;


-- ============================================================
-- STEP 0b (optional, read-only): time a query AS a student.
-- Replace the two placeholders, run the whole block, read the "Execution Time".
-- ============================================================
-- BEGIN;
-- SET LOCAL ROLE authenticated;
-- SELECT set_config(
--   'request.jwt.claims',
--   '{"sub":"<STUDENT_AUTH_USER_ID>","email":"<STUDENT_EMAIL>","role":"authenticated"}',
--   true);
-- EXPLAIN (ANALYZE, BUFFERS) SELECT id FROM student_notes LIMIT 50;
-- ROLLBACK;


-- ============================================================
-- STEP 1 (optional index): lets Postgres use an index for the email match
-- ============================================================
CREATE INDEX IF NOT EXISTS idx_students_email_norm ON students (lower(trim(email)));


-- ============================================================
-- STEP 2: the three policies (one transaction)
-- ============================================================
BEGIN;

-- ------------------------------------------------------------
-- student_note_permissions
-- ------------------------------------------------------------
DROP POLICY IF EXISTS "Students can read own permissions" ON student_note_permissions;

CREATE POLICY "Students can read own permissions"
ON student_note_permissions FOR SELECT
TO authenticated
USING (
  -- (unchanged) Individual rows assigned to this specific student
  student_id IN (
    SELECT id
    FROM students
    WHERE auth_user_id = (SELECT auth.uid())
       OR lower(trim(email)) = lower(trim((SELECT auth.jwt() ->> 'email')))
  )
  OR
  -- (unchanged) Group-wide rows (student_id IS NULL) — match "E", "Group E"
  (
    student_id IS NULL
    AND (
      group_name IN (
        SELECT group_name
        FROM students
        WHERE auth_user_id = (SELECT auth.uid())
           OR lower(trim(email)) = lower(trim((SELECT auth.jwt() ->> 'email')))
      )
      OR
      group_name IN (
        SELECT REPLACE(group_name, 'Group ', '')
        FROM students
        WHERE auth_user_id = (SELECT auth.uid())
           OR lower(trim(email)) = lower(trim((SELECT auth.jwt() ->> 'email')))
      )
      OR
      group_name IN (
        SELECT 'Group ' || REPLACE(group_name, 'Group ', '')
        FROM students
        WHERE auth_user_id = (SELECT auth.uid())
           OR lower(trim(email)) = lower(trim((SELECT auth.jwt() ->> 'email')))
      )
    )
  )
  OR
  -- one-time cross-group class: SAME RULE as before, now an uncorrelated set (computed once)
  (
    student_id IS NULL
    AND class_date IS NOT NULL
    AND (
      upper(regexp_replace(trim(group_name), '^[Gg]roup\s*', '')),
      class_date
    ) IN (
      SELECT upper(regexp_replace(trim(pr.notes), '^[Gg]roup\s*', '')), pr.date
      FROM payment_records pr
      WHERE lower(trim(pr.payment_method)) = 'manual_enrollment'
        AND pr.notes IS NOT NULL
        AND pr.student_id IN (
          SELECT id
          FROM students
          WHERE auth_user_id = (SELECT auth.uid())
             OR lower(trim(email)) = lower(trim((SELECT auth.jwt() ->> 'email')))
        )
    )
  )
  OR
  -- (unchanged) Admin bypass
  (SELECT is_arnoma_admin())
);

-- ------------------------------------------------------------
-- note_free_access
-- ------------------------------------------------------------
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
      WHERE auth_user_id = (SELECT auth.uid())
         OR lower(trim(email)) = lower(trim((SELECT auth.jwt() ->> 'email')))
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
        auth_user_id = (SELECT auth.uid())
        OR lower(trim(email)) = lower(trim((SELECT auth.jwt() ->> 'email')))
      )
      AND created_at <= note_free_access.created_at
    )
  )
  OR
  -- one-time cross-group class: SAME RULE as before, now an uncorrelated set (computed once)
  (
    access_type = 'group'
    AND class_date IS NOT NULL
    AND (
      upper(regexp_replace(trim(group_letter), '^[Gg]roup\s*', '')),
      class_date
    ) IN (
      SELECT upper(regexp_replace(trim(pr.notes), '^[Gg]roup\s*', '')), pr.date
      FROM payment_records pr
      WHERE lower(trim(pr.payment_method)) = 'manual_enrollment'
        AND pr.notes IS NOT NULL
        AND pr.student_id IN (
          SELECT id
          FROM students
          WHERE auth_user_id = (SELECT auth.uid())
             OR lower(trim(email)) = lower(trim((SELECT auth.jwt() ->> 'email')))
        )
    )
  )
  OR
  -- (unchanged) Admin bypass
  (SELECT is_arnoma_admin())
);

-- ------------------------------------------------------------
-- student_notes
-- ------------------------------------------------------------
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
      WHERE nfa.access_type = 'individual'
        AND nfa.student_id IN (
          SELECT id FROM students
          WHERE auth_user_id = (SELECT auth.uid())
             OR lower(trim(email)) = lower(trim((SELECT auth.jwt() ->> 'email')))
        )
    )

    OR

    -- (unchanged, b) Group free-access grant — student must have joined BEFORE access was granted
    id IN (
      SELECT nfa.note_id
      FROM note_free_access nfa
      INNER JOIN students s
        ON  s.auth_user_id = (SELECT auth.uid())
         OR lower(trim(s.email)) = lower(trim((SELECT auth.jwt() ->> 'email')))
      WHERE nfa.access_type = 'group'
        AND nfa.group_letter = upper(regexp_replace(coalesce(s.group_name, ''), '^[Gg]roup\s*', ''))
        AND s.created_at <= nfa.created_at
    )

    OR

    -- (unchanged, c) student_note_permissions — individual explicit access, no date guard
    id IN (
      SELECT snp.note_id
      FROM student_note_permissions snp
      WHERE snp.is_accessible = true
        AND snp.student_id IN (
          SELECT id FROM students
          WHERE auth_user_id = (SELECT auth.uid())
             OR lower(trim(email)) = lower(trim((SELECT auth.jwt() ->> 'email')))
        )
    )

    OR

    -- (unchanged, c2) student_note_permissions — group-level access, retroactive guard
    EXISTS (
      SELECT 1
      FROM student_note_permissions snp
      INNER JOIN students s
        ON  s.auth_user_id = (SELECT auth.uid())
         OR lower(trim(s.email)) = lower(trim((SELECT auth.jwt() ->> 'email')))
      WHERE snp.note_id = student_notes.id
        AND snp.is_accessible = true
        AND snp.student_id IS NULL
        AND upper(regexp_replace(coalesce(snp.group_name, ''), '^[Gg]roup\s*', ''))
          = upper(regexp_replace(coalesce(s.group_name, ''), '^[Gg]roup\s*', ''))
        AND s.created_at <= student_notes.created_at
    )

    OR

    -- (e) one-time cross-group class: SAME RULE as before, now an uncorrelated set
    id IN (
      SELECT snp.note_id
      FROM student_note_permissions snp
      WHERE snp.is_accessible = true
        AND snp.student_id IS NULL
        AND snp.class_date IS NOT NULL
        AND (
          upper(regexp_replace(coalesce(snp.group_name, ''), '^[Gg]roup\s*', '')),
          snp.class_date
        ) IN (
          SELECT upper(regexp_replace(trim(pr.notes), '^[Gg]roup\s*', '')), pr.date
          FROM payment_records pr
          WHERE lower(trim(pr.payment_method)) = 'manual_enrollment'
            AND pr.notes IS NOT NULL
            AND pr.student_id IN (
              SELECT id FROM students
              WHERE auth_user_id = (SELECT auth.uid())
                 OR lower(trim(email)) = lower(trim((SELECT auth.jwt() ->> 'email')))
            )
        )
    )

    OR

    -- (unchanged, d) Admin bypass
    (SELECT is_arnoma_admin())
  )
);

COMMIT;


-- ============================================================
-- STEP 3: verify (read-only)
-- ============================================================
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

-- Then re-run STEP 0b and compare "Execution Time", and reload the portal as a real
-- student. Expected: student_notes ~0.3-0.6 s instead of ~4-5 s, same notes visible.
