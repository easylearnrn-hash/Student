-- Fix start_date for students who were unpaused on 2026-06-17.
-- The portal uses start_date as the debt floor — any class before this date
-- is excluded from the unpaid total and payment history rows.
-- Run this once in the Supabase SQL Editor.

UPDATE students
SET start_date = '2026-06-17'
WHERE name IN ('Janna Avetikyan', 'Anna Karamyan');
