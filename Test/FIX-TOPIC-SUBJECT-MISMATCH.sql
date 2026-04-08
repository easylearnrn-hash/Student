-- ================================================================
-- FIX-TOPIC-SUBJECT-MISMATCH.sql
-- Fixes questions that were inserted under a newly-created topic
-- row instead of the canonical notes-system topic row.
--
-- Root cause: INSERT scripts filtered by (subject_id + name), but
-- the notes-system topics live under a different subject_id, so the
-- SELECT returned NULL and a duplicate topic was created.
--
-- This script:
--   1. Shows you the duplicate topic rows (diagnosis)
--   2. Moves all questions from the orphan rows to the canonical rows
--   3. Deletes the orphan rows
-- ================================================================

BEGIN;

DO $$
DECLARE
  canonical_id UUID;
  orphan_id    UUID;
  orphan_count INT;

  -- For each topic: (canonical name, category used in INSERT script)
  -- We pick canonical = the row with the MOST questions (or oldest if tied)
  topics TEXT[] := ARRAY[
    'Buerger''s Disease',
    'PVD / PAD / DVT'
  ];
  tname TEXT;
BEGIN
  FOREACH tname IN ARRAY topics
  LOOP
    -- Find ALL rows with this name
    FOR canonical_id, orphan_id, orphan_count IN
      SELECT
        -- winner: row with most questions
        (SELECT id FROM test_topics
          WHERE name = tname
          ORDER BY (SELECT COUNT(*) FROM test_questions q WHERE q.topic_id = test_topics.id) DESC,
                   created_at ASC
          LIMIT 1),
        -- each other row
        t.id,
        (SELECT COUNT(*) FROM test_questions q WHERE q.topic_id = t.id)::INT
      FROM test_topics t
      WHERE t.name = tname
        AND t.id != (SELECT id FROM test_topics
                      WHERE name = tname
                      ORDER BY (SELECT COUNT(*) FROM test_questions q WHERE q.topic_id = test_topics.id) DESC,
                               created_at ASC
                      LIMIT 1)
    LOOP
      RAISE NOTICE 'Topic "%": moving % questions from orphan % → canonical %',
        tname, orphan_count, orphan_id, canonical_id;

      UPDATE test_questions SET topic_id = canonical_id WHERE topic_id = orphan_id;
      DELETE FROM test_topics WHERE id = orphan_id;
    END LOOP;
  END LOOP;
END $$;

-- ── Verify ───────────────────────────────────────────────────────
SELECT
  t.name,
  t.status,
  COUNT(q.id) AS question_count
FROM test_topics t
LEFT JOIN test_questions q ON q.topic_id = t.id AND q.is_active = true
WHERE t.name IN ('Buerger''s Disease', 'PVD / PAD / DVT')
GROUP BY t.id, t.name, t.status
ORDER BY t.name;

COMMIT;
