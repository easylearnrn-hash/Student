-- Add read_at timestamp to student_alerts table
-- This tracks when a student actually read the alert

ALTER TABLE student_alerts 
ADD COLUMN IF NOT EXISTS read_at TIMESTAMP WITH TIME ZONE;

-- Create index for faster queries
CREATE INDEX IF NOT EXISTS idx_student_alerts_read_at ON student_alerts(read_at);

-- Optionally backfill existing read alerts with updated_at as read_at
-- (only for alerts that are already marked as read)
UPDATE student_alerts 
SET read_at = updated_at 
WHERE is_read = true AND read_at IS NULL;

COMMENT ON COLUMN student_alerts.read_at IS 'Timestamp when the student marked the alert as read';
