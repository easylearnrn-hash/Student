-- Applied live 2026-11-07. Naira Grigoryan (student 150, home group G) paid Oct 24 (Group F one-time class)
-- and Oct 25 (Group G class) in one Stripe payment; both rows were tagged class_group = 'F'.
-- The Oct 25 row is a home-group class, so its tag is cleared (home-group rows carry no tag).
update payment_records set class_group = null where id = 1094 and student_id = 150 and date = '2026-10-25' and class_group = 'F';
