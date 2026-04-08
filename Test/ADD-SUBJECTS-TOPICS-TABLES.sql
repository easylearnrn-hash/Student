-- ================================================================
-- ADD-SUBJECTS-TOPICS-TABLES.sql
-- Run this in the Supabase SQL Editor once.
-- Creates: test_subjects, test_topics, test_configs
-- Extends: test_questions with topic_id, display_order, bilingual
--          fields, is_multiple_choice, is_flagged, is_active, points
-- ================================================================


-- ────────────────────────────────────────────────────────────────
-- 1. test_subjects  (e.g. "Pharmacology", "Med-Surg")
-- ────────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS test_subjects (
  id             UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name           TEXT NOT NULL,
  description    TEXT,
  display_order  INT  NOT NULL DEFAULT 0,
  is_active      BOOLEAN NOT NULL DEFAULT TRUE,
  created_at     TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Allow everyone to read active subjects (students + admins)
ALTER TABLE test_subjects ENABLE ROW LEVEL SECURITY;

CREATE POLICY "public can read active subjects"
  ON test_subjects FOR SELECT
  USING (is_active = TRUE);

CREATE POLICY "admins manage subjects"
  ON test_subjects FOR ALL
  USING (
    EXISTS (SELECT 1 FROM admin_accounts WHERE auth_user_id = auth.uid())
  );


-- ────────────────────────────────────────────────────────────────
-- 2. test_topics  (e.g. "Beta Blockers", "Cardiac Output")
-- ────────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS test_topics (
  id             UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  subject_id     UUID NOT NULL REFERENCES test_subjects(id) ON DELETE CASCADE,
  name           TEXT NOT NULL,
  description    TEXT,
  display_order  INT  NOT NULL DEFAULT 0,
  status         TEXT NOT NULL DEFAULT 'published',  -- 'published' | 'draft'
  created_at     TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_test_topics_subject_id ON test_topics(subject_id);
CREATE INDEX IF NOT EXISTS idx_test_topics_status      ON test_topics(status);

ALTER TABLE test_topics ENABLE ROW LEVEL SECURITY;

CREATE POLICY "public can read published topics"
  ON test_topics FOR SELECT
  USING (status = 'published');

CREATE POLICY "admins manage topics"
  ON test_topics FOR ALL
  USING (
    EXISTS (SELECT 1 FROM admin_accounts WHERE auth_user_id = auth.uid())
  );


-- ────────────────────────────────────────────────────────────────
-- 3. test_configs  (maps a subject → a test container in `tests`)
--    question.html uses this to look up which test_id to insert into
-- ────────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS test_configs (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  subject_id  UUID NOT NULL REFERENCES test_subjects(id) ON DELETE CASCADE,
  test_id     BIGINT REFERENCES tests(id) ON DELETE SET NULL,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE UNIQUE INDEX IF NOT EXISTS idx_test_configs_subject_id ON test_configs(subject_id);

ALTER TABLE test_configs ENABLE ROW LEVEL SECURITY;

CREATE POLICY "public can read test_configs"
  ON test_configs FOR SELECT
  TO anon, authenticated
  USING (TRUE);

CREATE POLICY "admins manage test_configs"
  ON test_configs FOR ALL
  USING (
    EXISTS (SELECT 1 FROM admin_accounts WHERE auth_user_id = auth.uid())
  );


-- ────────────────────────────────────────────────────────────────
-- 4. Extend test_questions with columns question.html expects
-- ────────────────────────────────────────────────────────────────

-- Link each question to a topic
ALTER TABLE test_questions
  ADD COLUMN IF NOT EXISTS topic_id          UUID REFERENCES test_topics(id) ON DELETE SET NULL;

-- Ordering within a topic
ALTER TABLE test_questions
  ADD COLUMN IF NOT EXISTS display_order     INT  NOT NULL DEFAULT 0;

-- Multiple-choice flag
ALTER TABLE test_questions
  ADD COLUMN IF NOT EXISTS is_multiple_choice BOOLEAN NOT NULL DEFAULT FALSE;

-- is_active guard (question.html filters on this)
ALTER TABLE test_questions
  ADD COLUMN IF NOT EXISTS is_active         BOOLEAN NOT NULL DEFAULT TRUE;

-- Points value
ALTER TABLE test_questions
  ADD COLUMN IF NOT EXISTS points            INT NOT NULL DEFAULT 1;

-- Flag for review
ALTER TABLE test_questions
  ADD COLUMN IF NOT EXISTS is_flagged        BOOLEAN NOT NULL DEFAULT FALSE;

-- Bilingual fields (Armenian)
ALTER TABLE test_questions
  ADD COLUMN IF NOT EXISTS question_stem_hy  TEXT;
ALTER TABLE test_questions
  ADD COLUMN IF NOT EXISTS options_hy        JSONB;
ALTER TABLE test_questions
  ADD COLUMN IF NOT EXISTS rationale_hy      TEXT;

-- Indexes
CREATE INDEX IF NOT EXISTS idx_test_questions_topic_id      ON test_questions(topic_id);
CREATE INDEX IF NOT EXISTS idx_test_questions_is_active     ON test_questions(is_active);
CREATE INDEX IF NOT EXISTS idx_test_questions_display_order ON test_questions(display_order);
CREATE INDEX IF NOT EXISTS idx_test_questions_is_flagged    ON test_questions(is_flagged);


-- ────────────────────────────────────────────────────────────────
-- 5. RLS policy so question.html (anon) can insert questions
--    (run this only once — skip if policy already exists)
-- ────────────────────────────────────────────────────────────────
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies
    WHERE tablename = 'test_questions'
      AND policyname = 'allow question inserts anon'
  ) THEN
    EXECUTE $p$
      CREATE POLICY "allow question inserts anon"
        ON test_questions FOR INSERT
        TO anon, authenticated
        WITH CHECK (TRUE);
    $p$;
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM pg_policies
    WHERE tablename = 'test_questions'
      AND policyname = 'allow question updates anon'
  ) THEN
    EXECUTE $p$
      CREATE POLICY "allow question updates anon"
        ON test_questions FOR UPDATE
        TO anon, authenticated
        USING (TRUE);
    $p$;
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM pg_policies
    WHERE tablename = 'test_questions'
      AND policyname = 'allow question deletes anon'
  ) THEN
    EXECUTE $p$
      CREATE POLICY "allow question deletes anon"
        ON test_questions FOR DELETE
        TO anon, authenticated
        USING (TRUE);
    $p$;
  END IF;
END $$;
