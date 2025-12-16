-- ═══════════════════════════════════════════════════════════════
-- DECEMBER 1-15 PAYMENT DEBUG QUERIES (FIXED FOR ACTUAL SCHEMA)
-- Run in Supabase SQL Editor to diagnose Calendar matching issues
--
-- PAYMENT MATCHING RULES:
-- - Calendar shows GREEN dot when: payments.student_id = students.id 
--                              AND payments.for_class = class date
-- - Calendar shows RED dot when: No matching payment found
-- - Calendar shows FUCHSIA dot when: Payment exists but for_class ≠ any class date
-- ═══════════════════════════════════════════════════════════════


-- QUERY 1: ALL Dec 1-15 payments with student info
-- Shows what payments exist and where they're allocated
-- ═══════════════════════════════════════════════════════════════
SELECT 
  p.id as payment_id,
  p.student_id,
  s.name as student_name,
  s.group_name,
  p.amount,
  p.date::date as paid_on,
  p.for_class as allocated_to,
  TO_CHAR(p.for_class, 'Day') as allocated_day,
  (p.for_class - p.date::date) as days_difference,
  p.status,
  -- Interpretation
  CASE 
    WHEN p.student_id IS NULL THEN '🔴 UNLINKED (no student_id)'
    WHEN p.for_class = p.date::date THEN '✅ Same-day payment'
    WHEN p.for_class > p.date::date THEN '📅 Advanced payment (paid early)'
    WHEN p.for_class < p.date::date THEN '⏪ Late payment (paid after class)'
  END as payment_type
FROM payments p
LEFT JOIN students s ON p.student_id::bigint = s.id
WHERE p.date >= '2025-12-01' AND p.date < '2025-12-16'
ORDER BY p.for_class, s.name;


-- QUERY 2: DUPLICATES - Multiple payments for same student + date
-- Calendar should show ERROR (yellow dots) for these
-- ═══════════════════════════════════════════════════════════════
SELECT 
  p.student_id,
  s.name as student_name,
  p.for_class,
  COUNT(*) as payment_count,
  array_agg(p.id) as payment_ids,
  array_agg(p.amount) as amounts,
  SUM(p.amount) as total_amount
FROM payments p
LEFT JOIN students s ON p.student_id::bigint = s.id
WHERE p.date >= '2025-12-01' AND p.date < '2025-12-16'
  AND p.student_id IS NOT NULL
GROUP BY p.student_id, s.name, p.for_class
HAVING COUNT(*) > 1
ORDER BY p.for_class, s.name;


-- QUERY 3: UNLINKED payments (no student_id)
-- Calendar should show Type A FUCHSIA dots (truly unlinked)
-- ═══════════════════════════════════════════════════════════════
SELECT 
  p.id as payment_id,
  p.payer_name,
  p.amount,
  p.date::date as paid_on,
  p.for_class as allocated_to,
  p.status,
  p.resolved_student_name,
  -- Suggestions for linking
  (
    SELECT string_agg(s.name || ' (ID: ' || s.id || ')', ', ')
    FROM students s
    WHERE s.name ILIKE '%' || COALESCE(p.payer_name, p.resolved_student_name, '') || '%'
       OR COALESCE(p.payer_name, p.resolved_student_name, '') ILIKE '%' || s.name || '%'
  ) as possible_matches
FROM payments p
WHERE p.date >= '2025-12-01' AND p.date < '2025-12-16'
  AND p.student_id IS NULL
ORDER BY p.for_class;


-- QUERY 4: DATE MISMATCHES (for_class ≠ payment date)
-- These are reassigned payments - check if reassignment makes sense
-- ═══════════════════════════════════════════════════════════════
SELECT 
  p.id,
  s.name as student_name,
  s.group_name,
  p.date::date as paid_on,
  TO_CHAR(p.date, 'Day') as paid_day,
  p.for_class as allocated_to,
  TO_CHAR(p.for_class, 'Day') as allocated_day,
  (p.for_class - p.date::date) as days_diff,
  p.amount
FROM payments p
LEFT JOIN students s ON p.student_id::bigint = s.id
WHERE p.date >= '2025-12-01' AND p.date < '2025-12-16'
  AND p.for_class != p.date::date
  AND p.student_id IS NOT NULL
ORDER BY ABS(p.for_class - p.date::date) DESC, s.name;


-- QUERY 5: PAYMENTS BY DATE (for_class grouping)
-- Shows which dates have payments allocated to them
-- ═══════════════════════════════════════════════════════════════
SELECT 
  p.for_class,
  TO_CHAR(p.for_class, 'Day') as day_of_week,
  COUNT(*) as total_payments,
  COUNT(DISTINCT p.student_id) as unique_students,
  SUM(p.amount) as total_amount,
  string_agg(DISTINCT s.name, ', ' ORDER BY s.name) as students
FROM payments p
LEFT JOIN students s ON p.student_id::bigint = s.id
WHERE p.for_class >= '2025-12-01' AND p.for_class < '2025-12-16'
GROUP BY p.for_class
ORDER BY p.for_class;


-- QUERY 6: STUDENTS with MULTIPLE payments in Dec 1-15
-- Helps identify prepayment patterns or data issues
-- ═══════════════════════════════════════════════════════════════
SELECT 
  s.name as student_name,
  s.group_name,
  COUNT(*) as payment_count,
  array_agg(p.for_class ORDER BY p.for_class) as allocated_dates,
  array_agg(p.amount ORDER BY p.for_class) as amounts,
  SUM(p.amount) as total_paid
FROM payments p
JOIN students s ON p.student_id::bigint = s.id
WHERE p.date >= '2025-12-01' AND p.date < '2025-12-16'
GROUP BY s.name, s.group_name, p.student_id
HAVING COUNT(*) > 1
ORDER BY COUNT(*) DESC, s.name;


-- ═══════════════════════════════════════════════════════════════
-- INTERPRETATION GUIDE:
--
-- Query 1: Overview of all payments
--   - Look for UNLINKED payments (need to assign student_id)
--   - Check if for_class dates make sense (should match class schedule)
--
-- Query 2: Duplicates (CRITICAL ERROR)
--   - Should return ZERO rows if unique constraint is working
--   - If rows appear: Delete duplicate or fix trigger
--
-- Query 3: Unlinked payments
--   - ~8-10 expected (Venmo/Zelle without name match)
--   - Use "possible_matches" to manually link them
--
-- Query 4: Reassigned payments
--   - Check if reassignments are valid (paid early vs paid late)
--   - Verify student actually has class on allocated_to date
--
-- Query 5: Daily summary
--   - Compare with Calendar grid - does student count match?
--   - Check if day_of_week matches student's group schedule
--
-- Query 6: Students with multiple payments
--   - Normal if student pays weekly
--   - Abnormal if student has 3+ payments in 2 weeks
-- ═══════════════════════════════════════════════════════════════
