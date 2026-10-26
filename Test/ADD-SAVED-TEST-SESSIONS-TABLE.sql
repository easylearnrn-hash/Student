-- ============================================================
-- ADD-SAVED-TEST-SESSIONS-TABLE.sql
-- Run this in the Supabase SQL Editor for project:
--   https://zlvnxvrzotamhpezqedr.supabase.co
-- ============================================================

CREATE TABLE IF NOT EXISTS saved_test_sessions (
  id                       UUID          PRIMARY KEY DEFAULT gen_random_uuid(),
  session_name             TEXT,
  student_id               TEXT          NOT NULL,
  owner_auth_id            UUID          NOT NULL DEFAULT auth.uid(),  -- the signed-in Supabase user who owns this row
  test_id                  BIGINT        REFERENCES tests(id) ON DELETE SET NULL,
  session_id               TEXT,
  current_question_index   INT           NOT NULL DEFAULT 0,
  answers                  JSONB,
  answer_status            JSONB,
  flagged_questions        JSONB,
  questions                JSONB,
  test_config              JSONB,
  start_time               TIMESTAMPTZ,
  shuffle_seed             TEXT,
  total_questions          INT,
  answered_questions       INT,
  progress_percent         INT,
  session_snapshot_en      JSONB,
  session_snapshot_hy      JSONB,
  created_at               TIMESTAMPTZ   NOT NULL DEFAULT NOW(),
  updated_at               TIMESTAMPTZ   NOT NULL DEFAULT NOW()
);

-- Indexes for the two most common lookups
CREATE INDEX IF NOT EXISTS idx_saved_test_sessions_student_id
  ON saved_test_sessions (student_id);

CREATE INDEX IF NOT EXISTS idx_saved_test_sessions_student_test
  ON saved_test_sessions (student_id, test_id);

-- Auto-update updated_at on every row change
CREATE OR REPLACE FUNCTION update_saved_test_sessions_updated_at()
RETURNS TRIGGER LANGUAGE plpgsql AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_saved_test_sessions_updated_at ON saved_test_sessions;
CREATE TRIGGER trg_saved_test_sessions_updated_at
  BEFORE UPDATE ON saved_test_sessions
  FOR EACH ROW EXECUTE FUNCTION update_saved_test_sessions_updated_at();

-- Tables created before the ownership column existed (safe to re-run)
ALTER TABLE saved_test_sessions ADD COLUMN IF NOT EXISTS owner_auth_id UUID DEFAULT auth.uid();
DELETE FROM saved_test_sessions WHERE owner_auth_id IS NULL;  -- unattributed rows could never be shown to their owner
ALTER TABLE saved_test_sessions ALTER COLUMN owner_auth_id SET DEFAULT auth.uid();
ALTER TABLE saved_test_sessions ALTER COLUMN owner_auth_id SET NOT NULL;
CREATE INDEX IF NOT EXISTS idx_saved_test_sessions_owner ON saved_test_sessions (owner_auth_id);

-- ============================================================
-- RLS — every signed-in person (student, teacher or admin) can see, change and delete ONLY
-- their own saved tests. There is deliberately NO admin override: nobody can read an
-- admin's saved tests, and an admin cannot read a student's. Signed-out visitors get nothing.
-- ============================================================
ALTER TABLE saved_test_sessions ENABLE ROW LEVEL SECURITY;

-- Remove every earlier policy (including the old "anyone can read/write everything" ones)
DO $$
DECLARE pol record;
BEGIN
  FOR pol IN SELECT policyname FROM pg_policies WHERE schemaname = 'public' AND tablename = 'saved_test_sessions' LOOP
    EXECUTE format('DROP POLICY %I ON public.saved_test_sessions', pol.policyname);
  END LOOP;
END $$;

REVOKE ALL ON saved_test_sessions FROM anon;
REVOKE ALL ON saved_test_sessions FROM PUBLIC;
GRANT SELECT, INSERT, UPDATE, DELETE ON saved_test_sessions TO authenticated;

CREATE POLICY "saved_sessions_owner_select" ON saved_test_sessions
  FOR SELECT TO authenticated
  USING (owner_auth_id = (SELECT auth.uid()));

CREATE POLICY "saved_sessions_owner_insert" ON saved_test_sessions
  FOR INSERT TO authenticated
  WITH CHECK (owner_auth_id = (SELECT auth.uid()));

CREATE POLICY "saved_sessions_owner_update" ON saved_test_sessions
  FOR UPDATE TO authenticated
  USING (owner_auth_id = (SELECT auth.uid()))
  WITH CHECK (owner_auth_id = (SELECT auth.uid()));

CREATE POLICY "saved_sessions_owner_delete" ON saved_test_sessions
  FOR DELETE TO authenticated
  USING (owner_auth_id = (SELECT auth.uid()));
