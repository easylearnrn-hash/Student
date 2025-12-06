-- Migration: Manual Credit Payment Verification and Cleanup
-- Purpose: Identify classes that need credit payment re-application
-- Date: December 5, 2025

-- IMPORTANT: The old code was inserting credit payments into the 'payments' table,
-- but we now track them separately in 'credit_payments' table.
-- Since we don't have a reliable way to identify which payments in the 'payments' 
-- table were credit-based, the safest approach is to:
--
-- 1. Manually re-apply credit payments in the Calendar for affected dates
-- 2. Or delete old problematic payments from 'payments' table if you can identify them
--
-- This script provides diagnostic queries to help you find the issues.

-- ============================================================================
-- STEP 1: Check what's currently in credit_payments table
-- ============================================================================
SELECT 
  cp.student_id,
  s.name as student_name,
  cp.class_date,
  cp.amount,
  cp.balance_after,
  cp.applied_at
FROM credit_payments cp
LEFT JOIN students s ON s.id = cp.student_id
ORDER BY cp.student_id, cp.class_date DESC;

-- ============================================================================
-- STEP 2: Show ALL credit payments with student names
-- ============================================================================
SELECT 
  cp.id,
  cp.student_id,
  s.name as student_name,
  cp.class_date,
  cp.amount,
  cp.balance_after,
  cp.applied_at,
  cp.created_at
FROM credit_payments cp
LEFT JOIN students s ON s.id = cp.student_id
ORDER BY cp.class_date DESC, s.name;

-- ============================================================================
-- STEP 3: Check current balance for students
-- ============================================================================
SELECT 
  id,
  name,
  balance,
  price_per_class,
  group_name
FROM students
WHERE balance > 0  -- Students with credit balance
ORDER BY balance DESC;

-- ============================================================================
-- STEP 5: Check regular payments table for Narine (to find missing credit payments)
-- ============================================================================
SELECT 
  id,
  student_id,
  student_name,
  amount,
  email_date,
  created_at
FROM payments
WHERE student_name ILIKE '%Narine%'
   OR student_id::text = '25'
ORDER BY email_date DESC NULLS LAST;

-- ============================================================================
-- MANUAL FIX: Insert missing December 1 credit payment for Narine
-- ============================================================================
-- Narine Avetisyan paid for December 1, 2025 using $50 from credit
-- Current balance should be $300 (but shows $350 because payment wasn't recorded)
-- After inserting this payment, balance should be corrected to $300

INSERT INTO credit_payments (student_id, class_date, amount, balance_after, applied_at, created_at)
VALUES (
  25,                          -- Narine's student_id
  '2025-12-01',               -- December 1 class date
  50.00,                      -- Amount paid from credit
  300.00,                     -- Balance after payment ($350 - $50 = $300)
  '2025-12-01 10:00:00',      -- Applied at (estimated time)
  NOW()                       -- Created at (now)
);

-- After running this, also update Narine's balance in students table:
UPDATE students 
SET balance = 300.00
WHERE id = 25 AND balance = 350.00;

-- ============================================================================
-- FIX: Update December 5 balance_after to reflect correct balance
-- ============================================================================
-- December 5 was applied when balance was $350, but after adding Dec 1,
-- the actual balance before Dec 5 was $300, so after Dec 5 it should be $250

UPDATE credit_payments
SET balance_after = 250.00
WHERE id = 202 AND student_id = 25 AND class_date = '2025-12-05';

-- Also update Narine's current balance to $250:
UPDATE students 
SET balance = 250.00
WHERE id = 25;

-- ============================================================================
-- FINAL VERIFICATION: Check Narine's complete credit payment history
-- ============================================================================
SELECT 
  cp.id,
  cp.class_date,
  cp.amount,
  cp.balance_after,
  cp.applied_at
FROM credit_payments cp
WHERE cp.student_id = 25
ORDER BY cp.class_date ASC;  -- Ascending to see chronological order

-- Check current balance:
SELECT name, balance, price_per_class 
FROM students 
WHERE id = 25;

-- ============================================================================

