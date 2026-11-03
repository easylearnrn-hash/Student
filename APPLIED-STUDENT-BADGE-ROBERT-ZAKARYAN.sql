-- APPLIED 2026-11-03 to the live database (record only - safe to re-run: upsert).
-- Gold recognition badge for student 148 (Robert Zakaryan) for helping refine the question bank via the Teacher Inbox.
-- Shown at the top of "My Profile" in student-portal.html (loadProfileBadges). No schema/RLS change: uses the existing
-- portal_settings table (key "student_badge:<student id>", value {"badges":[{tier,title,note,awarded_at}]}).
-- To award another student: copy this statement with their student id as the key suffix.
insert into portal_settings (setting_key, setting_value, updated_by)
values (
  'student_badge:148',
  $j${"badges":[{"id":"question-bank-contributor","tier":"gold","title":"Question Bank Contributor","note":"Thank you for helping the question bank become more refined. Your feedback makes ARNOMA better for every student.","awarded_at":"2026-11-03"}]}$j$::jsonb,
  'admin'
)
on conflict (setting_key) do update set setting_value = excluded.setting_value, updated_at = now()
;
