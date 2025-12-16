-- COMPREHENSIVE DECEMBER 1-15 PAYMENT ANALYSIS FOR ALL GROUPS
-- Groups: A, C, D, E
-- Date Range: 2025-12-01 to 2025-12-15

-- Part 1: Show ALL students with their payments and class schedule
SELECT 
  s.id as student_id,
  s.name as student_name,
  s.group_name,
  g.schedule as group_schedule,
  COUNT(p.id) as payment_count,
  ARRAY_AGG(p.for_class ORDER BY p.for_class) FILTER (WHERE p.for_class IS NOT NULL) as payment_dates,
  ARRAY_AGG(p.amount ORDER BY p.for_class) FILTER (WHERE p.for_class IS NOT NULL) as payment_amounts,
  ARRAY_AGG(p.id ORDER BY p.for_class) FILTER (WHERE p.for_class IS NOT NULL) as payment_ids
FROM students s
LEFT JOIN groups g ON g.group_name = s.group_name
LEFT JOIN payments p ON p.student_id::bigint = s.id 
  AND p.for_class >= '2025-12-01' 
  AND p.for_class <= '2025-12-15'
WHERE s.group_name IN ('A', 'C', 'D', 'E')
  AND s.show_in_grid = true
GROUP BY s.id, s.name, s.group_name, g.schedule
ORDER BY s.group_name, s.name;

-- Part 2: Identify MISMATCHES (payments on wrong days for their group)
-- This will show students whose payment dates DON'T align with their group schedule

WITH group_class_days AS (
  SELECT 
    'A' as group_name,
    ARRAY['Tuesday', 'Thursday'] as class_days
  UNION ALL
  SELECT 'C', ARRAY['Monday', 'Friday']
  UNION ALL
  SELECT 'D', ARRAY['Monday', 'Wednesday', 'Sunday']
  UNION ALL
  SELECT 'E', ARRAY['Friday', 'Sunday']
),
student_payments AS (
  SELECT 
    s.id as student_id,
    s.name as student_name,
    s.group_name,
    p.for_class as payment_date,
    TO_CHAR(p.for_class, 'Day') as payment_day_name,
    TRIM(TO_CHAR(p.for_class, 'Day')) as payment_day_trimmed,
    p.amount,
    p.id as payment_id
  FROM students s
  JOIN payments p ON p.student_id::bigint = s.id
  WHERE s.group_name IN ('A', 'C', 'D', 'E')
    AND s.show_in_grid = true
    AND p.for_class >= '2025-12-01'
    AND p.for_class <= '2025-12-15'
)
SELECT 
  sp.student_name,
  sp.group_name,
  gcd.class_days as expected_days,
  sp.payment_date,
  sp.payment_day_trimmed as actual_day,
  sp.amount,
  sp.payment_id,
  CASE 
    WHEN sp.payment_day_trimmed = ANY(gcd.class_days) THEN '✅ CORRECT'
    ELSE '❌ WRONG DAY'
  END as status
FROM student_payments sp
JOIN group_class_days gcd ON gcd.group_name = sp.group_name
ORDER BY 
  sp.group_name,
  sp.student_name,
  sp.payment_date;

-- Part 3: Check for ABSENCES that would explain RED dots
SELECT 
  s.name as student_name,
  s.group_name,
  sa.class_date as absent_date,
  TO_CHAR(sa.class_date, 'Day') as absent_day,
  CASE 
    WHEN p.id IS NOT NULL THEN '⚠️ PAID BUT ABSENT (shows RED + FUCHSIA)'
    ELSE 'Not paid'
  END as payment_status
FROM student_absences sa
JOIN students s ON s.id = sa.student_id
LEFT JOIN payments p ON p.student_id::bigint = s.id 
  AND p.for_class = sa.class_date
WHERE s.group_name IN ('A', 'C', 'D', 'E')
  AND sa.class_date >= '2025-12-01'
  AND sa.class_date <= '2025-12-15'
ORDER BY s.group_name, s.name, sa.class_date;

-- Part 4: Summary - Payment count by group and date
SELECT 
  s.group_name,
  p.for_class,
  TO_CHAR(p.for_class, 'Day') as day_name,
  COUNT(DISTINCT s.id) as student_count,
  SUM(p.amount) as total_amount,
  STRING_AGG(s.name, ', ' ORDER BY s.name) as students
FROM payments p
JOIN students s ON p.student_id::bigint = s.id
WHERE s.group_name IN ('A', 'C', 'D', 'E')
  AND p.for_class >= '2025-12-01'
  AND p.for_class <= '2025-12-15'
GROUP BY s.group_name, p.for_class
ORDER BY s.group_name, p.for_class;
