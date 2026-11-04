-- Applied live: every stem now ends "Select all that apply." (no parentheses), in both stem columns.
UPDATE test_questions
SET question_stem = replace(question_stem, '(Select all that apply)', 'Select all that apply.'),
    question = replace(question, '(Select all that apply)', 'Select all that apply.')
WHERE question_stem LIKE '%(Select all that apply)%' OR question LIKE '%(Select all that apply)%';
