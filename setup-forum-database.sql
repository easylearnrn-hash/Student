-- ============================================================
-- FORUM DATABASE SETUP
-- ============================================================
-- Run this SQL in your Supabase SQL Editor
-- Dashboard → SQL Editor → New Query → Paste → Run

-- Create forum_messages table
CREATE TABLE IF NOT EXISTS forum_messages (
  id BIGSERIAL PRIMARY KEY,
  student_id INTEGER NOT NULL,
  student_name TEXT NOT NULL,
  student_email TEXT NOT NULL,
  message TEXT NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create forum_replies table
CREATE TABLE IF NOT EXISTS forum_replies (
  id BIGSERIAL PRIMARY KEY,
  message_id BIGINT NOT NULL REFERENCES forum_messages(id) ON DELETE CASCADE,
  student_id INTEGER NOT NULL,
  student_name TEXT NOT NULL,
  message TEXT NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_forum_messages_created_at ON forum_messages(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_forum_messages_student_id ON forum_messages(student_id);
CREATE INDEX IF NOT EXISTS idx_forum_replies_message_id ON forum_replies(message_id);
CREATE INDEX IF NOT EXISTS idx_forum_replies_created_at ON forum_replies(created_at DESC);

-- Enable Row Level Security (RLS)
ALTER TABLE forum_messages ENABLE ROW LEVEL SECURITY;
ALTER TABLE forum_replies ENABLE ROW LEVEL SECURITY;

-- RLS Policies for forum_messages
-- Anyone authenticated can read messages
CREATE POLICY "Anyone can read forum messages"
  ON forum_messages
  FOR SELECT
  TO authenticated
  USING (true);

-- Only authenticated users can insert messages
CREATE POLICY "Authenticated users can create messages"
  ON forum_messages
  FOR INSERT
  TO authenticated
  WITH CHECK (true);

-- Users can update their own messages
CREATE POLICY "Users can update own messages"
  ON forum_messages
  FOR UPDATE
  TO authenticated
  USING (student_id = current_setting('app.current_student_id')::integer);

-- Users can delete their own messages
CREATE POLICY "Users can delete own messages"
  ON forum_messages
  FOR DELETE
  TO authenticated
  USING (student_id = current_setting('app.current_student_id')::integer);

-- RLS Policies for forum_replies
-- Anyone authenticated can read replies
CREATE POLICY "Anyone can read forum replies"
  ON forum_replies
  FOR SELECT
  TO authenticated
  USING (true);

-- Only authenticated users can insert replies
CREATE POLICY "Authenticated users can create replies"
  ON forum_replies
  FOR INSERT
  TO authenticated
  WITH CHECK (true);

-- Users can update their own replies
CREATE POLICY "Users can update own replies"
  ON forum_replies
  FOR UPDATE
  TO authenticated
  USING (student_id = current_setting('app.current_student_id')::integer);

-- Users can delete their own replies
CREATE POLICY "Users can delete own replies"
  ON forum_replies
  FOR DELETE
  TO authenticated
  USING (student_id = current_setting('app.current_student_id')::integer);

-- Grant permissions
GRANT ALL ON forum_messages TO authenticated;
GRANT ALL ON forum_replies TO authenticated;
GRANT USAGE, SELECT ON SEQUENCE forum_messages_id_seq TO authenticated;
GRANT USAGE, SELECT ON SEQUENCE forum_replies_id_seq TO authenticated;

-- Create updated_at trigger function (if not exists)
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Add trigger to update updated_at automatically
DROP TRIGGER IF EXISTS update_forum_messages_updated_at ON forum_messages;
CREATE TRIGGER update_forum_messages_updated_at
  BEFORE UPDATE ON forum_messages
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- ============================================================
-- VERIFICATION QUERIES
-- ============================================================
-- Run these to verify the tables were created:

-- SELECT * FROM forum_messages;
-- SELECT * FROM forum_replies;
