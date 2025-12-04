-- ========================================================
-- COMPREHENSIVE PAYMENT MATCHING SCRIPT
-- ========================================================
-- Matches unmatched payments to students using multiple strategies
-- ========================================================

-- STRATEGY 1: Match by student_name field (most reliable)
UPDATE payments p
SET 
  linked_student_id = s.id,
  resolved_student_name = s.name,
  status = 'matched'
FROM students s
WHERE p.status = 'unmatched'
  AND p.linked_student_id IS NULL
  AND p.student_name IS NOT NULL
  AND p.student_name != ''
  AND s.name ILIKE '%' || p.student_name || '%';

-- STRATEGY 2: Match payer_name to student name (direct match)
UPDATE payments p
SET 
  linked_student_id = s.id,
  resolved_student_name = s.name,
  status = 'matched'
FROM students s
WHERE p.status = 'unmatched'
  AND p.linked_student_id IS NULL
  AND s.name ILIKE '%' || p.payer_name || '%';

-- STRATEGY 3: Specific business name mappings (manual overrides)
-- Scins Inc → Anna Ohanjanyan
UPDATE payments
SET 
  linked_student_id = (SELECT id FROM students WHERE name ILIKE '%Anna%Ohanjanyan%' OR name ILIKE '%Anna%Ohanjanya%' LIMIT 1),
  resolved_student_name = 'Anna Ohanjanyan',
  status = 'matched'
WHERE payer_name = 'Scins Inc'
  AND status = 'unmatched';

-- Hgg Medical Consulting → Gohar Hovhannisyan
UPDATE payments
SET 
  linked_student_id = (SELECT id FROM students WHERE name ILIKE '%Gohar%Hovhannisyan%' LIMIT 1),
  resolved_student_name = 'Gohar Hovhannisyan',
  status = 'matched'
WHERE payer_name = 'Hgg Medical Consulting'
  AND status = 'unmatched';

-- Alexis Color Bar → (need to identify student - check Payment Records)
-- N & D Marketing Service Inc → (need to identify)
-- Husikyan Consulting, I.Nc. → Sona Husikyan
UPDATE payments
SET 
  linked_student_id = (SELECT id FROM students WHERE name ILIKE '%Sona%Husikyan%' LIMIT 1),
  resolved_student_name = 'Sona Husikyan',
  status = 'matched'
WHERE payer_name = 'Husikyan Consulting, I.Nc.'
  AND status = 'unmatched';

-- Zg Consulting, I.Nc. → Gayane Zadourian (already has student_name)
-- Greg Arustamyan → Zara
UPDATE payments
SET 
  linked_student_id = (SELECT id FROM students WHERE name ILIKE '%Zara%' OR name ILIKE '%Arus%' LIMIT 1),
  resolved_student_name = (SELECT name FROM students WHERE name ILIKE '%Zara%' OR name ILIKE '%Arus%' LIMIT 1),
  status = 'matched'
WHERE payer_name = 'Greg Arustamyan'
  AND status = 'unmatched';

-- Ak Quality Nursing, Inc → (need to identify)
-- H&a Home Health Care Inc → (need to identify)
-- Level Up Management, Inc → Hasmik Antonova (some have student_name)
UPDATE payments
SET 
  linked_student_id = (SELECT id FROM students WHERE name ILIKE '%Hasmik%Antonova%' LIMIT 1),
  resolved_student_name = 'Hasmik Antonova',
  status = 'matched'
WHERE payer_name = 'Level Up Management, Inc'
  AND status = 'unmatched';

-- Abraham Poghosyan → Mari Poghosyan (family member)
UPDATE payments
SET 
  linked_student_id = (SELECT id FROM students WHERE name ILIKE '%Mari%Poghosyan%' LIMIT 1),
  resolved_student_name = 'Mari Poghosyan',
  status = 'matched'
WHERE payer_name = 'Abraham Poghosyan'
  AND status = 'unmatched';

-- Stepan Gevorgyan → Mariam Gevorgyan
UPDATE payments
SET 
  linked_student_id = (SELECT id FROM students WHERE name ILIKE '%Mariam%Gevorgyan%' OR name ILIKE '%Mari%Gevorgyan%' LIMIT 1),
  resolved_student_name = (SELECT name FROM students WHERE name ILIKE '%Mariam%Gevorgyan%' OR name ILIKE '%Mari%Gevorgyan%' LIMIT 1),
  status = 'matched'
WHERE payer_name = 'Stepan Gevorgyan'
  AND status = 'unmatched';

-- Suren Nikoghosyan → Ani Sahakyan
UPDATE payments
SET 
  linked_student_id = (SELECT id FROM students WHERE name ILIKE '%Ani%Sahakyan%' LIMIT 1),
  resolved_student_name = 'Ani Sahakyan',
  status = 'matched'
WHERE payer_name = 'Suren Nikoghosyan'
  AND status = 'unmatched';

-- Artyom Khachatryan → (rent payments - need to identify student)
-- Beatrisa Arushanian → (already has student_name ARUSHANIAN BEATRISA)
UPDATE payments
SET 
  linked_student_id = (SELECT id FROM students WHERE name ILIKE '%Beatrisa%' OR name ILIKE '%Arushanian%' LIMIT 1),
  resolved_student_name = (SELECT name FROM students WHERE name ILIKE '%Beatrisa%' OR name ILIKE '%Arushanian%' LIMIT 1),
  status = 'matched'
WHERE payer_name = 'Beatrisa Arushanian'
  AND status = 'unmatched';

-- Agapi Nazarovna Sukiasyan → (need to identify)
-- Agk Plumbing Llc → (need to identify)
-- Erx Medical Clinic, Inc → (need to identify)
-- Sofya Grigoryan → (might be student herself)
UPDATE payments
SET 
  linked_student_id = (SELECT id FROM students WHERE name ILIKE '%Sofya%Grigoryan%' LIMIT 1),
  resolved_student_name = 'Sofya Grigoryan',
  status = 'matched'
WHERE payer_name = 'Sofya Grigoryan'
  AND status = 'unmatched';

-- Aram Harutyunyan → (might be student)
UPDATE payments
SET 
  linked_student_id = (SELECT id FROM students WHERE name ILIKE '%Aram%Harutyunyan%' LIMIT 1),
  resolved_student_name = 'Aram Harutyunyan',
  status = 'matched'
WHERE payer_name = 'Aram Harutyunyan'
  AND status = 'unmatched';

-- Naira Boshyan → (might be student)
UPDATE payments
SET 
  linked_student_id = (SELECT id FROM students WHERE name ILIKE '%Naira%Boshyan%' LIMIT 1),
  resolved_student_name = 'Naira Boshyan',
  status = 'matched'
WHERE payer_name = 'Naira Boshyan'
  AND status = 'unmatched';

-- Ani Abovian → (might be student)
UPDATE payments
SET 
  linked_student_id = (SELECT id FROM students WHERE name ILIKE '%Ani%Abovian%' LIMIT 1),
  resolved_student_name = 'Ani Abovian',
  status = 'matched'
WHERE payer_name = 'Ani Abovian'
  AND status = 'unmatched';

-- Verify results
SELECT 
  COUNT(*) FILTER (WHERE status = 'matched') as matched_count,
  COUNT(*) FILTER (WHERE status = 'unmatched') as unmatched_count,
  COUNT(*) FILTER (WHERE linked_student_id IS NOT NULL) as linked_count,
  COUNT(*) as total_payments
FROM payments;

-- Show remaining unmatched (businesses we couldn't identify)
SELECT DISTINCT
  payer_name,
  COUNT(*) as payment_count,
  SUM(amount) as total_amount
FROM payments
WHERE status = 'unmatched'
GROUP BY payer_name
ORDER BY payment_count DESC;
