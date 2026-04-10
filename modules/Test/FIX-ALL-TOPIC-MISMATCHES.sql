-- ================================================================
-- FIX-ALL-TOPIC-MISMATCHES.sql
-- Run this in the Supabase SQL Editor.
--
-- For every topic that has questions split across multiple rows
-- (orphan rows created by the subject_id mismatch bug), this
-- consolidates ALL questions onto the single canonical row that
-- has the most questions, then deletes the orphan rows.
-- ================================================================

BEGIN;

DO $$
DECLARE
  rec         RECORD;
  canonical_id UUID;
  orphan_ids   UUID[];
  moved        INT;
BEGIN
  -- Find every topic name that has MORE THAN ONE row in test_topics
  FOR rec IN
    SELECT
      name,
      array_agg(id ORDER BY
        (SELECT COUNT(*) FROM test_questions q WHERE q.topic_id = t.id) DESC,
        created_at ASC
      ) AS ids
    FROM test_topics t
    GROUP BY name
    HAVING COUNT(*) > 1
  LOOP
    canonical_id := rec.ids[1];
    orphan_ids   := rec.ids[2:array_length(rec.ids,1)];

    UPDATE test_questions
       SET topic_id = canonical_id
     WHERE topic_id = ANY(orphan_ids);

    GET DIAGNOSTICS moved = ROW_COUNT;

    DELETE FROM test_topics WHERE id = ANY(orphan_ids);

    RAISE NOTICE 'Merged "%" — moved % questions → canonical %', rec.name, moved, canonical_id;
  END LOOP;
END $$;

-- Also fix topics where ALL questions ended up on an orphan with a
-- different subject_id than the notes-system row (canonical has 0,
-- orphan has 100). Re-run by name, picking the row with most questions.
DO $$
DECLARE
  tname TEXT;
  canonical_id UUID;
  orphan_ids   UUID[];
  moved        INT;

  topic_names TEXT[] := ARRAY[
    'Anticoagulants',
    'Buerger''s Disease',
    'CABG & PCI',
    'Cardiac Biomarkers',
    'Cardiac Tamponade',
    'Cardiomyopathy',
    'EKG',
    'Heart Attack vs Heart Failure vs Cardiac Arrest',
    'Heart Structure & Circulation',
    'Hypertension, Hypotension, CO & SV',
    'Infective Endocarditis',
    'Ischemic Heart Disease',
    'Pacemakers & ICDs',
    'Pericarditis',
    'PVD / PAD / DVT',
    'Right & Left Heart Failure',
    'Shock Management'
  ];
BEGIN
  FOREACH tname IN ARRAY topic_names
  LOOP
    -- Get all IDs for this name, best first
    SELECT array_agg(id ORDER BY
        (SELECT COUNT(*) FROM test_questions q WHERE q.topic_id = test_topics.id) DESC,
        created_at ASC
      )
    INTO orphan_ids
    FROM test_topics
    WHERE name = tname;

    IF orphan_ids IS NULL OR array_length(orphan_ids,1) < 2 THEN
      CONTINUE;  -- already clean
    END IF;

    canonical_id := orphan_ids[1];
    orphan_ids   := orphan_ids[2:array_length(orphan_ids,1)];

    UPDATE test_questions SET topic_id = canonical_id WHERE topic_id = ANY(orphan_ids);
    GET DIAGNOSTICS moved = ROW_COUNT;
    DELETE FROM test_topics WHERE id = ANY(orphan_ids);

    RAISE NOTICE 'Fixed "%" — moved % questions → %', tname, moved, canonical_id;
  END LOOP;
END $$;

-- ── Final check ──────────────────────────────────────────────────
SELECT
  t.name,
  t.status,
  COUNT(q.id) AS question_count
FROM test_topics t
LEFT JOIN test_questions q ON q.topic_id = t.id AND q.is_active = true
WHERE t.name IN (
  'Anticoagulants','Buerger''s Disease','CABG & PCI','Cardiac Biomarkers',
  'Cardiac Tamponade','Cardiomyopathy','EKG',
  'Heart Attack vs Heart Failure vs Cardiac Arrest',
  'Heart Structure & Circulation','Hypertension, Hypotension, CO & SV',
  'Infective Endocarditis','Ischemic Heart Disease','Pacemakers & ICDs',
  'Pericarditis','PVD / PAD / DVT','Right & Left Heart Failure','Shock Management'
)
GROUP BY t.id, t.name, t.status
ORDER BY t.name;

COMMIT;
