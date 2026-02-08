-- ============================================================
-- ADD FOR_CLASS_DATES COLUMN TO PAYMENTS TABLE
-- ============================================================
-- Purpose: Track which class date(s) each payment is applied to
-- Format: JSONB array of ISO date strings
-- Example: ["2026-02-10", "2026-02-12", "2026-02-15"]
-- ============================================================

-- Add for_class_dates column to payments table
ALTER TABLE payments
ADD COLUMN IF NOT EXISTS for_class_dates JSONB DEFAULT '[]'::jsonb;

-- Add comment for documentation
COMMENT ON COLUMN payments.for_class_dates IS 'Array of ISO date strings (YYYY-MM-DD) representing class dates this payment covers. Number of dates = floor(payment_amount / student_price_per_class).';

-- Create index for efficient querying by class date
CREATE INDEX IF NOT EXISTS idx_payments_for_class_dates 
ON payments USING gin (for_class_dates);

-- Add check constraint to ensure valid JSON array format
ALTER TABLE payments
ADD CONSTRAINT check_for_class_dates_is_array
CHECK (jsonb_typeof(for_class_dates) = 'array');

-- ============================================================
-- MIGRATION NOTES
-- ============================================================
-- 1. Existing rows will have empty array [] by default
-- 2. Frontend will calculate number of date pickers based on:
--    payment_amount / student_price_per_class (floored)
-- 3. Updates happen immediately on date picker change (no save button)
-- 4. Preserved when possible during amount/price recalculations
-- ============================================================
