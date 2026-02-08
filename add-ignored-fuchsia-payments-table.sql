-- Drop existing table if it has wrong type
DROP TABLE IF EXISTS ignored_fuchsia_payments CASCADE;

-- Create table to track ignored fuchsia payments
CREATE TABLE IF NOT EXISTS ignored_fuchsia_payments (
  id BIGSERIAL PRIMARY KEY,
  payment_id TEXT NOT NULL REFERENCES payments(id) ON DELETE CASCADE,
  student_id BIGINT REFERENCES students(id) ON DELETE CASCADE,
  ignored_at TIMESTAMPTZ DEFAULT NOW(),
  ignored_by TEXT,
  UNIQUE(payment_id)
);

-- Create index for faster lookups
CREATE INDEX IF NOT EXISTS idx_ignored_fuchsia_payments_payment_id ON ignored_fuchsia_payments(payment_id);
CREATE INDEX IF NOT EXISTS idx_ignored_fuchsia_payments_student_id ON ignored_fuchsia_payments(student_id);

-- Add RLS policies
ALTER TABLE ignored_fuchsia_payments ENABLE ROW LEVEL SECURITY;

-- Admin can do everything
CREATE POLICY "Admins can manage ignored fuchsia payments"
ON ignored_fuchsia_payments
FOR ALL
TO authenticated
USING (is_arnoma_admin())
WITH CHECK (is_arnoma_admin());

-- Anon can read (for impersonation mode)
CREATE POLICY "Anon can view ignored fuchsia payments"
ON ignored_fuchsia_payments
FOR SELECT
TO anon
USING (true);

COMMENT ON TABLE ignored_fuchsia_payments IS 'Tracks fuchsia dots that admins have chosen to ignore/hide';
