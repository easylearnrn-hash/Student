-- Add rationale column to test_questions table
-- This stores the explanation/rationale for why an answer is correct

ALTER TABLE test_questions 
ADD COLUMN IF NOT EXISTS rationale TEXT;

-- Create an index for faster searches if needed
CREATE INDEX IF NOT EXISTS idx_test_questions_rationale ON test_questions(rationale);

-- Verify the column was added
SELECT column_name, data_type, is_nullable
FROM information_schema.columns
WHERE table_name = 'test_questions'
ORDER BY ordinal_position;
