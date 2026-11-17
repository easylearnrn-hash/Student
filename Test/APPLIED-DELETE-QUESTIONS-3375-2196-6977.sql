-- Applied live 2026-11-17: questions removed permanently at the admin's request (flagged as unclear/incomplete).
--   2196  dabigatran "profile" Select-all item
--   3375  pericarditis / Dressler "management caveat" Select-all item
--   6977  AHI of 12 sleep-apnea interpretation item
-- Full row backups (and the rows that pointed at them) are in the session files, deleted-questions-3375-2196-6977-*.
begin;
delete from question_note_links where question_id in (3375,2196,6977);
delete from question_review where question_id in (3375,2196,6977) or duplicate_of in (3375,2196,6977);
delete from question_revisions where question_id in (3375,2196,6977);
delete from question_flags where question_id in (3375,2196,6977);
delete from qbank_questions where question_id in (3375,2196,6977);
delete from test_questions where id in (3375,2196,6977);
commit;
