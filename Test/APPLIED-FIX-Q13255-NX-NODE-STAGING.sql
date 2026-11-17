-- Applied live 2026-11-17. Q13255 ("A client's staging report lists NX") did not say it is TNM cancer staging or what N means.
-- Rewritten to be self-explanatory; the answer is unchanged (NX = regional lymph nodes cannot be assessed, option d).
-- Previous text is in the session backup question-13255-backup.json.
update test_questions set
  question_stem = $q$A client's cancer staging report uses the TNM (tumor, node, metastasis) system, where N describes the lymph nodes near the tumor. The report lists the node category as NX. How should the nurse interpret NX?$q$,
  question      = $q$A client's cancer staging report uses the TNM (tumor, node, metastasis) system, where N describes the lymph nodes near the tumor. The report lists the node category as NX. How should the nurse interpret NX?$q$,
  options       = $q$[{"id": "a", "text": "There is no cancer in the nearby lymph nodes"}, {"id": "b", "text": "There is cancer in a few nearby lymph nodes"}, {"id": "c", "text": "There is cancer in many nearby lymph nodes"}, {"id": "d", "text": "The nearby lymph nodes could not be assessed"}]$q$::jsonb,
  rationale     = $q$In TNM staging, N describes the regional lymph nodes near the tumor. NX means those lymph nodes cannot be assessed. N0 means there is no lymph node involvement, and N1 through N3 mean increasing involvement.$q$
where id = 13255;
