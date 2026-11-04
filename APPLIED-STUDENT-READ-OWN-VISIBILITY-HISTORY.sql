-- APPLIED 2026-11-04 to the live database.
--
-- WHY: student-portal.html skips class dates while a student was paused/hidden (student_visibility_history),
-- exactly like Calendar-NEW / Student-Manager. But the table only had an admin policy, so a student's own session
-- read ZERO rows and the portal treated every student as active on every date. Result: paused periods and
-- classes before a student (re)started showed as unpaid in the portal (e.g. Taguhi Barseghyan: $200 instead of $100,
-- Sep 8 Group A class counted while she was not active). 66 students have history rows.
--
-- WHAT: a student may SELECT only their own rows (student_id matches their students row). The columns are only
-- visible / effective_date, nothing sensitive. The admin policy and write access are unchanged.
--
-- ROLLBACK:  DROP POLICY "Students read own visibility history" ON student_visibility_history;

CREATE POLICY "Students read own visibility history"
  ON student_visibility_history
  FOR SELECT
  TO authenticated
  USING (
    student_id IN (
      SELECT s.id FROM students s WHERE s.auth_user_id = (SELECT auth.uid())
    )
  );
