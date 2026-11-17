-- Applied live 2026-11-17. Q4148 asked "What does the two-nurse bedside check include?" without saying which check.
-- The stem now states it is the check before a blood transfusion. Options and answer key are unchanged.
-- Previous text is in the session backup question-4148-backup.json.
update test_questions set
  question_stem = $q$Before a blood transfusion is started, what does the two-nurse bedside check include? Select all that apply.$q$,
  question      = $q$Before a blood transfusion is started, what does the two-nurse bedside check include? Select all that apply.$q$,
  rationale     = $q$Before a transfusion, two nurses check the patient ID, the blood bank label, the expiration and the blood type together at the bedside. The IV catheter color, the tubing color and the client's insurance number are not part of this check.$q$
where id = 4148;
