-- Create question_banks table for organizing questions
CREATE TABLE IF NOT EXISTS question_banks (
  id BIGSERIAL PRIMARY KEY,
  name TEXT NOT NULL,
  category TEXT NOT NULL DEFAULT 'General',
  description TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable RLS
ALTER TABLE question_banks ENABLE ROW LEVEL SECURITY;

-- Policy: Allow authenticated users to read
CREATE POLICY "Allow authenticated users to read question_banks"
  ON question_banks FOR SELECT
  TO authenticated
  USING (true);

-- Policy: Allow admins to insert
CREATE POLICY "Allow admins to insert question_banks"
  ON question_banks FOR INSERT
  TO authenticated
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM admin_accounts
      WHERE admin_accounts.email = auth.jwt() ->> 'email'
    )
  );

-- Policy: Allow admins to update
CREATE POLICY "Allow admins to update question_banks"
  ON question_banks FOR UPDATE
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM admin_accounts
      WHERE admin_accounts.email = auth.jwt() ->> 'email'
    )
  );

-- Policy: Allow admins to delete
CREATE POLICY "Allow admins to delete question_banks"
  ON question_banks FOR DELETE
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM admin_accounts
      WHERE admin_accounts.email = auth.jwt() ->> 'email'
    )
  );

-- Create junction table to link questions to multiple Q-Banks
CREATE TABLE IF NOT EXISTS qbank_questions (
  id BIGSERIAL PRIMARY KEY,
  qbank_id BIGINT REFERENCES question_banks(id) ON DELETE CASCADE,
  question_id BIGINT REFERENCES test_questions(id) ON DELETE CASCADE,
  added_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(qbank_id, question_id)
);

-- Enable RLS
ALTER TABLE qbank_questions ENABLE ROW LEVEL SECURITY;

-- Policy: Allow authenticated users to read
CREATE POLICY "Allow authenticated users to read qbank_questions"
  ON qbank_questions FOR SELECT
  TO authenticated
  USING (true);

-- Policy: Allow admins to insert
CREATE POLICY "Allow admins to insert qbank_questions"
  ON qbank_questions FOR INSERT
  TO authenticated
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM admin_accounts
      WHERE admin_accounts.email = auth.jwt() ->> 'email'
    )
  );

-- Policy: Allow admins to delete
CREATE POLICY "Allow admins to delete qbank_questions"
  ON qbank_questions FOR DELETE
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM admin_accounts
      WHERE admin_accounts.email = auth.jwt() ->> 'email'
    )
  );

-- Create index for faster queries
CREATE INDEX IF NOT EXISTS idx_qbank_questions_qbank_id ON qbank_questions(qbank_id);
CREATE INDEX IF NOT EXISTS idx_qbank_questions_question_id ON qbank_questions(question_id);

COMMENT ON TABLE question_banks IS 'Organized banks of questions that can be reused across multiple tests';
COMMENT ON TABLE qbank_questions IS 'Junction table linking questions to question banks (many-to-many relationship)';
