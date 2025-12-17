-- Add repeat-limit tracking columns for student alerts
ALTER TABLE student_alerts
ADD COLUMN IF NOT EXISTS max_show_count INTEGER CHECK (max_show_count IS NULL OR max_show_count >= 1),
ADD COLUMN IF NOT EXISTS times_shown INTEGER DEFAULT 0;

COMMENT ON COLUMN student_alerts.max_show_count IS 'Maximum number of times this alert should surface for the student';
COMMENT ON COLUMN student_alerts.times_shown IS 'How many times the alert has been shown to the student';

CREATE INDEX IF NOT EXISTS idx_student_alerts_max_show_count
  ON student_alerts(max_show_count)
  WHERE max_show_count IS NOT NULL;
