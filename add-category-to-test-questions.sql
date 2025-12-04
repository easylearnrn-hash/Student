-- ========================================================
-- ADD CATEGORY FIELD TO TEST QUESTIONS
-- ========================================================
-- This allows you to organize questions by topic:
-- Cardiovascular Medications, Respiratory Medications, etc.

-- Add category column
ALTER TABLE test_questions 
ADD COLUMN IF NOT EXISTS category TEXT DEFAULT 'General';

-- Add difficulty level column (optional)
ALTER TABLE test_questions 
ADD COLUMN IF NOT EXISTS difficulty TEXT DEFAULT 'Medium';

-- Create index for faster filtering
CREATE INDEX IF NOT EXISTS idx_test_questions_category ON test_questions(category);
CREATE INDEX IF NOT EXISTS idx_test_questions_difficulty ON test_questions(difficulty);

-- Update existing questions to have a default category
UPDATE test_questions 
SET category = 'General' 
WHERE category IS NULL;

-- Example categories you can use:
-- - Cardiovascular Medications
-- - Respiratory Medications
-- - Renal Medications
-- - Neurological Medications
-- - Endocrine Medications
-- - Gastrointestinal Medications
-- - Antimicrobial Medications
-- - Oncology Medications
-- - Pediatric Medications
-- - Obstetric Medications
-- - General Nursing
-- - Medical-Surgical
-- - Critical Care
-- - Emergency Nursing

-- Example difficulties:
-- - Easy
-- - Medium
-- - Hard
