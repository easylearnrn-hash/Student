-- ============================================================
-- CALENDAR PERFORMANCE FIX: Add date indexes for loadPayments()
-- 
-- Issue: Calendar.html loadPayments() takes 872ms (95% of init time)
-- Root Cause: Missing indexes on date columns used for filtering
-- Expected Improvement: 872ms → <50ms (17× faster!)
-- 
-- Date: January 2025
-- ============================================================

-- Index for payments table (for_class column)
-- Used by: loadPayments() line 6679-6680
-- Query: .gte('for_class', startDate).lte('for_class', endDate)
CREATE INDEX IF NOT EXISTS idx_payments_for_class 
ON payments(for_class DESC);

-- Index for payment_records table (date column)
-- Used by: loadPayments() line 6696-6697  
-- Query: .gte('date', startDate).lte('date', endDate)
CREATE INDEX IF NOT EXISTS idx_payment_records_date 
ON payment_records(date DESC);

-- Composite index for common query pattern (student + date)
-- Used by: Student-specific payment queries across the app
CREATE INDEX IF NOT EXISTS idx_payments_student_date 
ON payments(student_id, for_class DESC);

CREATE INDEX IF NOT EXISTS idx_payment_records_student_date 
ON payment_records(student_id, date DESC);

-- Add index on linked_student_id for payment matching logic
-- Used by: Payment-Records.html payment matching (line ~2000+)
CREATE INDEX IF NOT EXISTS idx_payments_linked_student 
ON payments(linked_student_id);

-- Add index on payer_name for alias matching
-- Used by: Payment matching by payer name
CREATE INDEX IF NOT EXISTS idx_payments_payer_name 
ON payments(payer_name);

-- Analyze tables to update query planner statistics
ANALYZE payments;
ANALYZE payment_records;

-- ============================================================
-- VERIFICATION QUERY
-- Run this to confirm indexes were created:
-- ============================================================
/*
SELECT 
  schemaname,
  tablename,
  indexname,
  indexdef
FROM pg_indexes
WHERE tablename IN ('payments', 'payment_records')
  AND indexname LIKE 'idx_%'
ORDER BY tablename, indexname;
*/

-- ============================================================
-- PERFORMANCE TEST QUERY
-- Run this to test index performance:
-- ============================================================
/*
EXPLAIN ANALYZE
SELECT * FROM payments
WHERE for_class >= '2024-11-01'
  AND for_class <= '2025-04-30'
ORDER BY for_class DESC;

-- Before indexes: "Seq Scan on payments" (slow)
-- After indexes: "Index Scan using idx_payments_for_class" (fast!)
*/
