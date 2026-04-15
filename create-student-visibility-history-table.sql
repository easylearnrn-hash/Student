-- ============================================================
-- student_visibility_history
-- Tracks every moment a student is toggled on/off in the
-- Student Manager (either via the toggle switch or a status change).
-- Calendar-NEW.html uses this table to determine whether a
-- student should show as a dot on any given calendar date.
--
-- Logic (applied in isStudentActiveOnDate):
--   1. Find the most recent record where effective_date <= calendar_date.
--   2. If found → use record.visible.
--   3. If the date is BEFORE all records → assume visible (they were
--      active before history tracking began).
--   4. If no records exist at all → fall back to current student
--      fields (show_in_grid / status).
-- ============================================================

CREATE TABLE IF NOT EXISTS student_visibility_history (
  id             BIGSERIAL    PRIMARY KEY,
  student_id     BIGINT       NOT NULL,
  visible        BOOLEAN      NOT NULL,   -- true = show in calendar, false = hide
  effective_date DATE         NOT NULL,   -- calendar date the change takes effect
  created_at     TIMESTAMPTZ  DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_svh_student_date
  ON student_visibility_history (student_id, effective_date);

-- RLS: admins can do everything; students have no access
ALTER TABLE student_visibility_history ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Admins manage visibility history"
  ON student_visibility_history
  FOR ALL
  USING (
    EXISTS (
      SELECT 1 FROM admin_accounts
      WHERE auth_user_id = auth.uid()
    )
  );
