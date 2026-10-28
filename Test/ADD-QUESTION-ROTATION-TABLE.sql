-- ============================================================
-- ADD-QUESTION-ROTATION-TABLE.sql
-- Run in the Supabase SQL Editor for project zlvnxvrzotamhpezqedr.
--
-- Per-student question rotation: remembers when each question was last DISPLAYED to each
-- signed-in person. When a test is built, the questions of every topic are picked longest-ago
-- shown first (never-shown questions first, random among equals), so a question is not repeated
-- for that person until every other question in the topic has been shown since.
--
-- Privacy: every person can read and write ONLY their own rows (same model as saved_test_sessions).
-- There is deliberately no admin override and anonymous visitors have no access.
-- ============================================================

CREATE TABLE IF NOT EXISTS student_question_history (
  owner_auth_id    UUID         NOT NULL DEFAULT auth.uid(),
  question_id      BIGINT       NOT NULL,
  times_shown      INT          NOT NULL DEFAULT 1,
  last_session_id  TEXT,        -- one test session counts once, however often the question is revisited
  first_shown_at   TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
  last_shown_at    TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
  PRIMARY KEY (owner_auth_id, question_id)
);

ALTER TABLE student_question_history ENABLE ROW LEVEL SECURITY;

DO $$
DECLARE pol record;
BEGIN
  FOR pol IN SELECT policyname FROM pg_policies WHERE schemaname = 'public' AND tablename = 'student_question_history' LOOP
    EXECUTE format('DROP POLICY %I ON public.student_question_history', pol.policyname);
  END LOOP;
END $$;

REVOKE ALL ON student_question_history FROM anon;
REVOKE ALL ON student_question_history FROM PUBLIC;
GRANT SELECT, INSERT, UPDATE ON student_question_history TO authenticated;

CREATE POLICY sqh_owner_select ON student_question_history
  FOR SELECT TO authenticated USING (owner_auth_id = (SELECT auth.uid()));
CREATE POLICY sqh_owner_insert ON student_question_history
  FOR INSERT TO authenticated WITH CHECK (owner_auth_id = (SELECT auth.uid()));
CREATE POLICY sqh_owner_update ON student_question_history
  FOR UPDATE TO authenticated
  USING (owner_auth_id = (SELECT auth.uid()))
  WITH CHECK (owner_auth_id = (SELECT auth.uid()));

-- Record that these questions were displayed in a test session (counts once per session).
CREATE OR REPLACE FUNCTION record_questions_shown(p_ids BIGINT[], p_session TEXT)
RETURNS VOID
LANGUAGE sql
SECURITY INVOKER
SET search_path = public
AS $$
  INSERT INTO student_question_history (owner_auth_id, question_id, times_shown, last_session_id)
  SELECT auth.uid(), i, 1, p_session FROM unnest(p_ids) AS i
  ON CONFLICT (owner_auth_id, question_id) DO UPDATE
    SET times_shown     = student_question_history.times_shown
                          + CASE WHEN student_question_history.last_session_id IS DISTINCT FROM EXCLUDED.last_session_id THEN 1 ELSE 0 END,
        last_session_id = EXCLUDED.last_session_id,
        last_shown_at   = NOW();
$$;

-- { "<question_id>": last_shown_epoch_seconds, ... } for the caller's own history
-- (a single row, so the server's row cap never truncates it)
DROP FUNCTION IF EXISTS get_question_times_shown(BIGINT[]);
CREATE OR REPLACE FUNCTION get_question_last_shown(p_ids BIGINT[])
RETURNS JSONB
LANGUAGE sql
STABLE
SECURITY INVOKER
SET search_path = public
AS $$
  SELECT COALESCE(jsonb_object_agg(h.question_id::text, EXTRACT(EPOCH FROM h.last_shown_at)), '{}'::jsonb)
  FROM student_question_history h
  WHERE h.owner_auth_id = auth.uid() AND h.question_id = ANY (p_ids);
$$;

REVOKE ALL ON FUNCTION record_questions_shown(BIGINT[], TEXT) FROM PUBLIC, anon;
REVOKE ALL ON FUNCTION get_question_last_shown(BIGINT[]) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION record_questions_shown(BIGINT[], TEXT) TO authenticated;
GRANT EXECUTE ON FUNCTION get_question_last_shown(BIGINT[]) TO authenticated;

-- ============================================================
-- "Add more questions" helper (read-only).
-- For the selected topics only, returns per topic the first p_per_topic active questions that are not
-- already in the test, never-shown first and then longest-ago shown for the caller (random among
-- equals), plus how many questions of the test each topic already has. The page uses it to add
-- questions without downloading the whole question pool.
--   { "candidates": { "<topic_id>": [question_id, ...] }, "current": { "<topic_id>": n } }
-- ============================================================
CREATE OR REPLACE FUNCTION get_question_add_candidates(p_topic_ids UUID[], p_exclude BIGINT[], p_per_topic INT)
RETURNS JSONB
LANGUAGE sql
STABLE
SECURITY INVOKER
SET search_path = public
AS $$
  WITH pool AS (
    SELECT q.id, q.topic_id,
           ROW_NUMBER() OVER (PARTITION BY q.topic_id ORDER BY h.last_shown_at ASC NULLS FIRST, random()) AS rn
    FROM test_questions q
    LEFT JOIN student_question_history h
      ON h.question_id = q.id AND h.owner_auth_id = auth.uid()
    WHERE q.is_active
      AND q.topic_id = ANY (p_topic_ids)
      AND NOT (q.id = ANY (COALESCE(p_exclude, ARRAY[]::BIGINT[])))
  ),
  picked AS (
    SELECT topic_id, jsonb_agg(id ORDER BY rn) AS ids
    FROM pool WHERE rn <= GREATEST(p_per_topic, 1)
    GROUP BY topic_id
  ),
  cur AS (
    SELECT topic_id, COUNT(*) AS n
    FROM test_questions
    WHERE id = ANY (COALESCE(p_exclude, ARRAY[]::BIGINT[])) AND topic_id = ANY (p_topic_ids)
    GROUP BY topic_id
  )
  SELECT jsonb_build_object(
    'candidates', COALESCE((SELECT jsonb_object_agg(topic_id::text, ids) FROM picked), '{}'::jsonb),
    'current',    COALESCE((SELECT jsonb_object_agg(topic_id::text, n)   FROM cur),    '{}'::jsonb)
  );
$$;

REVOKE ALL ON FUNCTION get_question_add_candidates(UUID[], BIGINT[], INT) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION get_question_add_candidates(UUID[], BIGINT[], INT) TO authenticated;
