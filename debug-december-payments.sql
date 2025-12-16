-- ═══════════════════════════════════════════════════════════════
-- DEBUG DECEMBER 1-15 PAYMENTS
-- Run these queries in Supabase SQL Editor
-- ═══════════════════════════════════════════════════════════════

-- QUERY 1: All payments from Dec 1-15 with student info
-- Shows: payment date, for_class date, student name, amount, status
-- ═══════════════════════════════════════════════════════════════
SELECT 
  p.id,
  p.student_id,
  s.name as student_name,
  p.amount,
  p.date as receipt_date,
  p.for_class,
  p.status,
  -- Check if dates match
  CASE 
    WHEN p.for_class = p.date::date THEN '✅ Match'
    ELSE '⚠️ Mismatch'
  END as date_match
FROM payments p
LEFT JOIN students s ON p.student_id::bigint = s.id
WHERE p.date >= '2025-12-01' AND p.date < '2025-12-16'
ORDER BY p.date, s.name;


-- QUERY 2: Find students with classes on Dec 1-15
-- Shows which students SHOULD have classes each day
-- ═══════════════════════════════════════════════════════════════
WITH december_dates AS (
  SELECT generate_series(
    '2025-12-01'::date,
    '2025-12-15'::date,
    '1 day'::interval
  )::date as class_date
)
SELECT 
  dd.class_date,
  s.id as student_id,
  s.name as student_name,
  s.group_letter,
  -- Check if payment exists
  CASE 
    WHEN p.id IS NOT NULL THEN '💰 Has Payment'
    ELSE '❌ No Payment'
  END as payment_status,
  p.amount,
  p.for_class as payment_for_class
FROM december_dates dd
CROSS JOIN students s
LEFT JOIN payments p ON p.student_id::bigint = s.id AND p.for_class = dd.class_date
WHERE s.show_in_grid = true
  AND EXTRACT(DOW FROM dd.class_date) = ANY(
    CASE s.group_letter
      WHEN 'A' THEN ARRAY[1, 3, 5]  -- Mon, Wed, Fri
      WHEN 'B' THEN ARRAY[2, 4, 6]  -- Tue, Thu, Sat
      WHEN 'C' THEN ARRAY[0]         -- Sunday
      WHEN 'D' THEN ARRAY[1, 3, 5]  -- Mon, Wed, Fri
      WHEN 'E' THEN ARRAY[2, 4]     -- Tue, Thu
      WHEN 'F' THEN ARRAY[6]         -- Saturday
      ELSE ARRAY[]::integer[]
    END
  )
ORDER BY dd.class_date, s.name;


-- QUERY 3: Find MISMATCHES - Payments where for_class != receipt date
-- These are the problematic ones Calendar might be missing
-- ═══════════════════════════════════════════════════════════════
SELECT 
  p.id,
  s.name as student_name,
  p.amount,
  p.date::date as receipt_date,
  p.for_class,
  (p.for_class - p.date::date) as days_difference
FROM payments p
LEFT JOIN students s ON p.student_id::bigint = s.id
WHERE p.date >= '2025-12-01' AND p.date < '2025-12-16'
  AND p.for_class != p.date::date
ORDER BY p.for_class, s.name;


-- QUERY 4: Find DUPLICATES - Multiple payments for same student+date
-- Calendar should show ERROR (yellow dots) for these
-- ═══════════════════════════════════════════════════════════════
SELECT 
  p.student_id,
  s.name as student_name,
  p.for_class,
  COUNT(*) as payment_count,
  array_agg(p.id) as payment_ids,
  array_agg(p.amount) as amounts
FROM payments p
LEFT JOIN students s ON p.student_id::bigint = s.id
WHERE p.date >= '2025-12-01' AND p.date < '2025-12-16'
  AND p.student_id IS NOT NULL
GROUP BY p.student_id, s.name, p.for_class
HAVING COUNT(*) > 1
ORDER BY p.for_class, s.name;


-- QUERY 5: Unlinked payments (student_id IS NULL)
-- Calendar should show FUCHSIA Type A dots for these
-- ═══════════════════════════════════════════════════════════════
SELECT 
  p.id,
  p.payer_name,
  p.amount,
  p.date as receipt_date,
  p.for_class,
  p.status,
  p.resolved_student_name
FROM payments p
WHERE p.date >= '2025-12-01' AND p.date < '2025-12-16'
  AND p.student_id IS NULL
ORDER BY p.for_class;


-- QUERY 6: Payments for non-class days (student has no class on for_class date)
-- Calendar should show FUCHSIA Type B dots for these
-- ═══════════════════════════════════════════════════════════════
SELECT 
  p.id,
  s.id as student_id,
  s.name as student_name,
  s.group_letter,
  p.for_class,
  EXTRACT(DOW FROM p.for_class) as day_of_week,
  p.amount,
  -- Show expected class days for this group
  CASE s.group_letter
    WHEN 'A' THEN 'Mon/Wed/Fri (1,3,5)'
    WHEN 'B' THEN 'Tue/Thu/Sat (2,4,6)'
    WHEN 'C' THEN 'Sunday (0)'
    WHEN 'D' THEN 'Mon/Wed/Fri (1,3,5)'
    WHEN 'E' THEN 'Tue/Thu (2,4)'
    WHEN 'F' THEN 'Saturday (6)'
    ELSE 'No group'
  END as expected_days
FROM payments p
JOIN students s ON p.student_id::bigint = s.id
WHERE p.date >= '2025-12-01' AND p.date < '2025-12-16'
  AND s.show_in_grid = true
  AND NOT (
    EXTRACT(DOW FROM p.for_class) = ANY(
      CASE s.group_letter
        WHEN 'A' THEN ARRAY[1, 3, 5]
        WHEN 'B' THEN ARRAY[2, 4, 6]
        WHEN 'C' THEN ARRAY[0]
        WHEN 'D' THEN ARRAY[1, 3, 5]
        WHEN 'E' THEN ARRAY[2, 4]
        WHEN 'F' THEN ARRAY[6]
        ELSE ARRAY[]::integer[]
      END
    )
  )
ORDER BY p.for_class, s.name;
