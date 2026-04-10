-- ========================================================
-- CREATE TESTS SYSTEM
-- ========================================================
-- This creates a system where admins can create multiple named tests
-- Each test has its own set of questions
-- Students see separate test boxes they can take individually

-- Create tests table
CREATE TABLE IF NOT EXISTS tests (
  id BIGINT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
  test_name TEXT NOT NULL,
  system_category TEXT NOT NULL, -- e.g., "Cardiovascular", "Respiratory"
  description TEXT,
  is_active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Modify test_questions to link to a specific test
ALTER TABLE test_questions 
ADD COLUMN IF NOT EXISTS test_id BIGINT REFERENCES tests(id) ON DELETE CASCADE;

-- Make test_id optional for backward compatibility
-- Questions without test_id are in the "general pool"

-- Add indexes
CREATE INDEX IF NOT EXISTS idx_test_questions_test_id ON test_questions(test_id);
CREATE INDEX IF NOT EXISTS idx_tests_is_active ON tests(is_active);

-- Enable RLS
ALTER TABLE tests ENABLE ROW LEVEL SECURITY;

-- Anyone can view active tests
CREATE POLICY "Anyone can view active tests"
  ON tests
  FOR SELECT
  USING (is_active = TRUE);

-- Only admins can manage tests
CREATE POLICY "Admins can insert tests"
  ON tests
  FOR INSERT
  TO authenticated
  WITH CHECK (
    auth.uid() IN (
      SELECT auth_user_id FROM admin_accounts
    )
  );

CREATE POLICY "Admins can update tests"
  ON tests
  FOR UPDATE
  TO authenticated
  USING (
    auth.uid() IN (
      SELECT auth_user_id FROM admin_accounts
    )
  );

CREATE POLICY "Admins can delete tests"
  ON tests
  FOR DELETE
  TO authenticated
  USING (
    auth.uid() IN (
      SELECT auth_user_id FROM admin_accounts
    )
  );

-- Add updated_at trigger for tests
CREATE TRIGGER update_tests_updated_at
  BEFORE UPDATE ON tests
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- Example: Insert sample tests
INSERT INTO tests (test_name, system_category, description) VALUES
  ('Cardiovascular Medications', 'Cardiovascular', 'Test your knowledge of cardiovascular drugs including ACE inhibitors, beta blockers, and more'),
  ('Respiratory Medications', 'Respiratory', 'Master respiratory medications including bronchodilators, steroids, and anticholinergics'),
  ('Renal Medications', 'Renal', 'Learn about diuretics, electrolyte management, and renal pharmacology');
