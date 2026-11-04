-- Applied live: show the calculated BMI in the stem so students don't have to compute it.
UPDATE test_questions
SET question = 'A client weighs 300 lb and is 70 inches tall. Based on the client''s BMI (43.0), which nursing action is indicated?'
WHERE id = 19521;
