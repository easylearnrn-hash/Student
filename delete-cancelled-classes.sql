-- Delete cancelled classes for Dec 3, Dec 4, and Dec 5 (Group C only)
-- Run this in Supabase SQL Editor

-- Delete Dec 3, 2025 cancellations (Groups A and D - Wednesday classes)
DELETE FROM skipped_classes
WHERE class_date = '2025-12-03'
  AND group_name IN ('Group A', 'Group D');

-- Delete Dec 4, 2025 cancellations (Groups A and D - Thursday classes)
DELETE FROM skipped_classes
WHERE class_date = '2025-12-04'
  AND group_name IN ('Group A', 'Group D');

-- Delete Dec 5, 2025 cancellation (Group C only - Friday class)
DELETE FROM skipped_classes
WHERE class_date = '2025-12-05'
  AND group_name = 'Group C';

-- Verify deletion (should return 0 rows)
SELECT * FROM skipped_classes
WHERE class_date IN ('2025-12-03', '2025-12-04', '2025-12-05')
  AND (
    (class_date = '2025-12-03' AND group_name IN ('Group A', 'Group D'))
    OR (class_date = '2025-12-04' AND group_name IN ('Group A', 'Group D'))
    OR (class_date = '2025-12-05' AND group_name = 'Group C')
  );
