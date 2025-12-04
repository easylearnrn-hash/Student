SELECT id, title, pdf_url, created_at
FROM student_notes
WHERE deleted = false
ORDER BY id;
