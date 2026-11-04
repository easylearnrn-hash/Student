-- Applied live: question 13532 stem uses "cryptorchidism" instead of "an undescended testicle" (both stem columns).
UPDATE test_questions
SET question_stem = replace(question_stem, 'an undescended testicle as an infant', 'cryptorchidism as an infant'),
    question = replace(question, 'an undescended testicle as an infant', 'cryptorchidism as an infant')
WHERE id = 13532;
