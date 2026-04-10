-- ========================================================
-- TEST REACTIONS TABLE (OPTIONAL - Currently using localStorage)
-- ========================================================
-- This table can be used in the future to store reactions in the database
-- Currently, reactions are stored in localStorage (arnoma-test-reactions-v1)
-- Run this only if you want to migrate to database storage

-- Create reactions table
CREATE TABLE IF NOT EXISTS test_reactions (
  id BIGINT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
  reaction_type TEXT NOT NULL CHECK (reaction_type IN ('correct', 'incorrect')),
  message TEXT NOT NULL,
  emoji TEXT,
  is_active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Add RLS policies
ALTER TABLE test_reactions ENABLE ROW LEVEL SECURITY;

-- Anyone can read active reactions
CREATE POLICY "Anyone can view active reactions"
  ON test_reactions
  FOR SELECT
  USING (is_active = TRUE);

-- Only admins can manage reactions
CREATE POLICY "Admins can insert reactions"
  ON test_reactions
  FOR INSERT
  TO authenticated
  WITH CHECK (
    auth.uid() IN (
      SELECT auth_user_id FROM admin_accounts
    )
  );

CREATE POLICY "Admins can update reactions"
  ON test_reactions
  FOR UPDATE
  TO authenticated
  USING (
    auth.uid() IN (
      SELECT auth_user_id FROM admin_accounts
    )
  );

CREATE POLICY "Admins can delete reactions"
  ON test_reactions
  FOR DELETE
  TO authenticated
  USING (
    auth.uid() IN (
      SELECT auth_user_id FROM admin_accounts
    )
  );

-- Insert default reactions
INSERT INTO test_reactions (reaction_type, message) VALUES
  ('correct', 'Amazing! You got it right! 🎉'),
  ('correct', 'Perfect! Keep up the great work! ⭐'),
  ('correct', 'Excellent! You''re on fire! 🔥'),
  ('correct', 'Fantastic! That''s correct! 💫'),
  ('correct', 'Brilliant! You nailed it! 🏆'),
  ('correct', 'Outstanding! You''re a star! 🌟'),
  ('correct', 'Superb! That''s the right answer! ✨'),
  ('correct', 'Wonderful! You''re doing great! 🎯'),
  ('incorrect', 'Not quite, but keep trying! 💪'),
  ('incorrect', 'Almost there! Review and try again! 📚'),
  ('incorrect', 'Don''t give up! You can do this! 🌟'),
  ('incorrect', 'Keep learning! Every mistake is progress! 🚀'),
  ('incorrect', 'Try again! You''re getting closer! 💡'),
  ('incorrect', 'No worries! Learning takes practice! 📖'),
  ('incorrect', 'Keep going! You''ll get it next time! 🎓'),
  ('incorrect', 'Stay positive! Mistakes help you learn! 💫');

-- Add updated_at trigger
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_test_reactions_updated_at
  BEFORE UPDATE ON test_reactions
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();
