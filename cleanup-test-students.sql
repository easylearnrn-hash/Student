-- Delete test students created by test suite
DELETE FROM students 
WHERE name = '123' 
   OR email = 'true'
   OR name LIKE 'Test Student%'
   OR email LIKE 'test-%@test.com';
