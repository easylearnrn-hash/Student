-- PART 2: WRONG DAY DETECTION
-- Identifies payments allocated to days that DON'T match the student's group schedule

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
  CASE WHEN sp.payment_day_trimmed = ANY(gcd.class_days) THEN 1 ELSE 0 END, -- Wrong days first
  sp.group_name,
  sp.student_name,
  sp.payment_date;
