-- FIX: Husikyan Consulting Payment Not Matching
-- Problem: Alias contains periods which are rejected by CHECK constraint
-- Payment payer_name: "Husikyan Consulting, I.Nc."

-- STEP 1: Check current alias status
SELECT id, name, aliases, group_name 
FROM students 
WHERE name = 'Sona Husikyan';

-- STEP 2: Update alias to match payment (TEXT format, not JSONB!)
-- The aliases column is TEXT with comma separators, NOT JSONB
UPDATE students
SET aliases = 'Husikyan Consulting'
WHERE name = 'Sona Husikyan';

-- OR with multiple variations:
-- UPDATE students
-- SET aliases = 'Husikyan Consulting, Husikyan Consulting I Nc'
-- WHERE name = 'Sona Husikyan';

-- STEP 3: Verify the update
SELECT id, name, aliases, group_name 
FROM students 
WHERE name = 'Sona Husikyan';

-- STEP 4: Check if payment will now match
SELECT id, payer_name, amount, date, linked_student_id, resolved_student_name
FROM payments
WHERE payer_name ILIKE '%Husikyan Consulting%'
ORDER BY date DESC;

-- NOTES:
-- 1. The aliases column is TEXT (not JSONB!) with comma separators
--    Constraint: aliases_no_special_chars blocks: [ ] " ||| \
--    Allowed format: "Name1, Name2, Name3" (plain text with comma-space separator)
--
-- 2. Payment matching in Calendar.html uses fuzzy logic:
--    - Splits aliases on comma: aliases.split(',').map(a => a.trim())
--    - Checks if payment payer_name contains any alias
--    - Also checks resolved_student_name
--
-- 3. "Husikyan Consulting" will match "Husikyan Consulting, I.Nc." via substring match
