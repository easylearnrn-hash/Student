-- ============================================================================
-- MIGRATION-NOTE-QUESTION-MAPPING.sql
-- Links every test question to the study note that teaches it, using stable ids.
--
-- ADDITIVE ONLY: creates 4 tables, 1 view and 1 nullable column. It does not
-- alter, rename or delete any existing table, row, policy or function.
-- Safe to re-run (IF NOT EXISTS / DROP POLICY IF EXISTS).
--
-- SAFE IMPLEMENTATION SEQUENCE
--   0. Back up: test_questions, test_topics, test_subjects, tests, student_notes
--      (done by build_note_question_map.py / ~/ARNOMA-backups before running).
--   1. Branch (feature/test-notes-integration). Nothing below touches main.
--   2. Dry-run THIS file inside BEGIN ... ROLLBACK and confirm no errors.
--   3. Apply this file (schema only, no data).
--   4. Populate note_catalog from Notes/  (python3 build_note_question_map.py).
--   5. Populate test_topics.note_id and question_note_links (same script).
--   6. Verify counts + that every question resolves to a note (queries at bottom).
--   7. Only then ship the front-end that reads these tables.
--
-- ROLLBACK (data in these tables is derived and can be rebuilt):
--   DROP VIEW  IF EXISTS public.v_question_primary_note;
--   DROP TABLE IF EXISTS public.question_revisions, public.question_review,
--                        public.question_note_links CASCADE;
--   ALTER TABLE public.test_topics DROP COLUMN IF EXISTS note_id;
--   DROP TABLE IF EXISTS public.note_catalog CASCADE;
--
-- DATA MODEL
--   test_subjects (system) --< test_topics (topic) --< test_questions
--   test_topics.note_id          -> note_catalog.note_id   (a topic's study note)
--   question_note_links          (question, note, role)    (1 primary + n secondary)
--   note_catalog.parent_note_id  -> note_catalog           (sub-notes, e.g. EKG rhythms)
--
--   note_id is a UUID v5 derived ONCE from the note's original path. It never
--   changes when a note is renamed or moved: update note_catalog.path instead.
--   content_sha256 records the note text a link was verified against, so edits
--   can be detected and the links re-checked.
-- ============================================================================

BEGIN;

-- 1. NOTE CATALOG ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.note_catalog (
  note_id         uuid PRIMARY KEY,
  system_name     text NOT NULL,
  title           text NOT NULL,
  subtitle        text,
  path            text NOT NULL,
  parent_note_id  uuid REFERENCES public.note_catalog(note_id) ON DELETE SET NULL,
  content_sha256  text,
  headings        jsonb NOT NULL DEFAULT '[]'::jsonb,
  student_note_id bigint,
  is_active       boolean NOT NULL DEFAULT true,
  created_at      timestamptz NOT NULL DEFAULT now(),
  updated_at      timestamptz NOT NULL DEFAULT now()
);
CREATE UNIQUE INDEX IF NOT EXISTS uq_note_catalog_path   ON public.note_catalog (path) WHERE is_active;
CREATE INDEX        IF NOT EXISTS idx_note_catalog_system ON public.note_catalog (system_name);
CREATE INDEX        IF NOT EXISTS idx_note_catalog_parent ON public.note_catalog (parent_note_id);

-- 2. TOPIC -> NOTE -----------------------------------------------------------
ALTER TABLE public.test_topics
  ADD COLUMN IF NOT EXISTS note_id uuid REFERENCES public.note_catalog(note_id) ON DELETE SET NULL;
CREATE INDEX IF NOT EXISTS idx_test_topics_note_id ON public.test_topics (note_id);

-- 3. QUESTION -> NOTE LINKS --------------------------------------------------
CREATE TABLE IF NOT EXISTS public.question_note_links (
  id              bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  question_id     bigint NOT NULL REFERENCES public.test_questions(id) ON DELETE CASCADE,
  note_id         uuid   NOT NULL REFERENCES public.note_catalog(note_id) ON DELETE RESTRICT,
  role            text   NOT NULL DEFAULT 'primary' CHECK (role IN ('primary', 'secondary')),
  section_heading text,
  anchor_text     text,
  support_level   text   NOT NULL DEFAULT 'unverified'
                  CHECK (support_level IN ('direct', 'partial', 'unmatched', 'gap', 'unverified')),
  -- direct/partial/unmatched = automated lexical screen only (NOT a clinical review)
  -- gap                      = a person confirmed the note lacks the needed content
  -- unverified               = not yet checked
  support_score   numeric(3,2),
  note_sha256     text,
  verified_by     text   NOT NULL DEFAULT 'auto-lexical-v2',
  verified_at     timestamptz,
  created_at      timestamptz NOT NULL DEFAULT now(),
  updated_at      timestamptz NOT NULL DEFAULT now(),
  UNIQUE (question_id, note_id)
);
-- A question has at most one primary note.
CREATE UNIQUE INDEX IF NOT EXISTS uq_qnl_one_primary ON public.question_note_links (question_id) WHERE role = 'primary';
CREATE INDEX        IF NOT EXISTS idx_qnl_note       ON public.question_note_links (note_id);

-- 4. REVIEW STATE (admin only) -----------------------------------------------
CREATE TABLE IF NOT EXISTS public.question_review (
  question_id  bigint PRIMARY KEY REFERENCES public.test_questions(id) ON DELETE CASCADE,
  status       text NOT NULL DEFAULT 'unreviewed'
               CHECK (status IN ('unreviewed', 'auto_checked', 'needs_admin_review', 'admin_approved', 'retired_duplicate')),
  issues       text[] NOT NULL DEFAULT '{}',
  duplicate_of bigint REFERENCES public.test_questions(id) ON DELETE SET NULL,
  notes        text,
  reviewed_by  text,
  reviewed_at  timestamptz,
  created_at   timestamptz NOT NULL DEFAULT now(),
  updated_at   timestamptz NOT NULL DEFAULT now()
);
CREATE INDEX IF NOT EXISTS idx_question_review_status ON public.question_review (status);

-- 5. AUDIT TRAIL FOR ANY AUTOMATED EDIT TO A QUESTION ------------------------
CREATE TABLE IF NOT EXISTS public.question_revisions (
  id          bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  question_id bigint NOT NULL REFERENCES public.test_questions(id) ON DELETE CASCADE,
  field       text   NOT NULL,
  old_value   jsonb,
  new_value   jsonb,
  reason      text   NOT NULL,
  changed_by  text   NOT NULL,
  changed_at  timestamptz NOT NULL DEFAULT now()
);
CREATE INDEX IF NOT EXISTS idx_question_revisions_q ON public.question_revisions (question_id);

-- 6. updated_at triggers (reuse the project's existing helper) ----------------
DROP TRIGGER IF EXISTS trg_note_catalog_updated_at        ON public.note_catalog;
CREATE TRIGGER trg_note_catalog_updated_at        BEFORE UPDATE ON public.note_catalog
  FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();
DROP TRIGGER IF EXISTS trg_question_note_links_updated_at ON public.question_note_links;
CREATE TRIGGER trg_question_note_links_updated_at BEFORE UPDATE ON public.question_note_links
  FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();
DROP TRIGGER IF EXISTS trg_question_review_updated_at     ON public.question_review;
CREATE TRIGGER trg_question_review_updated_at     BEFORE UPDATE ON public.question_review
  FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

-- 7. ROW LEVEL SECURITY ------------------------------------------------------
-- Students may read the catalog and the links (needed to open "study this topic").
-- Nothing here exposes answers. Review state and revisions are admin-only.
ALTER TABLE public.note_catalog        ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.question_note_links ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.question_review     ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.question_revisions  ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "public read active notes"  ON public.note_catalog;
CREATE POLICY "public read active notes"  ON public.note_catalog
  FOR SELECT TO anon, authenticated USING (is_active);
DROP POLICY IF EXISTS "admins manage note_catalog" ON public.note_catalog;
CREATE POLICY "admins manage note_catalog" ON public.note_catalog
  FOR ALL TO authenticated USING (public.is_arnoma_admin()) WITH CHECK (public.is_arnoma_admin());

DROP POLICY IF EXISTS "public read question note links" ON public.question_note_links;
CREATE POLICY "public read question note links" ON public.question_note_links
  FOR SELECT TO anon, authenticated USING (true);
DROP POLICY IF EXISTS "admins manage question note links" ON public.question_note_links;
CREATE POLICY "admins manage question note links" ON public.question_note_links
  FOR ALL TO authenticated USING (public.is_arnoma_admin()) WITH CHECK (public.is_arnoma_admin());

DROP POLICY IF EXISTS "admins manage question_review" ON public.question_review;
CREATE POLICY "admins manage question_review" ON public.question_review
  FOR ALL TO authenticated USING (public.is_arnoma_admin()) WITH CHECK (public.is_arnoma_admin());

DROP POLICY IF EXISTS "admins manage question_revisions" ON public.question_revisions;
CREATE POLICY "admins manage question_revisions" ON public.question_revisions
  FOR ALL TO authenticated USING (public.is_arnoma_admin()) WITH CHECK (public.is_arnoma_admin());

-- Defense in depth: anon never writes, and never reads admin-only tables.
REVOKE ALL ON public.note_catalog, public.question_note_links, public.question_review, public.question_revisions FROM anon;
GRANT SELECT ON public.note_catalog, public.question_note_links TO anon;

-- 8. ONE PLACE TO ASK "WHICH NOTE TEACHES THIS QUESTION?" ---------------------
-- An explicit primary link wins; otherwise the question inherits its topic's note.
-- New questions added in the editor therefore resolve to a note without extra work.
CREATE OR REPLACE VIEW public.v_question_primary_note
  WITH (security_invoker = true) AS
SELECT q.id                                   AS question_id,
       q.topic_id,
       COALESCE(l.note_id, t.note_id)         AS note_id,
       (l.note_id IS NOT NULL)                AS has_explicit_link,
       l.section_heading,
       l.anchor_text,
       COALESCE(l.support_level, 'unverified') AS support_level
FROM public.test_questions q
LEFT JOIN public.test_topics         t ON t.id = q.topic_id
LEFT JOIN public.question_note_links l ON l.question_id = q.id AND l.role = 'primary';
GRANT SELECT ON public.v_question_primary_note TO anon, authenticated;

-- 9. UPGRADE PATH for databases created before 'unmatched' existed ------------
-- (CREATE TABLE IF NOT EXISTS does not alter an existing table.)
ALTER TABLE public.question_note_links DROP CONSTRAINT IF EXISTS question_note_links_support_level_check;
ALTER TABLE public.question_note_links ADD  CONSTRAINT question_note_links_support_level_check
  CHECK (support_level IN ('direct', 'partial', 'unmatched', 'gap', 'unverified'));

COMMIT;

-- ============================================================================
-- VERIFICATION (run after populating):
--   SELECT count(*) FROM public.note_catalog;                       -- expect 398
--   SELECT count(*) FROM public.test_topics WHERE note_id IS NOT NULL;
--   SELECT count(*) FROM public.v_question_primary_note WHERE note_id IS NULL;  -- expect 0 for active questions
--   SELECT question_id FROM public.question_note_links
--    WHERE role='primary' GROUP BY 1 HAVING count(*) > 1;           -- expect 0 rows
-- ============================================================================
