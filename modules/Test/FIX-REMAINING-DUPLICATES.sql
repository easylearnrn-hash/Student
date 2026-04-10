-- ================================================================
-- FIX-REMAINING-DUPLICATES.sql
-- Run this in the Supabase SQL Editor.
--
-- Merges the remaining near-duplicate topic pairs that differ by
-- punctuation/wording (not just casing), so the earlier
-- FIX-DUPLICATE-TOPICS.sql normaliser missed them.
--
-- For each pair:
--   1. Re-points any questions on the empty row to the winner.
--   2. Deletes the empty row.
-- ================================================================

BEGIN;

DO $$
DECLARE
  winner_id UUID;
  loser_id  UUID;

  -- Each pair: (winner name with questions, loser name with 0 questions)
  pairs TEXT[][] := ARRAY[
    ARRAY['Buerger''s Disease',                              'Buergers Disease'],
    ARRAY['Pacemakers & ICDs',                              'Pacemakers _ ICDs'],
    ARRAY['Right & Left Heart Failure',                     'Right & Left-Sided Heart Failure'],
    ARRAY['PVD / PAD / DVT',                                'PVD,  PAD,  DVT'],
    ARRAY['Ischemic Heart Disease',                         'Ischemic Heart Disease IHD'],
    ARRAY['Hypertension, Hypotension, CO & SV',             'Hyper-Hypotension, CO & SV'],
    ARRAY['Heart Attack vs Heart Failure vs Cardiac Arrest','Heart Attack _  Heart Failure _ Cardiac Arrest.docx']
  ];

  pair TEXT[];
BEGIN
  FOREACH pair SLICE 1 IN ARRAY pairs
  LOOP
    SELECT id INTO winner_id FROM test_topics WHERE name = pair[1] LIMIT 1;
    SELECT id INTO loser_id  FROM test_topics WHERE name = pair[2] LIMIT 1;

    IF winner_id IS NULL THEN
      RAISE WARNING 'Winner not found: "%"', pair[1];
      CONTINUE;
    END IF;

    IF loser_id IS NULL THEN
      RAISE NOTICE 'Loser already gone (skipping): "%"', pair[2];
      CONTINUE;
    END IF;

    -- Re-point any questions (safety net — should be 0, but just in case)
    UPDATE test_questions SET topic_id = winner_id WHERE topic_id = loser_id;

    -- Remove the duplicate
    DELETE FROM test_topics WHERE id = loser_id;

    RAISE NOTICE 'Merged "%" → "%"', pair[2], pair[1];
  END LOOP;
END $$;

-- ────────────────────────────────────────────────────────────────
-- Verify: show all topics with their question counts
-- ────────────────────────────────────────────────────────────────
SELECT
  t.name,
  t.status,
  COUNT(q.id) AS question_count
FROM test_topics t
LEFT JOIN test_questions q
       ON q.topic_id = t.id
      AND q.is_active = true
GROUP BY t.id, t.name, t.status
ORDER BY question_count DESC, t.name ASC;

COMMIT;
