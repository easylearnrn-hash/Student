-- Add first_name, last_name, preferred_language columns to subscribers table
-- These make it easy to convert a subscriber to a real student without re-entering data

ALTER TABLE subscribers
  ADD COLUMN IF NOT EXISTS first_name TEXT,
  ADD COLUMN IF NOT EXISTS last_name  TEXT,
  ADD COLUMN IF NOT EXISTS preferred_language TEXT;

-- Back-fill full_name for any existing rows that already have it
-- (new inserts will populate all four columns)
