-- ============================================================
-- TEST GRADE HISTORY — ARNOMA (zlvnxvrzotamhpezqedr)
-- Stores every practice-test attempt as a permanent grade entry
-- (append-only). Used by Test/test.html:
--   • saveTestGrade()          — student submits a test
--   • Cold Call "submit grades" — admin records grades for students
--   • openGradeHistoryModal()  — admin "View All Student Quiz Results"
--
-- Identity is taken from the signed-in Supabase user, NOT from values
-- sent by the browser:
--   • Student insert → linked to their students row via auth.uid()
--   • Admin insert   → owner_id must be a students.id (Cold Call)
-- owner_id is normalised to students.id so one student = one key.
--
-- Access (RLS):
--   • Students: insert own attempts, read own attempts
--   • Admins (is_arnoma_admin()): full access
--   • anon: no access
--
-- Safe to re-run. Run once in the Supabase SQL Editor.
-- ============================================================

BEGIN;

CREATE TABLE IF NOT EXISTS public.test_grade_history (
  id                 UUID PRIMARY KEY DEFAULT gen_random_uuid(),

  -- Identity
  owner_id           TEXT NOT NULL,                     -- students.id (as text) once linked
  student_id         BIGINT REFERENCES public.students(id) ON DELETE SET NULL,
  auth_user_id       UUID,                              -- students.auth_user_id
  student_name       TEXT,
  student_email      TEXT,
  student_role       TEXT DEFAULT 'student',
  is_teacher_session BOOLEAN NOT NULL DEFAULT false,

  -- Test info
  test_title         TEXT NOT NULL,
  topics             TEXT,
  test_id            TEXT,
  answered_snapshot  JSONB,

  -- Score
  score_percent      INTEGER NOT NULL CHECK (score_percent BETWEEN 0 AND 100),
  letter_grade       CHAR(1) NOT NULL CHECK (letter_grade IN ('A','B','C','D','F')),
  correct_count      INTEGER NOT NULL DEFAULT 0,
  incorrect_count    INTEGER NOT NULL DEFAULT 0,
  total_questions    INTEGER NOT NULL DEFAULT 0,

  taken_at           TIMESTAMPTZ NOT NULL DEFAULT now(),
  created_at         TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Bring an older copy of the table up to date (no-ops on a fresh install)
ALTER TABLE public.test_grade_history ADD COLUMN IF NOT EXISTS student_id BIGINT REFERENCES public.students(id) ON DELETE SET NULL;
ALTER TABLE public.test_grade_history ADD COLUMN IF NOT EXISTS auth_user_id UUID;
ALTER TABLE public.test_grade_history ADD COLUMN IF NOT EXISTS student_role TEXT DEFAULT 'student';
ALTER TABLE public.test_grade_history ADD COLUMN IF NOT EXISTS is_teacher_session BOOLEAN NOT NULL DEFAULT false;
ALTER TABLE public.test_grade_history ADD COLUMN IF NOT EXISTS answered_snapshot JSONB;

-- ── Indexes ─────────────────────────────────────────────────
CREATE INDEX IF NOT EXISTS idx_tgh_owner_id     ON public.test_grade_history(owner_id);
CREATE INDEX IF NOT EXISTS idx_tgh_student_id   ON public.test_grade_history(student_id);
CREATE INDEX IF NOT EXISTS idx_tgh_auth_user_id ON public.test_grade_history(auth_user_id);
CREATE INDEX IF NOT EXISTS idx_tgh_taken_at     ON public.test_grade_history(taken_at DESC);
CREATE INDEX IF NOT EXISTS idx_tgh_test_id      ON public.test_grade_history(test_id);

-- ── Identity trigger ────────────────────────────────────────
-- Fills student_id / auth_user_id / name / email from the students table so
-- the browser cannot record a grade under someone else's identity.
CREATE OR REPLACE FUNCTION public.tgh_set_identity()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  s RECORD;
BEGIN
  IF public.is_arnoma_admin() THEN
    -- Admin recording grades for students (Cold Call): owner_id is students.id
    IF NEW.owner_id ~ '^\d+$' THEN
      SELECT id, auth_user_id, name, email INTO s
      FROM public.students WHERE id = NEW.owner_id::bigint;
      IF FOUND THEN
        NEW.student_id    := s.id;
        NEW.auth_user_id  := s.auth_user_id;
        NEW.student_name  := COALESCE(NEW.student_name, s.name);
        NEW.student_email := COALESCE(NEW.student_email, s.email::text);
      END IF;
    END IF;
  ELSE
    -- Student recording their own attempt: identity comes from the session only
    NEW.auth_user_id := auth.uid();
    NEW.student_id   := NULL;
    SELECT id, name, email INTO s
    FROM public.students WHERE auth_user_id = auth.uid()
    ORDER BY id LIMIT 1;
    IF FOUND THEN
      NEW.student_id    := s.id;
      NEW.owner_id      := s.id::text;
      NEW.student_name  := s.name;
      NEW.student_email := s.email::text;
    END IF;
    NEW.student_role       := 'student';
    NEW.is_teacher_session := false;
  END IF;
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_tgh_set_identity ON public.test_grade_history;
CREATE TRIGGER trg_tgh_set_identity
  BEFORE INSERT ON public.test_grade_history
  FOR EACH ROW EXECUTE FUNCTION public.tgh_set_identity();

-- ── RLS ─────────────────────────────────────────────────────
ALTER TABLE public.test_grade_history ENABLE ROW LEVEL SECURITY;

-- Remove any wide-open policy copied from another project
DROP POLICY IF EXISTS anon_all_test_grade_history    ON public.test_grade_history;
DROP POLICY IF EXISTS tgh_insert_own_or_admin        ON public.test_grade_history;
DROP POLICY IF EXISTS tgh_select_own_or_admin        ON public.test_grade_history;
DROP POLICY IF EXISTS tgh_update_admin               ON public.test_grade_history;
DROP POLICY IF EXISTS tgh_delete_admin               ON public.test_grade_history;

-- Students may only insert rows linked to their own students record; admins may insert any
CREATE POLICY tgh_insert_own_or_admin
  ON public.test_grade_history FOR INSERT TO authenticated
  WITH CHECK (
    public.is_arnoma_admin()
    OR (auth_user_id = auth.uid() AND student_id IS NOT NULL)
  );

CREATE POLICY tgh_select_own_or_admin
  ON public.test_grade_history FOR SELECT TO authenticated
  USING (public.is_arnoma_admin() OR auth_user_id = auth.uid());

-- Append-only for students; only admins may correct or remove entries
CREATE POLICY tgh_update_admin
  ON public.test_grade_history FOR UPDATE TO authenticated
  USING (public.is_arnoma_admin()) WITH CHECK (public.is_arnoma_admin());

CREATE POLICY tgh_delete_admin
  ON public.test_grade_history FOR DELETE TO authenticated
  USING (public.is_arnoma_admin());

COMMIT;

-- Make the new table visible to the API immediately (clears "not found in the schema cache")
NOTIFY pgrst, 'reload schema';

-- ── Verify ──────────────────────────────────────────────────
SELECT 'test_grade_history' AS table_name, count(*) AS rows FROM public.test_grade_history;
SELECT policyname, cmd, roles FROM pg_policies WHERE tablename = 'test_grade_history' ORDER BY policyname;
