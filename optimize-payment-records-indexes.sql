-- ⚡ LIGHTNING-FAST PAYMENT RECORDS - DATABASE INDEX OPTIMIZATION
-- Run this in Supabase SQL Editor to create indexes for maximum performance
-- These indexes will make Payment Records load at blazing speed

-- 1️⃣ Index on email_date for fast date sorting (most critical)
CREATE INDEX IF NOT EXISTS idx_payments_email_date_desc 
ON payments (email_date DESC NULLS LAST);

-- 2️⃣ Index on created_at as secondary sort
CREATE INDEX IF NOT EXISTS idx_payments_created_at_desc 
ON payments (created_at DESC NULLS LAST);

-- 3️⃣ Composite index for the exact query pattern used in Payment Records
CREATE INDEX IF NOT EXISTS idx_payments_composite_sort 
ON payments (email_date DESC NULLS LAST, created_at DESC NULLS LAST);

-- 4️⃣ Index on student_id for quick student lookups
CREATE INDEX IF NOT EXISTS idx_payments_student_id 
ON payments (student_id) WHERE student_id IS NOT NULL;

-- 5️⃣ Index on resolved_student_name for fast filtering
CREATE INDEX IF NOT EXISTS idx_payments_resolved_student_name 
ON payments (resolved_student_name) WHERE resolved_student_name IS NOT NULL;

-- 6️⃣ Index on payer_name for payer search optimization
CREATE INDEX IF NOT EXISTS idx_payments_payer_name 
ON payments (payer_name) WHERE payer_name IS NOT NULL;

-- 📊 VERIFY INDEXES
-- Run this to see all indexes on the payments table:
SELECT 
    schemaname,
    tablename,
    indexname,
    indexdef
FROM pg_indexes
WHERE tablename = 'payments'
ORDER BY indexname;

-- 🎯 PERFORMANCE TEST
-- Before: Run EXPLAIN ANALYZE on your query
-- After: Run again and compare execution time
EXPLAIN ANALYZE
SELECT * 
FROM payments 
ORDER BY email_date DESC NULLS LAST, created_at DESC NULLS LAST
LIMIT 500;

-- ✅ Expected improvement: 10-50x faster queries depending on table size
-- 💡 Note: Indexes are automatically used by Supabase/PostgreSQL query planner
