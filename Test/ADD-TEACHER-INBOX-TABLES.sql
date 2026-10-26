-- ============================================================
-- ADD-TEACHER-INBOX-TABLES.sql
-- Run in the Supabase SQL Editor for project zlvnxvrzotamhpezqedr.
--
-- question_flags     : a student pressed "Flag" on a question (admin sees them in "Flagged questions")
-- teacher_questions  : a student pressed "Ask the teacher" (admin sees them in "Students asking me")
--
-- Privacy: signed-in students can only create / see their own rows; administrators
-- (is_arnoma_admin()) can see and manage everything. Anonymous visitors have no access.
-- ============================================================

CREATE TABLE IF NOT EXISTS question_flags (
  id             UUID         PRIMARY KEY DEFAULT gen_random_uuid(),
  question_id    BIGINT       NOT NULL,
  question_text  TEXT,
  options        JSONB,
  correct_answer TEXT,
  topic_name     TEXT,
  student_name   TEXT,
  student_email  TEXT,
  owner_auth_id  UUID         NOT NULL DEFAULT auth.uid(),
  created_at     TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
  UNIQUE (owner_auth_id, question_id)
);
CREATE INDEX IF NOT EXISTS idx_question_flags_question ON question_flags (question_id);
CREATE INDEX IF NOT EXISTS idx_question_flags_created  ON question_flags (created_at DESC);

CREATE TABLE IF NOT EXISTS teacher_questions (
  id             UUID         PRIMARY KEY DEFAULT gen_random_uuid(),
  question_id    BIGINT,
  question_text  TEXT,
  options        JSONB,
  correct_answer TEXT,
  topic_name     TEXT,
  message        TEXT         NOT NULL,
  student_name   TEXT,
  student_email  TEXT,
  owner_auth_id  UUID         NOT NULL DEFAULT auth.uid(),
  status         TEXT         NOT NULL DEFAULT 'open' CHECK (status IN ('open', 'resolved')),
  created_at     TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
  resolved_at    TIMESTAMPTZ
);
CREATE INDEX IF NOT EXISTS idx_teacher_questions_status  ON teacher_questions (status, created_at DESC);

ALTER TABLE question_flags    ENABLE ROW LEVEL SECURITY;
ALTER TABLE teacher_questions ENABLE ROW LEVEL SECURITY;

REVOKE ALL ON question_flags, teacher_questions FROM anon;
GRANT SELECT, INSERT, UPDATE, DELETE ON question_flags, teacher_questions TO authenticated;

DROP POLICY IF EXISTS question_flags_select ON question_flags;
DROP POLICY IF EXISTS question_flags_insert ON question_flags;
DROP POLICY IF EXISTS question_flags_delete ON question_flags;

CREATE POLICY question_flags_select ON question_flags FOR SELECT TO authenticated
  USING (owner_auth_id = auth.uid() OR is_arnoma_admin());
CREATE POLICY question_flags_insert ON question_flags FOR INSERT TO authenticated
  WITH CHECK (owner_auth_id = auth.uid());
CREATE POLICY question_flags_delete ON question_flags FOR DELETE TO authenticated
  USING (owner_auth_id = auth.uid() OR is_arnoma_admin());

DROP POLICY IF EXISTS teacher_questions_select ON teacher_questions;
DROP POLICY IF EXISTS teacher_questions_insert ON teacher_questions;
DROP POLICY IF EXISTS teacher_questions_update ON teacher_questions;
DROP POLICY IF EXISTS teacher_questions_delete ON teacher_questions;

CREATE POLICY teacher_questions_select ON teacher_questions FOR SELECT TO authenticated
  USING (owner_auth_id = auth.uid() OR is_arnoma_admin());
CREATE POLICY teacher_questions_insert ON teacher_questions FOR INSERT TO authenticated
  WITH CHECK (owner_auth_id = auth.uid() AND status = 'open');
CREATE POLICY teacher_questions_update ON teacher_questions FOR UPDATE TO authenticated
  USING (is_arnoma_admin()) WITH CHECK (is_arnoma_admin());
CREATE POLICY teacher_questions_delete ON teacher_questions FOR DELETE TO authenticated
  USING (is_arnoma_admin());
