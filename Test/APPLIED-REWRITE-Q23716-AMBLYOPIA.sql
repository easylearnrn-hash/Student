-- Applied live: question 23716 reworded so every option is a clear parent call; answer key stays b.
UPDATE test_questions SET
 question_stem = $q$A pediatric eye clinic nurse is returning voicemail messages from parents of four children treated for amblyopia ("lazy eye"). Which parent should the nurse call back FIRST?$q$,
 question = $q$A pediatric eye clinic nurse is returning voicemail messages from parents of four children treated for amblyopia ("lazy eye"). Which parent should the nurse call back FIRST?$q$,
 options = $q$[
  {"id":"a","text":"The parent of a 5-year-old who wants to reschedule a routine patch check for next month"},
  {"id":"b","text":"The parent of a 4-year-old who stopped patching the stronger eye 2 months ago"},
  {"id":"c","text":"The parent of a 7-year-old on atropine drops who reports blurred near vision in the treated eye"},
  {"id":"d","text":"The parent of a 12-year-old with long-standing amblyopia who needs a letter for a school sports team"}
 ]$q$::jsonb,
 rationale = $q$Treatment works best in early childhood, and success depends on the child wearing the patch or receiving the drops as prescribed. A 4-year-old who has stopped patching is losing vision gains during the most effective treatment period, so this lapse needs attention first. Blurred near vision in the eye that receives atropine is an expected effect of the drops, a routine patch check can wait, and a sports letter is not urgent.$q$
WHERE id = 23716;
