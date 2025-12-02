-- Create sent_emails table for email notification tracking
-- Run this in Supabase SQL Editor

CREATE TABLE IF NOT EXISTS sent_emails (
  id BIGSERIAL PRIMARY KEY,
  recipient TEXT NOT NULL,
  subject TEXT NOT NULL,
  body_html TEXT,
  body_text TEXT,
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
CREATE INDEX IF NOT EXISTS idx_sent_emails_recipient ON sent_emails(recipient);
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
GRANT USAGE, SELECT ON SEQUENCE sent_emails_id_seq TO authenticated;
GRANT USAGE, SELECT ON SEQUENCE sent_emails_id_seq TO anon;
