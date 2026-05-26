-- ============================================================
-- FIX: Hasmik Hayrapetyan — "No group assigned" in portal
-- Run in Supabase SQL Editor
-- ============================================================

-- STEP 1: See ALL Hasmik records (look for duplicates / missing group_name)
SELECT id, name, email, auth_user_id, group_name, price_per_class, status
FROM students
WHERE lower(name) LIKE '%hasmik%'
   OR lower(name) LIKE '%hayrapetyan%'
ORDER BY id;

-- ============================================================
-- STEP 2: Sync group_name onto whichever record the portal loads (has auth_user_id).
-- Copies from the other record (the one Student Manager edits) regardless of
-- whether the portal record already had a group — fixes stale group after SM update.
-- ============================================================
UPDATE students portal_rec
SET
  group_name      = source_rec.group_name,
  price_per_class = COALESCE(source_rec.price_per_class, portal_rec.price_per_class)
FROM students source_rec
WHERE
  -- portal record: the one the portal loads (has auth_user_id)
  lower(portal_rec.name) LIKE '%hasmik%'
  AND portal_rec.auth_user_id IS NOT NULL
  -- source record: different row, same person, has a different group_name (= the SM edit)
  AND lower(source_rec.name) LIKE '%hasmik%'
  AND source_rec.group_name IS NOT NULL
  AND source_rec.group_name != ''
  AND source_rec.id != portal_rec.id
  AND source_rec.group_name IS DISTINCT FROM portal_rec.group_name
RETURNING portal_rec.id, portal_rec.name, portal_rec.auth_user_id, portal_rec.group_name, portal_rec.price_per_class;

-- ============================================================
-- STEP 3: PERMANENT FIX — Delete the duplicate record (no auth_user_id).
-- After this, Student Manager and the portal edit the SAME row — no more sync issues.
-- ⚠️ Only run AFTER Step 2 succeeds and the VERIFICATION query shows correct group_name.
-- ============================================================
-- DELETE FROM students
-- WHERE lower(name) LIKE '%hasmik%'
--   AND auth_user_id IS NULL
-- RETURNING id, name, email, group_name;

-- VERIFICATION
SELECT id, name, email, auth_user_id, group_name, price_per_class
FROM students
WHERE lower(name) LIKE '%hasmik%'
   OR lower(name) LIKE '%hayrapetyan%'
ORDER BY id;
