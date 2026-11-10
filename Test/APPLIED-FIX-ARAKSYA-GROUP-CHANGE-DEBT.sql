-- Applied live 2026-11-10. Araksya Dulbenchyan (student 15) moved from Group A (Tue/Thu) to Group P (Mon/Wed).
-- With no start_date, Group P's schedule was charged back to May 2026 ($5,300 unpaid).
-- Her debt floor is set to the day of the move (Los Angeles date) so only classes from then on count.
-- Previous value: start_date = NULL.
update students set start_date = '2026-11-09' where id = 15 and start_date is null;

-- Correction, same day: moving her debt floor to Nov 9 also hid her real Group A debt (Tue/Thu classes she
-- attended and did not pay). Those three classes were added back as explicit Group A classes
-- (what Calendar's "Add student to class" writes) by keepOldGroupDebtOnMove() in Student-Manager.html.
-- Result: Group A Oct 22, Oct 27, Nov 3 + Group P Nov 9 = $400; the phantom Mon/Wed weeks stay removed.
insert into payment_records (student_id, date, amount, status, payment_method, notes, class_group) values
  (15, '2026-10-22', 0, 'unpaid', 'manual_enrollment', 'A', 'A'),
  (15, '2026-10-27', 0, 'unpaid', 'manual_enrollment', 'A', 'A'),
  (15, '2026-11-03', 0, 'unpaid', 'manual_enrollment', 'A', 'A');
-- (rows 1175-1177 already inserted live; do not run this again)
