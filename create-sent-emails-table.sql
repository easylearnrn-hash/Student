-- Create sent_emails table for email notification tracking
-- Run this in Supabase SQL Editor

CREATE TABLE IF NOT EXISTS sent_emails (
  id BIGSERIAL PRIMARY KEY,
  recipient_email TEXT NOT NULL,
  recipient_name TEXT,
  subject TEXT NOT NULL,
  html_content TEXT,
  status TEXT DEFAULT 'sent',
  template_name TEXT,
  email_type TEXT,
  resend_id TEXT,
  delivery_status TEXT DEFAULT 'unknown',
  sent_at TIMESTAMPTZ DEFAULT NOW(),
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create index for faster queries
CREATE INDEX IF NOT EXISTS idx_sent_emails_sent_at ON sent_emails(sent_at DESC);
CREATE INDEX IF NOT EXISTS idx_sent_emails_recipient ON sent_emails(recipient_email);
CREATE INDEX IF NOT EXISTS idx_sent_emails_type ON sent_emails(email_type);

-- Enable RLS (Row Level Security)
ALTER TABLE sent_emails ENABLE ROW LEVEL SECURITY;

-- Create policy to allow all operations for authenticated users
CREATE POLICY "Enable all operations for authenticated users" ON sent_emails
  FOR ALL
  USING (true)
  WITH CHECK (true);

-- Grant permissions
GRANT ALL ON sent_emails TO authenticated;
GRANT ALL ON sent_emails TO anon;
DO $$
DECLARE
  seq_name TEXT;
BEGIN
  seq_name := pg_get_serial_sequence('sent_emails', 'id');
  IF seq_name IS NOT NULL THEN
    EXECUTE format('GRANT USAGE, SELECT ON SEQUENCE %s TO authenticated', seq_name);
    EXECUTE format('GRANT USAGE, SELECT ON SEQUENCE %s TO anon', seq_name);
  END IF;
END $$;
