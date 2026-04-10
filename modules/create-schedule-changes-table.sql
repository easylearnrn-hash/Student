-- Create schedule_changes table for announcements feed
-- Run this in Supabase SQL Editor

-- Create the table
CREATE TABLE IF NOT EXISTS schedule_changes (
  id BIGSERIAL PRIMARY KEY,
  group_name TEXT NOT NULL,
  change_type TEXT NOT NULL, -- 'cancelation', 'reschedule', 'new-class', 'permanent-change', etc.
  message TEXT NOT NULL,
  description TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  created_by TEXT,
  metadata JSONB -- For storing additional data like old_date, new_date, etc.
);

-- Create index on group_name for faster queries
CREATE INDEX IF NOT EXISTS idx_schedule_changes_group ON schedule_changes(group_name);

-- Create index on created_at for sorting
CREATE INDEX IF NOT EXISTS idx_schedule_changes_created_at ON schedule_changes(created_at DESC);

-- Enable Row Level Security (RLS)
ALTER TABLE schedule_changes ENABLE ROW LEVEL SECURITY;

-- Policy: Allow all authenticated users to read schedule changes
CREATE POLICY "Allow authenticated users to read schedule changes"
  ON schedule_changes
  FOR SELECT
  TO authenticated
  USING (true);

-- Policy: Allow service role (admins) to insert/update/delete
CREATE POLICY "Allow service role to manage schedule changes"
  ON schedule_changes
  FOR ALL
  TO service_role
  USING (true)
  WITH CHECK (true);

-- Grant permissions
GRANT SELECT ON schedule_changes TO authenticated;
GRANT ALL ON schedule_changes TO service_role;

-- Insert sample announcements for testing
INSERT INTO schedule_changes (group_name, change_type, message, created_at) VALUES
  ('Group A', 'cancelation', 'Tuesday Nov 10 class has been canceled.', NOW() - INTERVAL '2 days'),
  ('Group A', 'reschedule', 'Your Tuesday class has been moved to Wednesday, Nov 12 at 7 PM.', NOW() - INTERVAL '5 days'),
  ('Group B', 'new-class', 'A new one-day extra class has been scheduled: Friday, Nov 14 — 8:00 PM', NOW() - INTERVAL '1 day'),
  ('Group C', 'permanent-change', 'Your weekly Tuesday class is now at 7:30 PM (effective starting Nov 20).', NOW() - INTERVAL '3 days'),
  ('Group E', 'cancelation', 'Thursday class canceled due to holiday.', NOW() - INTERVAL '4 hours');

COMMENT ON TABLE schedule_changes IS 'Stores schedule change announcements for student groups';
COMMENT ON COLUMN schedule_changes.change_type IS 'Type of change: cancelation, reschedule, new-class, permanent-change';
COMMENT ON COLUMN schedule_changes.message IS 'User-facing announcement message';
COMMENT ON COLUMN schedule_changes.metadata IS 'Additional structured data (dates, times, etc.)';
