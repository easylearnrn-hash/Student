-- Applied live: question 2258 rewritten as a clear question about the Buerger disease risk profile. Answer key stays a, c, e.
UPDATE test_questions SET
 question_stem = $q$A nurse is reviewing who is at risk for thromboangiitis obliterans (Buerger disease). Which statements are accurate? Select all that apply.$q$,
 question = $q$A nurse is reviewing who is at risk for thromboangiitis obliterans (Buerger disease). Which statements are accurate? Select all that apply.$q$,
 options = $q$[
  {"id":"a","text":"Women are affected less often, but the number is rising as more women use tobacco"},
  {"id":"b","text":"A client's age and gender have no connection to the risk"},
  {"id":"c","text":"Most affected clients are men younger than 45 years"},
  {"id":"d","text":"It occurs mainly in elderly adults who have never used tobacco"},
  {"id":"e","text":"Heavy tobacco use is the central risk factor"}
 ]$q$::jsonb,
 rationale = $q$Buerger disease is strongly linked to heavy tobacco use and most often affects men younger than 45. Women are affected less often, but their numbers are rising as tobacco use among women increases. It is not a disease of elderly nonsmokers, and age and gender are important parts of the risk profile.$q$
WHERE id = 2258;
