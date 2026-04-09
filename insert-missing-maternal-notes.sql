-- ============================================================
-- Insert missing HTML-only Maternal Health notes into student_notes
-- Run this in the Supabase SQL Editor
-- These notes have no PDF — the student portal resolves them
-- by title to the correct HTML file automatically.
-- ============================================================

INSERT INTO student_notes
  (title, description, group_name, category, system_category, class_date, pdf_url, file_name, file_size, requires_payment, is_system_note, deleted)
VALUES
  (
    'BPP and CST',
    'Biophysical Profile and Contraction Stress Test — antepartum fetal surveillance, scoring, results, and NCLEX priorities',
    'Maternal Health',
    'Maternal Health',
    'Maternal Health',
    '2026-04-09',
    '', '', 0,
    true, true, false
  ),
  (
    'Nonstress Test NST',
    'Nonstress Test — fetal heart rate monitoring, reactive vs nonreactive results, and NCLEX priorities',
    'Maternal Health',
    'Maternal Health',
    'Maternal Health',
    '2026-04-09',
    '', '', 0,
    true, true, false
  ),
  (
    'Antepartum Care',
    'Prenatal visits, labs, fundal height, fetal monitoring, and NCLEX priorities',
    'Maternal Health',
    'Maternal Health',
    'Maternal Health',
    '2026-04-09',
    '', '', 0,
    true, true, false
  )
ON CONFLICT DO NOTHING;
