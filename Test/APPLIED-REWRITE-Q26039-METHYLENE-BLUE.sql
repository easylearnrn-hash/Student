-- Applied live: question 26039 reworded (clear vignette, complete options, no "listed" wording). Answer key stays d.
UPDATE test_questions SET
 question_stem = $q$A client who takes duloxetine (Cymbalta) for depression is scheduled for a procedure in which methylene blue will be given intravenously. Which action should the nurse take FIRST?$q$,
 question = $q$A client who takes duloxetine (Cymbalta) for depression is scheduled for a procedure in which methylene blue will be given intravenously. Which action should the nurse take FIRST?$q$,
 options = $q$[
  {"id":"a","text":"Proceed with the procedure because methylene blue is only a dye"},
  {"id":"b","text":"Give the duloxetine dose together with the procedure medications"},
  {"id":"c","text":"Plan to check the creatine kinase (CK) level after the procedure"},
  {"id":"d","text":"Tell the provider that the client takes duloxetine before the methylene blue is given"}
 ]$q$::jsonb,
 rationale = $q$Methylene blue acts as a monoamine oxidase inhibitor (MAOI), and duloxetine is a serotonin-norepinephrine reuptake inhibitor (SNRI). Combining them can cause serotonin syndrome, so the nurse must tell the provider before the drug is given so the order can be changed. Checking creatine kinase afterward does not prevent the interaction, and methylene blue is not a harmless dye.$q$
WHERE id = 26039;
