-- ⚠️ DELETE SPECIFIC DEC 17, 2025 PAYMENTS
-- This will delete only the 4 payments you specified
-- 
-- STEPS TO RUN:
-- 1. Go to https://supabase.com/dashboard/project/zlvnxvrzotamhpezqedr/sql/new
-- 2. Copy and paste STEP 1 below to preview what will be deleted
-- 3. If it looks correct, copy and paste STEP 2 to delete
-- 4. After deletion, go to Payment Records and click Gmail/55s sync to re-import

-- ═══════════════════════════════════════════════════════════════════════════
-- STEP 1: PREVIEW WHAT WILL BE DELETED (Run this first!)
-- ═══════════════════════════════════════════════════════════════════════════
SELECT 
  id, 
  student_id, 
  linked_student_id, 
  payer_name, 
  amount, 
  email_date, 
  for_class, 
  memo,
  created_at
FROM payments
WHERE email_date >= '2025-12-17 00:00:00'
  AND email_date < '2025-12-18 00:00:00'
  AND payer_name IN ('Anahit Aslanyan', 'Ani Khurshudyan', 'Stella Ghazaryan', 'Scins Inc')
  AND amount = 50
ORDER BY email_date DESC;

-- ═══════════════════════════════════════════════════════════════════════════
-- STEP 2: DELETE THE PAYMENTS (Run this after confirming STEP 1 shows exactly 4 rows)
-- ═══════════════════════════════════════════════════════════════════════════
DELETE FROM payments
WHERE email_date >= '2025-12-17 00:00:00'
  AND email_date < '2025-12-18 00:00:00'
  AND payer_name IN ('Anahit Aslanyan', 'Ani Khurshudyan', 'Stella Ghazaryan', 'Scins Inc')
  AND amount = 50;

-- This should return: "4 rows affected"
