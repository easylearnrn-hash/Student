-- Check if hrach@arnoma.us exists in students table
SELECT id, name, email, auth_user_id, role, show_in_grid
FROM students
WHERE email = 'hrach@arnoma.us';
