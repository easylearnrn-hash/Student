-- Applied live: clearer wording for question 26716 (same answer key: a, d).
UPDATE test_questions
SET question = 'A nurse is precepting a new graduate on an eating disorders unit. The graduate explains why several interventions are in a client''s plan of care. Which statements show accurate understanding? Select all that apply.',
    options = '[
      {"id":"a","text":"Weighing the client daily at the same time in the same clothing helps detect water-loading or weight manipulation"},
      {"id":"b","text":"Monitoring intake and output is what prevents the client from purging after meals"},
      {"id":"c","text":"Removing diet pills from the unit is done mainly to reduce power struggles over food"},
      {"id":"d","text":"Behavioral contracts give the client structure and involvement in recovery"},
      {"id":"e","text":"Avoiding conversation about food is what prevents the client from purging after meals"}
    ]'::jsonb
WHERE id = 26716;
