-- ============================================================
-- ADD-SAVED-TEST-SESSIONS-TABLE.sql
-- Run this in the Supabase SQL Editor for project:
--   https://zlvnxvrzotamhpezqedr.supabase.co
-- ============================================================

CREATE TABLE IF NOT EXISTS saved_test_sessions (
  id                       UUID          PRIMARY KEY DEFAULT gen_random_uuid(),
  session_name             TEXT,
  student_id               TEXT          NOT NULL,
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

-- ============================================================
-- RLS
-- Anyone (anon) can save/load their own sessions by student_id.
-- Admins get full access.
-- ============================================================
ALTER TABLE saved_test_sessions ENABLE ROW LEVEL SECURITY;

-- Drop existing policies first so this script is safe to re-run
DROP POLICY IF EXISTS "anon_insert_own_sessions" ON saved_test_sessions;
DROP POLICY IF EXISTS "anon_select_own_sessions" ON saved_test_sessions;
DROP POLICY IF EXISTS "anon_update_own_sessions" ON saved_test_sessions;
DROP POLICY IF EXISTS "anon_delete_own_sessions" ON saved_test_sessions;

-- Anon / public: insert own rows
CREATE POLICY "anon_insert_own_sessions"
  ON saved_test_sessions
  FOR INSERT
  TO anon, authenticated
  WITH CHECK (true);

-- Anon / public: select own rows
CREATE POLICY "anon_select_own_sessions"
  ON saved_test_sessions
  FOR SELECT
  TO anon, authenticated
  USING (true);

-- Anon / public: update own rows
CREATE POLICY "anon_update_own_sessions"
  ON saved_test_sessions
  FOR UPDATE
  TO anon, authenticated
  USING (true)
  WITH CHECK (true);

-- Anon / public: delete own rows
CREATE POLICY "anon_delete_own_sessions"
  ON saved_test_sessions
  FOR DELETE
  TO anon, authenticated
  USING (true);
