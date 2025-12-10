-- ========================================
-- REORDER 24 FOLDERS: Set sort_order to 1-24
-- ========================================
-- This updates the sort_order to match your desired sequence

-- Based on your expected order:
-- 1. Medical Terminology
-- 2. Human Anatomy
-- 3. Medication Suffixes and Drug Classes
-- 4. Cardiovascular System
-- 5. Endocrine System
-- 6. Gastrointestinal & Hepatic System
-- 7. Respiratory System
-- 8. Renal
-- 9. Fluids, Electrolytes & Nutrition
-- 10. Eye Disorders
-- 11. EENT
-- 12. Burns and Skin
-- 13. Reproductive and Sexual Health System
-- 14. Maternal Health
-- 15. Pediatrics
-- 16. Medical-Surgical Care
-- 17. Mental Health
-- 18. Autoimmune & Infectious Disorders
-- 19. Neurology
-- 20. Cancer
-- 21. Musculoskeletal Disorders
-- 22. Psycho-Social Aspects
-- 23. Nursing Skills and Fundamentals
-- 24. Pharmacology

-- Run each UPDATE separately to avoid timeout:

-- #1
UPDATE note_folders SET sort_order = 1 WHERE folder_name = 'Medical Terminology' AND group_letter IS NULL;

-- #2
UPDATE note_folders SET sort_order = 2 WHERE folder_name = 'Human Anatomy' AND group_letter IS NULL;

-- #3
UPDATE note_folders SET sort_order = 3 WHERE folder_name = 'Medication Suffixes and Drug Classes' AND group_letter IS NULL;

-- #4
UPDATE note_folders SET sort_order = 4 WHERE folder_name = 'Cardiovascular System' AND group_letter IS NULL;

-- #5
UPDATE note_folders SET sort_order = 5 WHERE folder_name = 'Endocrine System' AND group_letter IS NULL;

-- #6
UPDATE note_folders SET sort_order = 6 WHERE folder_name = 'Gastrointestinal & Hepatic System' AND group_letter IS NULL;

-- #7
UPDATE note_folders SET sort_order = 7 WHERE folder_name = 'Respiratory System' AND group_letter IS NULL;

-- #8
UPDATE note_folders SET sort_order = 8 WHERE folder_name = 'Renal' AND group_letter IS NULL;

-- #9
UPDATE note_folders SET sort_order = 9 WHERE folder_name = 'Fluids, Electrolytes & Nutrition' AND group_letter IS NULL;

-- #10
UPDATE note_folders SET sort_order = 10 WHERE folder_name = 'Eye Disorders' AND group_letter IS NULL;

-- #11
UPDATE note_folders SET sort_order = 11 WHERE folder_name = 'EENT' AND group_letter IS NULL;

-- #12
UPDATE note_folders SET sort_order = 12 WHERE folder_name = 'Burns and Skin' AND group_letter IS NULL;

-- #13
UPDATE note_folders SET sort_order = 13 WHERE folder_name = 'Reproductive and Sexual Health System' AND group_letter IS NULL;

-- #14
UPDATE note_folders SET sort_order = 14 WHERE folder_name = 'Maternal Health' AND group_letter IS NULL;

-- #15
UPDATE note_folders SET sort_order = 15 WHERE folder_name = 'Pediatrics' AND group_letter IS NULL;

-- #16
UPDATE note_folders SET sort_order = 16 WHERE folder_name = 'Medical-Surgical Care' AND group_letter IS NULL;

-- #17
UPDATE note_folders SET sort_order = 17 WHERE folder_name = 'Mental Health' AND group_letter IS NULL;

-- #18
UPDATE note_folders SET sort_order = 18 WHERE folder_name = 'Autoimmune & Infectious Disorders' AND group_letter IS NULL;

-- #19
UPDATE note_folders SET sort_order = 19 WHERE folder_name = 'Neurology' AND group_letter IS NULL;

-- #20
UPDATE note_folders SET sort_order = 20 WHERE folder_name = 'Cancer' AND group_letter IS NULL;

-- #21
UPDATE note_folders SET sort_order = 21 WHERE folder_name = 'Musculoskeletal Disorders' AND group_letter IS NULL;

-- #22
UPDATE note_folders SET sort_order = 22 WHERE folder_name = 'Psycho-Social Aspects' AND group_letter IS NULL;

-- #23
UPDATE note_folders SET sort_order = 23 WHERE folder_name = 'Nursing Skills and Fundamentals' AND group_letter IS NULL;

-- #24
UPDATE note_folders SET sort_order = 24 WHERE folder_name = 'Pharmacology' AND group_letter IS NULL;


-- ========================================
-- VERIFY: Check final order
-- ========================================
SELECT 
  sort_order,
  folder_name,
  LOWER(REGEXP_REPLACE(folder_name, ' System$', '', 'i')) as normalized_name
FROM note_folders
WHERE deleted_at IS NULL
  AND group_letter IS NULL
ORDER BY sort_order;

-- Expected: 24 rows, sort_order 1-24 in your exact sequence
