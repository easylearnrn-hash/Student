-- ========================================================
-- TEST QUESTIONS - RLS POLICIES
-- ========================================================

-- Enable RLS if not already enabled
ALTER TABLE test_questions ENABLE ROW LEVEL SECURITY;

-- Drop existing policies if any
DROP POLICY IF EXISTS "Anyone can read questions" ON test_questions;
DROP POLICY IF EXISTS "Only admins can insert/delete" ON test_questions;
DROP POLICY IF EXISTS "Admins can do everything" ON test_questions;

-- Allow everyone to read questions (students need this for the test)
CREATE POLICY "Anyone can read questions"
  ON test_questions FOR SELECT
  USING (true);

-- Allow admins to insert, update, delete questions
CREATE POLICY "Admins can manage questions"
  ON test_questions FOR ALL
  USING (
    auth.uid() IN (
      SELECT auth_user_id FROM admin_accounts
    )
  );

-- Verify the table structure
SELECT column_name, data_type 
FROM information_schema.columns 
WHERE table_name = 'test_questions'
ORDER BY ordinal_position;
