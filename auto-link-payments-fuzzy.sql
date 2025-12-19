-- ============================================================================
-- AUTO-LINK ALL UNLINKED PAYMENTS USING FUZZY MATCHING
-- ============================================================================
-- 
-- This script automatically links payments to students by matching payer names
-- with student names and aliases using fuzzy logic:
--   • First word is enough (e.g., "Level" matches "Level Up Management, Inc")
--   • Ignores punctuation: , . - & etc.
--   • Ignores business suffixes: Inc, LLC, Corp, Consulting, Management
--   • Case-insensitive matching
--
-- RUN THIS IN SUPABASE SQL EDITOR
-- ============================================================================

-- Step 1: Create a helper function to normalize names for fuzzy matching
CREATE OR REPLACE FUNCTION normalize_name_for_matching(name TEXT)
RETURNS TEXT AS $$
BEGIN
  IF name IS NULL THEN
    RETURN '';
  END IF;
  
  -- Convert to lowercase and remove common business suffixes
  name := LOWER(name);
  name := REGEXP_REPLACE(name, '\m(inc|llc|corp|consulting|management|service|company)\M\.?', '', 'gi');
  
  -- Remove all punctuation and extra spaces
  name := REGEXP_REPLACE(name, '[,.\-&]', ' ', 'g');
  name := REGEXP_REPLACE(name, '\s+', ' ', 'g');
  name := TRIM(name);
  
  -- Get first meaningful word (at least 3 characters)
  name := SPLIT_PART(name, ' ', 1);
  
  RETURN name;
END;
$$ LANGUAGE plpgsql IMMUTABLE;

-- Step 2: Show unlinked payments with potential matches
WITH normalized_aliases AS (
  SELECT 
    s.id AS student_id,
    s.name AS student_name,
    normalize_name_for_matching(s.name) AS normalized_name,
    s.aliases,
    UNNEST(
      ARRAY_APPEND(
        STRING_TO_ARRAY(REGEXP_REPLACE(COALESCE(s.aliases, ''), '[\[\]"]', '', 'g'), ','),
        s.name
      )
    ) AS alias_raw
  FROM students s
),
processed_aliases AS (
  SELECT 
    student_id,
    student_name,
    normalized_name,
    aliases,
    TRIM(alias_raw) AS alias_clean,
    normalize_name_for_matching(TRIM(alias_raw)) AS alias_normalized
  FROM normalized_aliases
  WHERE TRIM(alias_raw) != ''
)
SELECT DISTINCT
  p.id AS payment_id,
  p.payer_name,
  p.amount,
  p.for_class,
  normalize_name_for_matching(p.payer_name) AS normalized_payer,
  pa.student_id AS matched_student_id,
  pa.student_name AS matched_student_name,
  pa.normalized_name AS normalized_student,
  pa.aliases,
  pa.alias_clean AS matched_alias,
  CASE 
    WHEN normalize_name_for_matching(p.payer_name) = pa.normalized_name THEN 'Direct Name Match'
    WHEN normalize_name_for_matching(p.payer_name) = pa.alias_normalized THEN 'Exact Alias Match'
    WHEN LENGTH(normalize_name_for_matching(p.payer_name)) >= 4 
         AND LENGTH(pa.alias_normalized) >= 4
         AND (
           normalize_name_for_matching(p.payer_name) = SUBSTRING(pa.alias_normalized, 1, LENGTH(normalize_name_for_matching(p.payer_name)))
           OR pa.alias_normalized = SUBSTRING(normalize_name_for_matching(p.payer_name), 1, LENGTH(pa.alias_normalized))
         ) THEN 'Fuzzy Alias Match'
    ELSE 'No Match'
  END AS match_type
FROM payments p
CROSS JOIN processed_aliases pa
WHERE p.student_id IS NULL
  AND p.linked_student_id IS NULL
  AND (
    -- Exact normalized match (name or alias)
    normalize_name_for_matching(p.payer_name) = pa.normalized_name
    OR normalize_name_for_matching(p.payer_name) = pa.alias_normalized
    -- Prefix match (minimum 4 chars to avoid false positives like "a" matching "ak")
    OR (
      LENGTH(normalize_name_for_matching(p.payer_name)) >= 4 
      AND LENGTH(pa.alias_normalized) >= 4
      AND (
        normalize_name_for_matching(p.payer_name) = SUBSTRING(pa.alias_normalized, 1, LENGTH(normalize_name_for_matching(p.payer_name)))
        OR pa.alias_normalized = SUBSTRING(normalize_name_for_matching(p.payer_name), 1, LENGTH(pa.alias_normalized))
      )
    )
  )
ORDER BY p.for_class DESC, p.payer_name, pa.student_name;

-- Step 3: AUTO-LINK payments (REVIEW THE ABOVE RESULTS FIRST!)
-- ⚠️ WARNING: This will update the payments table! Review Step 2 results before running.

WITH normalized_aliases AS (
  SELECT 
    s.id AS student_id,
    s.name AS student_name,
    UNNEST(
      ARRAY_APPEND(
        STRING_TO_ARRAY(REGEXP_REPLACE(COALESCE(s.aliases, ''), '[\[\]"]', '', 'g'), ','),
        s.name
      )
    ) AS alias_raw
  FROM students s
),
processed_aliases AS (
  SELECT 
    student_id,
    student_name,
    TRIM(alias_raw) AS alias_clean,
    normalize_name_for_matching(TRIM(alias_raw)) AS alias_normalized
  FROM normalized_aliases
  WHERE TRIM(alias_raw) != ''
),
matched_payments AS (
  SELECT DISTINCT ON (p.id)
    p.id AS payment_id,
    pa.student_id,
    pa.student_name
  FROM payments p
  CROSS JOIN processed_aliases pa
  WHERE 
    p.student_id IS NULL
    AND p.linked_student_id IS NULL
    AND (
      -- Exact normalized match
      normalize_name_for_matching(p.payer_name) = pa.alias_normalized
      -- OR prefix match (minimum 4 chars)
      OR (
        LENGTH(normalize_name_for_matching(p.payer_name)) >= 4 
        AND LENGTH(pa.alias_normalized) >= 4
        AND (
          normalize_name_for_matching(p.payer_name) = SUBSTRING(pa.alias_normalized, 1, LENGTH(normalize_name_for_matching(p.payer_name)))
          OR pa.alias_normalized = SUBSTRING(normalize_name_for_matching(p.payer_name), 1, LENGTH(pa.alias_normalized))
        )
      )
    )
  ORDER BY p.id, pa.student_id
)
UPDATE payments p
SET 
  student_id = mp.student_id::TEXT,
  linked_student_id = mp.student_id::TEXT,
  resolved_student_name = mp.student_name
FROM matched_payments mp
WHERE p.id = mp.payment_id;

-- Step 4: Verify results after running Step 3
SELECT 
  COUNT(*) AS total_unlinked_payments,
  COUNT(DISTINCT payer_name) AS unique_payer_names
FROM payments 
WHERE student_id IS NULL AND linked_student_id IS NULL;

-- Step 5: Drop the helper function (cleanup)
-- DROP FUNCTION IF EXISTS normalize_name_for_matching(TEXT);
