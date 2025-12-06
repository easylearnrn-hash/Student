-- EMERGENCY FIX: Update all Cardiovascular notes to use generic path without date/timestamp
-- This will work if we rename files in storage to remove the timestamp portion

-- First, let's see what we're working with
SELECT id, title, pdf_url FROM student_notes 
WHERE pdf_url LIKE 'Cardiovascular-System/%'
ORDER BY id;

-- The issue: Database has 2025-12-05 dates, but storage has 2025-12-02 dates
-- SOLUTION: We need to either:
-- 1. Delete all cardiovascular notes and re-upload through Notes Manager
-- 2. Manually fix each path to match storage

-- Quick check: How many cardiovascular notes are there?
SELECT COUNT(*) as total_cardiovascular_notes
FROM student_notes 
WHERE pdf_url LIKE 'Cardiovascular-System/%';

-- RECOMMENDED: Delete all cardiovascular notes and re-upload them properly
-- This ensures database and storage are in sync

-- Uncomment below to delete (BE CAREFUL!)
-- DELETE FROM student_notes WHERE pdf_url LIKE 'Cardiovascular-System/%';
