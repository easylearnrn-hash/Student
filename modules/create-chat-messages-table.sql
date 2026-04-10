-- =====================================================
-- CHAT MESSAGES SYSTEM
-- =====================================================
-- Creates table for student-to-student and admin-student chat
-- Supports both group chat and private admin messages
-- =====================================================

-- Drop existing table and policies if they exist
DROP TABLE IF EXISTS chat_messages CASCADE;

-- Create chat_messages table
CREATE TABLE chat_messages (
  id BIGSERIAL PRIMARY KEY,
  student_id INTEGER NOT NULL REFERENCES students(id) ON DELETE CASCADE,
  sender_name TEXT NOT NULL,
  sender_college TEXT,
  message TEXT NOT NULL,
  sender_type TEXT NOT NULL CHECK (sender_type IN ('student', 'admin')),
  is_private BOOLEAN NOT NULL DEFAULT FALSE,
  is_read BOOLEAN NOT NULL DEFAULT FALSE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Create indexes for performance
CREATE INDEX idx_chat_messages_student_id ON chat_messages(student_id);
CREATE INDEX idx_chat_messages_created_at ON chat_messages(created_at DESC);
CREATE INDEX idx_chat_messages_is_private ON chat_messages(is_private);
CREATE INDEX idx_chat_messages_sender_type ON chat_messages(sender_type);
CREATE INDEX idx_chat_messages_is_read ON chat_messages(is_read);

-- Composite index for common queries
CREATE INDEX idx_chat_messages_student_created ON chat_messages(student_id, created_at DESC);
CREATE INDEX idx_chat_messages_private_student ON chat_messages(is_private, student_id) WHERE is_private = true;

-- Enable Row Level Security
ALTER TABLE chat_messages ENABLE ROW LEVEL SECURITY;

-- =====================================================
-- RLS POLICIES
-- =====================================================

-- Policy 1: Everyone can view all group messages (is_private = false)
CREATE POLICY "Everyone can view group messages"
ON chat_messages
FOR SELECT
TO public
USING (chat_messages.is_private = false);

-- Policy 2: Students and admins can view private messages they're involved in
CREATE POLICY "View own private messages"
ON chat_messages
FOR SELECT
TO public
USING (
  chat_messages.is_private = true 
  AND (
    -- Student can see their own private messages
    chat_messages.student_id IN (
      SELECT id FROM students 
      WHERE auth_user_id = auth.uid()
    )
    OR
    -- Admins can see all private messages
    EXISTS (
      SELECT 1 FROM admin_accounts 
      WHERE admin_accounts.auth_user_id = auth.uid()
    )
  )
);

-- Policy 3: Everyone can insert messages (we'll validate on client side)
CREATE POLICY "Anyone can insert messages"
ON chat_messages
FOR INSERT
TO public
WITH CHECK (true);

-- Policy 4: Users can update their own messages
CREATE POLICY "Update own messages"
ON chat_messages
FOR UPDATE
TO public
USING (
  chat_messages.student_id IN (
    SELECT id FROM students 
    WHERE auth_user_id = auth.uid()
  )
  OR
  EXISTS (
    SELECT 1 FROM admin_accounts 
    WHERE admin_accounts.auth_user_id = auth.uid()
  )
);

-- Policy 5: Admins can delete messages
CREATE POLICY "Admins can delete messages"
ON chat_messages
FOR DELETE
TO public
USING (
  EXISTS (
    SELECT 1 FROM admin_accounts 
    WHERE admin_accounts.auth_user_id = auth.uid()
  )
);

-- =====================================================
-- TRIGGERS
-- =====================================================

-- Auto-update updated_at timestamp
CREATE OR REPLACE FUNCTION update_chat_messages_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER chat_messages_updated_at
BEFORE UPDATE ON chat_messages
FOR EACH ROW
EXECUTE FUNCTION update_chat_messages_updated_at();

-- =====================================================
-- COMMENTS
-- =====================================================

COMMENT ON TABLE chat_messages IS 'Stores student-to-student and admin-student chat messages';
COMMENT ON COLUMN chat_messages.student_id IS 'ID of the student who sent or is associated with the message';
COMMENT ON COLUMN chat_messages.sender_name IS 'Display name of the message sender';
COMMENT ON COLUMN chat_messages.sender_college IS 'College name of the sender (for students)';
COMMENT ON COLUMN chat_messages.message IS 'The actual message text content';
COMMENT ON COLUMN chat_messages.sender_type IS 'Type of sender: student or admin';
COMMENT ON COLUMN chat_messages.is_private IS 'Whether this is a private message (only visible to sender and admin)';
COMMENT ON COLUMN chat_messages.is_read IS 'Whether the message has been read by the recipient';

-- =====================================================
-- SUCCESS MESSAGE
-- =====================================================

DO $$
BEGIN
  RAISE NOTICE '✅ Chat messages table created successfully!';
  RAISE NOTICE '📊 Table: chat_messages';
  RAISE NOTICE '🔒 RLS Policies: 5 policies created';
  RAISE NOTICE '⚡ Indexes: 7 indexes created for performance';
  RAISE NOTICE '';
  RAISE NOTICE '🔄 IMPORTANT: Enable Realtime in Supabase Dashboard:';
  RAISE NOTICE '   1. Go to Database > Replication';
  RAISE NOTICE '   2. Enable replication for "chat_messages" table';
  RAISE NOTICE '   3. This enables real-time message updates!';
END $$;
