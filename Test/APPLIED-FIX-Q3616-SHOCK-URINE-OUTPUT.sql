-- Applied live 2026-11-17. Q3616 was a template item ("Which clinical judgment is most accurate regarding Urine output target?")
-- with an unrelated distractor ("Cardiogenic treatment specifics"). Rewritten as a clear shock-monitoring question.
-- The answer is unchanged: urine output greater than 0.5 mL/kg/hr (option c). Both question columns now hold the same text.
-- Previous text is in the session backup question-3616-backup.json.
update test_questions set
  question_stem = $q$A nurse is caring for a client in shock who has an indwelling urinary (Foley) catheter. Which urine output shows that the kidneys are getting enough blood flow?$q$,
  question      = $q$A nurse is caring for a client in shock who has an indwelling urinary (Foley) catheter. Which urine output shows that the kidneys are getting enough blood flow?$q$,
  options       = $q$[{"id": "a", "text": "Less than 0.5 mL/kg/hr"}, {"id": "b", "text": "About 0.05 mL/kg/hr"}, {"id": "c", "text": "More than 0.5 mL/kg/hr"}, {"id": "d", "text": "Urine output no longer matters once oxygen is started"}]$q$::jsonb,
  rationale     = $q$In shock, urine output is a simple way to check kidney blood flow. The goal is more than 0.5 mL/kg/hr (for example, about 35 mL/hr for a 70-kg adult). A lower output means the kidneys are not getting enough blood and the treatment needs to be adjusted. Urine output stays important throughout shock care, not only until oxygen is started.$q$
where id = 3616;
