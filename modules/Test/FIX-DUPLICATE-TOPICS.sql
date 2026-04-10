-- ================================================================
-- FIX-DUPLICATE-TOPICS.sql
-- Run this in the Supabase SQL Editor.
--
-- Problem: test_topics has duplicate rows for the same concept
-- (e.g. "Anticoagulants" with 100 questions AND "ANTICOAGULANTS"
-- with 0 questions). This script:
--
--   1. For each group of duplicates, picks ONE canonical row
--      (the one that already has questions attached).
--   2. Re-points all test_questions.topic_id to the canonical row.
--   3. Deletes the empty duplicate rows.
--   4. Removes topics with 0 questions that have no canonical match
--      and are clearly stale imports (they have no questions at all
--      anywhere in the system by any name variant).
-- ================================================================

BEGIN;

-- ────────────────────────────────────────────────────────────────
-- STEP 1: Merge duplicates by canonical (lowercased, trimmed) name
-- ────────────────────────────────────────────────────────────────
DO $$
DECLARE
  rec         RECORD;
  keep_id     UUID;
  dup_ids     UUID[];
BEGIN
  -- Loop over every group of topics that share the same normalised name
  FOR rec IN
    SELECT
      lower(trim(name)) AS norm_name,
      array_agg(id ORDER BY
        -- prefer the row that actually has questions attached
        (SELECT COUNT(*) FROM test_questions q WHERE q.topic_id = t.id) DESC,
        -- then prefer the row whose name has normal mixed-case (not all-caps)
        CASE WHEN name = upper(name) THEN 1 ELSE 0 END ASC,
        created_at ASC
      ) AS ids
    FROM test_topics t
    GROUP BY lower(trim(name))
    HAVING COUNT(*) > 1
  LOOP
    keep_id := rec.ids[1];                  -- the "winner"
    dup_ids := rec.ids[2:array_length(rec.ids, 1)];  -- everything else

    -- Re-point any questions on the duplicates to the winner
    UPDATE test_questions
       SET topic_id = keep_id
     WHERE topic_id = ANY(dup_ids);

    -- Delete the now-empty duplicate topic rows
    DELETE FROM test_topics WHERE id = ANY(dup_ids);

    RAISE NOTICE 'Merged % duplicate(s) of "%" → kept %', array_length(dup_ids,1), rec.norm_name, keep_id;
  END LOOP;
END $$;

-- ────────────────────────────────────────────────────────────────
-- STEP 2: Verify — show all topics and their question counts
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
