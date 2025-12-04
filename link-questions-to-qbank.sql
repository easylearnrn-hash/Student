-- Link existing questions to a Q-Bank
-- This script helps you add your 143 cardiovascular questions to a Q-Bank

-- IMPORTANT: First ensure test_questions table has the required columns
-- Run this if you get "column does not exist" errors:
ALTER TABLE test_questions 
ADD COLUMN IF NOT EXISTS difficulty TEXT,
ADD COLUMN IF NOT EXISTS category TEXT,
ADD COLUMN IF NOT EXISTS test_id BIGINT REFERENCES tests(id) ON DELETE CASCADE;

CREATE INDEX IF NOT EXISTS idx_test_questions_difficulty ON test_questions(difficulty);
CREATE INDEX IF NOT EXISTS idx_test_questions_category ON test_questions(category);
CREATE INDEX IF NOT EXISTS idx_test_questions_test_id ON test_questions(test_id);

-- Step 1: Find your Q-Bank ID
-- Run this first to see your Q-Banks:
SELECT id, name, category FROM question_banks ORDER BY created_at DESC;

-- Step 2: Find the questions you want to add
-- Example: Find all cardiovascular questions
SELECT id, question, difficulty, category 
FROM test_questions 
WHERE category ILIKE '%cardiovascular%'
ORDER BY difficulty, id;

-- Step 3: Link questions to Q-Bank
-- Replace <qbank_id> with your Q-Bank ID from Step 1
-- Replace the WHERE clause to match your questions

-- Option A: Add ALL cardiovascular questions to Q-Bank
INSERT INTO qbank_questions (qbank_id, question_id)
SELECT 
  1, -- Replace with your Q-Bank ID
  id
FROM test_questions
WHERE category ILIKE '%cardiovascular%'
ON CONFLICT (qbank_id, question_id) DO NOTHING;

-- Option B: Add questions by difficulty
-- Easy questions to Q-Bank
INSERT INTO qbank_questions (qbank_id, question_id)
SELECT 
  1, -- Replace with your Q-Bank ID
  id
FROM test_questions
WHERE category ILIKE '%cardiovascular%'
  AND difficulty = 'Easy'
ON CONFLICT (qbank_id, question_id) DO NOTHING;

-- Medium questions
INSERT INTO qbank_questions (qbank_id, question_id)
SELECT 
  2, -- Replace with your Q-Bank ID for Medium
  id
FROM test_questions
WHERE category ILIKE '%cardiovascular%'
  AND difficulty = 'Medium'
ON CONFLICT (qbank_id, question_id) DO NOTHING;

-- Hard questions
INSERT INTO qbank_questions (qbank_id, question_id)
SELECT 
  3, -- Replace with your Q-Bank ID for Hard
  id
FROM test_questions
WHERE category ILIKE '%cardiovascular%'
  AND difficulty = 'Hard'
ON CONFLICT (qbank_id, question_id) DO NOTHING;

-- Step 4: Verify the links
-- Check how many questions are in your Q-Bank
SELECT 
  qb.id,
  qb.name,
  qb.category,
  COUNT(qq.question_id) as question_count
FROM question_banks qb
LEFT JOIN qbank_questions qq ON qb.id = qq.qbank_id
GROUP BY qb.id, qb.name, qb.category
ORDER BY qb.created_at DESC;

-- Step 5: View questions in a specific Q-Bank
-- Replace <qbank_id> with your Q-Bank ID
SELECT 
  tq.id,
  tq.question,
  tq.difficulty,
  tq.category,
  qq.added_at
FROM qbank_questions qq
JOIN test_questions tq ON qq.question_id = tq.id
WHERE qq.qbank_id = 1 -- Replace with your Q-Bank ID
ORDER BY tq.difficulty, tq.id;

-- Step 6: Remove questions from Q-Bank (if needed)
-- DELETE FROM qbank_questions WHERE qbank_id = 1;
