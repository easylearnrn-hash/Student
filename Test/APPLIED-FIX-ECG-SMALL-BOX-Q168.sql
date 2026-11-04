-- Applied live: question 168 had a vague stem ("Small Box") and a broken option ("It QRS width, P-wave duration").
-- Rewritten as a clear ECG-grid question. Answer key stays a, b, e (three correct).
UPDATE test_questions
SET question = 'A nurse is teaching a nursing student how to read an ECG strip printed on standard ECG paper. Which statements about ONE small box on the grid are accurate? (Select all that apply)',
    options = '[
      {"id":"a","text":"Five small boxes make up one large box, which represents 0.20 seconds"},
      {"id":"b","text":"It measures 1 mm in width"},
      {"id":"c","text":"It represents 0.20 seconds on the horizontal axis"},
      {"id":"d","text":"It is used only for voltage and cannot be used to measure time"},
      {"id":"e","text":"It represents 0.04 seconds on the horizontal axis"}
    ]'::jsonb,
    rationale = 'On standard ECG paper, one small box is 1 mm wide and equals 0.04 seconds horizontally (and 0.1 mV vertically). Five small boxes make one large box, which equals 0.20 seconds. A small box does not equal 0.20 seconds (that is a large box), and the grid is used to measure both time (horizontal) and voltage (vertical). Counting small boxes is how the nurse measures the PR interval, QRS width and other intervals.'
WHERE id = 168;
