-- Fix PDF paths in student_notes to match actual storage filenames
-- The storage has "Cardiovascular System_" (with SPACE) but database has "Cardiovascular-System_"

-- Show current records before fixing
SELECT id, title, pdf_url, file_name
FROM student_notes
WHERE pdf_url LIKE 'Cardiovascular-System/%';

-- Update pdf_url: replace "Cardiovascular-System_" with "Cardiovascular System_" (space, no hyphen)
UPDATE student_notes
SET pdf_url = REPLACE(pdf_url, 'Cardiovascular-System/Cardiovascular-System_', 'Cardiovascular-System/Cardiovascular System_')
WHERE pdf_url LIKE 'Cardiovascular-System/Cardiovascular-System_%';

-- Update file_name: replace "Cardiovascular-System_" with "Cardiovascular System_"
UPDATE student_notes
SET file_name = REPLACE(file_name, 'Cardiovascular-System_', 'Cardiovascular System_')
WHERE file_name LIKE 'Cardiovascular-System_%';

-- Show fixed records
SELECT id, title, pdf_url, file_name 
FROM student_notes 
WHERE pdf_url LIKE 'Cardiovascular-System/%';
