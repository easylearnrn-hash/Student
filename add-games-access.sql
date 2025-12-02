-- ========================================================
-- ADD GAMES ACCESS CONTROL TO STUDENTS TABLE
-- ========================================================
-- This adds the ability for admin to toggle game access
-- for individual students in Student Manager
-- ========================================================

-- Add games_access column (default TRUE - everyone has access by default)
ALTER TABLE students 
  ADD COLUMN IF NOT EXISTS games_access BOOLEAN DEFAULT TRUE;

-- Update existing students to have access by default
UPDATE students 
SET games_access = TRUE 
WHERE games_access IS NULL;

-- ========================================================
-- ✅ MIGRATION COMPLETE!
-- ========================================================
--
-- Now you can:
-- 1. Go to Student Manager
-- 2. Add a toggle for "Games Access" (like Calendar toggle)
-- 3. Toggle it OFF to restrict a student from playing games
-- 4. Student will see "Access Restricted" message when they try
--
-- Admin (hrachfilm@gmail.com) ALWAYS has access regardless
--
-- ========================================================
