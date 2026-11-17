-- Applied live 2026-11-17. Q24159 (ear drops for a 6-year-old) was keyed as a "needs further teaching" item whose
-- keyed answer was the WRONG technique ("down and back"), which reads like an error. Rewritten as a direct question:
-- the correct answer is now "pull the ear UP and back" (children 3 years and older). Previous text is in the session
-- backup question-24159-backup.json.
update test_questions set
  question_stem = $q$The parent of a 6-year-old is taught to give ear drops at home. Which statement by the parent indicates correct understanding of the technique?$q$,
  question      = $q$The parent of a 6-year-old is taught to give ear drops at home. Which statement by the parent indicates correct understanding of the technique?$q$,
  options       = $q$[{"id": "a", "text": "I will pull his ear up and back"}, {"id": "b", "text": "I will pull his ear down and back"}, {"id": "c", "text": "I will pull his ear straight down"}, {"id": "d", "text": "I will pull his ear straight forward"}]$q$::jsonb,
  correct_answer = '["a"]',
  rationale     = $q$For a child 3 years and older, the pinna is pulled UP and back to straighten the ear canal so the drops reach the eardrum. Down and back is the technique for children younger than 3 years, so it is not used for a 6-year-old. Pulling the ear straight down or straight forward does not straighten the canal.$q$
where id = 24159;
