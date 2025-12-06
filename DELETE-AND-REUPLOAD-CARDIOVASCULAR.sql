-- ================================================================
-- DELETE CARDIOVASCULAR NOTES WITH WRONG FILE PATHS
-- ================================================================
-- Problem: Database has 2025-12-05 dates but storage has 2025-12-02 files
-- Solution: Delete all cardiovascular notes and re-upload through Notes Manager
-- This ensures database and storage paths are perfectly in sync
-- ================================================================

-- STEP 1: Delete permissions first (foreign key constraint)
DELETE FROM student_note_permissions 
WHERE note_id IN (
  SELECT id FROM student_notes 
  WHERE pdf_url LIKE 'Cardiovascular-System/%'
);

-- STEP 2: Delete the notes themselves
DELETE FROM student_notes 
WHERE pdf_url LIKE 'Cardiovascular-System/%';

-- STEP 3: Verify deletion
SELECT COUNT(*) as remaining_cardiovascular_notes
FROM student_notes 
WHERE pdf_url LIKE 'Cardiovascular-System/%';

-- Should return 0

-- ================================================================
-- NEXT STEPS AFTER RUNNING THIS SQL:
-- ================================================================
-- 1. Go to Notes-Manager-NEW.html
-- 2. Select all 23 Cardiovascular PDFs from your local folder
-- 3. Upload them with:
--    - System: Cardiovascular System
--    - Course: (appropriate course name)
--    - Requires Payment: false (since we want them unlocked)
-- 4. This will create fresh database entries that match the storage files
-- ================================================================
