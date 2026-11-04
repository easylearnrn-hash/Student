-- Applied live: options are the nurse speaking to the client, so "her"/"the client's" become "your".
UPDATE test_questions
SET options = '[
  {"id":"a","text":"\"Removing the tube is preferred for a recurrent ectopic in a badly damaged tube.\""},
  {"id":"b","text":"\"Removing the tube is required, since saving it works only after rupture occurs.\""},
  {"id":"c","text":"\"Removing the tube is done for every ectopic, regardless of your wishes.\""},
  {"id":"d","text":"\"Removing the tube is needed because your vital signs are too stable for drug therapy.\""}
]'::jsonb
WHERE id = 21840;
