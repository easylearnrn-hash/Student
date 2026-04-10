-- ================================================================
-- SEED-TEST-CONFIG-AND-SUBJECTS.sql
-- Run this in the Supabase SQL Editor for:
--   https://zlvnxvrzotamhpezqedr.supabase.co
--
-- What this does:
--   1. Drops and recreates test_configs with the columns test.html expects
--   2. Inserts the default test config row (UUID 00000000-0000-0000-0000-000000000001)
--   3. Inserts seed subjects into test_subjects
-- ================================================================


-- ────────────────────────────────────────────────────────────────
-- 1.  Recreate test_configs with the columns test.html reads
-- ────────────────────────────────────────────────────────────────
DROP TABLE IF EXISTS test_configs CASCADE;

CREATE TABLE test_configs (
  id                   UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  title                TEXT        NOT NULL DEFAULT 'Practice Test',
  duration_minutes     INT         NOT NULL DEFAULT 60,
  shuffle_questions    BOOLEAN     NOT NULL DEFAULT TRUE,
  shuffle_options      BOOLEAN     NOT NULL DEFAULT TRUE,
  show_back_button     BOOLEAN     NOT NULL DEFAULT TRUE,
  allow_review         BOOLEAN     NOT NULL DEFAULT TRUE,
  passing_score_percent INT        NOT NULL DEFAULT 70,
  is_active            BOOLEAN     NOT NULL DEFAULT TRUE,
  created_at           TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at           TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

ALTER TABLE test_configs ENABLE ROW LEVEL SECURITY;

CREATE POLICY "public can read active test_configs"
  ON test_configs FOR SELECT
  TO anon, authenticated
  USING (TRUE);

CREATE POLICY "admins manage test_configs"
  ON test_configs FOR ALL
  USING (
    EXISTS (SELECT 1 FROM admin_accounts WHERE auth_user_id = auth.uid())
  );


-- ────────────────────────────────────────────────────────────────
-- 2.  Insert the default config row that test.html always looks for
--     (id = 00000000-0000-0000-0000-000000000001)
-- ────────────────────────────────────────────────────────────────
INSERT INTO test_configs (
  id,
  title,
  duration_minutes,
  shuffle_questions,
  shuffle_options,
  show_back_button,
  allow_review,
  passing_score_percent,
  is_active
) VALUES (
  '00000000-0000-0000-0000-000000000001',
  'Nursing & Health Sciences Practice Test',
  90,
  TRUE,
  TRUE,
  TRUE,
  TRUE,
  70,
  TRUE
)
ON CONFLICT (id) DO UPDATE SET
  title                 = EXCLUDED.title,
  duration_minutes      = EXCLUDED.duration_minutes,
  shuffle_questions     = EXCLUDED.shuffle_questions,
  shuffle_options       = EXCLUDED.shuffle_options,
  show_back_button      = EXCLUDED.show_back_button,
  allow_review          = EXCLUDED.allow_review,
  passing_score_percent = EXCLUDED.passing_score_percent,
  is_active             = EXCLUDED.is_active,
  updated_at            = NOW();


-- ────────────────────────────────────────────────────────────────
-- 3.  Clear old seed data and re-seed subjects matching real Notes
--     Subject names map exactly to student_notes.category values
-- ────────────────────────────────────────────────────────────────
TRUNCATE test_topics, test_subjects RESTART IDENTITY CASCADE;

INSERT INTO test_subjects (name, display_order, is_active) VALUES
  ('Cardiovascular System',                1,  TRUE),
  ('Respiratory System',                   2,  TRUE),
  ('Neurology',                            3,  TRUE),
  ('Gastrointestinal & Hepatic System',    4,  TRUE),
  ('Renal',                                5,  TRUE),
  ('Endocrine System',                     6,  TRUE),
  ('Musculoskeletal Disorders',            7,  TRUE),
  ('Burns and Skin',                       8,  TRUE),
  ('Autoimmune & Infectious Disorders',    9,  TRUE),
  ('Cancer',                              10,  TRUE),
  ('Reproductive and Sexual Health System',11, TRUE),
  ('EENT',                                12,  TRUE),
  ('Eye Disorders',                       13,  TRUE),
  ('Mental Health',                       14,  TRUE),
  ('Maternal Health',                     15,  TRUE),
  ('Pediatrics',                          16,  TRUE),
  ('Pharmacology',                        17,  TRUE),
  ('Nursing Skills and Fundamentals',     18,  TRUE),
  ('Fluids, Electrolytes & Nutrition',    19,  TRUE),
  ('Medical-Surgical Care',               20,  TRUE),
  ('Psycho-Social Aspects',               21,  TRUE),
  ('Human Anatomy',                       22,  TRUE),
  ('Medical Terminology',                 23,  TRUE),
  ('Medication Suffixes and Drug Classes',24,  TRUE);


-- ────────────────────────────────────────────────────────────────
-- 4.  Populate test_topics directly from student_notes.title
--     Joined on student_notes.category = test_subjects.name (exact match)
--     Each distinct note title becomes a selectable topic.
-- ────────────────────────────────────────────────────────────────
INSERT INTO test_topics (subject_id, name, display_order, status)
SELECT
  s.id                                                    AS subject_id,
  TRIM(regexp_replace(n.title, '[^\u0000-\u007F\u00A0-\u024F]+', '', 'g')) AS name,
  ROW_NUMBER() OVER (
    PARTITION BY s.id
    ORDER BY n.created_at
  )                                                       AS display_order,
  'published'                                             AS status
FROM student_notes n
JOIN test_subjects s
  ON s.name = n.category
WHERE
  n.title IS NOT NULL
  AND n.title <> ''
  AND (n.deleted IS NULL OR n.deleted = FALSE)
GROUP BY s.id, n.title, n.created_at
ORDER BY s.id, n.created_at;