-- Wrap is_arnoma_admin() as (SELECT is_arnoma_admin()) so Postgres evaluates it once per query,
-- not once per row. Pure text substitution: the result is identical, only the number of calls changes.
ALTER POLICY "Admins full access to note_free_access" ON public.note_free_access
  USING ((SELECT is_arnoma_admin()))
  WITH CHECK ((SELECT is_arnoma_admin()));
ALTER POLICY "Students can view free access" ON public.note_free_access
  USING ((((access_type = 'individual'::text) AND (student_id IN ( SELECT students.id
   FROM students
  WHERE ((students.auth_user_id = auth.uid()) OR (lower(TRIM(BOTH FROM students.email)) = lower(TRIM(BOTH FROM (auth.jwt() ->> 'email'::text)))))))) OR ((access_type = 'group'::text) AND (group_letter IN ( SELECT upper(regexp_replace(COALESCE(students.group_name, ''::text), '^[Gg]roup\s*'::text, ''::text)) AS upper
   FROM students
  WHERE (((students.auth_user_id = auth.uid()) OR (lower(TRIM(BOTH FROM students.email)) = lower(TRIM(BOTH FROM (auth.jwt() ->> 'email'::text))))) AND (students.created_at <= note_free_access.created_at))))) OR ((access_type = 'group'::text) AND (class_date IS NOT NULL) AND (EXISTS ( SELECT 1
   FROM (payment_records pr
     JOIN students s ON (((s.auth_user_id = auth.uid()) OR (lower(TRIM(BOTH FROM s.email)) = lower(TRIM(BOTH FROM (auth.jwt() ->> 'email'::text)))))))
  WHERE ((pr.student_id = s.id) AND (lower(TRIM(BOTH FROM pr.payment_method)) = 'manual_enrollment'::text) AND (pr.notes IS NOT NULL) AND (upper(regexp_replace(TRIM(BOTH FROM pr.notes), '^[Gg]roup\s*'::text, ''::text)) = upper(regexp_replace(TRIM(BOTH FROM note_free_access.group_letter), '^[Gg]roup\s*'::text, ''::text))) AND (pr.date = note_free_access.class_date))))) OR (SELECT is_arnoma_admin())));
ALTER POLICY "Admins full access to note permissions" ON public.student_note_permissions
  USING ((SELECT is_arnoma_admin()))
  WITH CHECK ((SELECT is_arnoma_admin()));
ALTER POLICY "Students can read own permissions" ON public.student_note_permissions
  USING (((student_id IN ( SELECT students.id
   FROM students
  WHERE ((students.auth_user_id = auth.uid()) OR (lower(TRIM(BOTH FROM students.email)) = lower(TRIM(BOTH FROM (auth.jwt() ->> 'email'::text))))))) OR ((student_id IS NULL) AND ((group_name IN ( SELECT students.group_name
   FROM students
  WHERE ((students.auth_user_id = auth.uid()) OR (lower(TRIM(BOTH FROM students.email)) = lower(TRIM(BOTH FROM (auth.jwt() ->> 'email'::text))))))) OR (group_name IN ( SELECT replace(students.group_name, 'Group '::text, ''::text) AS replace
   FROM students
  WHERE ((students.auth_user_id = auth.uid()) OR (lower(TRIM(BOTH FROM students.email)) = lower(TRIM(BOTH FROM (auth.jwt() ->> 'email'::text))))))) OR (group_name IN ( SELECT ('Group '::text || replace(students.group_name, 'Group '::text, ''::text))
   FROM students
  WHERE ((students.auth_user_id = auth.uid()) OR (lower(TRIM(BOTH FROM students.email)) = lower(TRIM(BOTH FROM (auth.jwt() ->> 'email'::text))))))))) OR ((student_id IS NULL) AND (class_date IS NOT NULL) AND (EXISTS ( SELECT 1
   FROM (payment_records pr
     JOIN students s ON (((s.auth_user_id = auth.uid()) OR (lower(TRIM(BOTH FROM s.email)) = lower(TRIM(BOTH FROM (auth.jwt() ->> 'email'::text)))))))
  WHERE ((pr.student_id = s.id) AND (lower(TRIM(BOTH FROM pr.payment_method)) = 'manual_enrollment'::text) AND (pr.notes IS NOT NULL) AND (upper(regexp_replace(TRIM(BOTH FROM pr.notes), '^[Gg]roup\s*'::text, ''::text)) = upper(regexp_replace(TRIM(BOTH FROM student_note_permissions.group_name), '^[Gg]roup\s*'::text, ''::text))) AND (pr.date = student_note_permissions.class_date))))) OR (SELECT is_arnoma_admin())));
ALTER POLICY "Admins have full access to notes" ON public.student_notes
  USING ((SELECT is_arnoma_admin()))
  WITH CHECK ((SELECT is_arnoma_admin()));
ALTER POLICY "Students can view accessible notes" ON public.student_notes
  USING (((deleted = false) AND ((id IN ( SELECT nfa.note_id
   FROM (note_free_access nfa
     JOIN students s ON (((s.auth_user_id = auth.uid()) OR (lower(TRIM(BOTH FROM s.email)) = lower(TRIM(BOTH FROM (auth.jwt() ->> 'email'::text)))))))
  WHERE ((nfa.access_type = 'individual'::text) AND (nfa.student_id = s.id)))) OR (id IN ( SELECT nfa.note_id
   FROM (note_free_access nfa
     JOIN students s ON (((s.auth_user_id = auth.uid()) OR (lower(TRIM(BOTH FROM s.email)) = lower(TRIM(BOTH FROM (auth.jwt() ->> 'email'::text)))))))
  WHERE ((nfa.access_type = 'group'::text) AND (nfa.group_letter = upper(regexp_replace(COALESCE(s.group_name, ''::text), '^[Gg]roup\s*'::text, ''::text))) AND (s.created_at <= nfa.created_at)))) OR (id IN ( SELECT snp.note_id
   FROM (student_note_permissions snp
     JOIN students s ON (((s.auth_user_id = auth.uid()) OR (lower(TRIM(BOTH FROM s.email)) = lower(TRIM(BOTH FROM (auth.jwt() ->> 'email'::text)))))))
  WHERE ((snp.is_accessible = true) AND (snp.student_id = s.id)))) OR (EXISTS ( SELECT 1
   FROM (student_note_permissions snp
     JOIN students s ON (((s.auth_user_id = auth.uid()) OR (lower(TRIM(BOTH FROM s.email)) = lower(TRIM(BOTH FROM (auth.jwt() ->> 'email'::text)))))))
  WHERE ((snp.note_id = student_notes.id) AND (snp.is_accessible = true) AND (snp.student_id IS NULL) AND (upper(regexp_replace(COALESCE(snp.group_name, ''::text), '^[Gg]roup\s*'::text, ''::text)) = upper(regexp_replace(COALESCE(s.group_name, ''::text), '^[Gg]roup\s*'::text, ''::text))) AND (s.created_at <= student_notes.created_at)))) OR (EXISTS ( SELECT 1
   FROM ((student_note_permissions snp
     JOIN students s ON (((s.auth_user_id = auth.uid()) OR (lower(TRIM(BOTH FROM s.email)) = lower(TRIM(BOTH FROM (auth.jwt() ->> 'email'::text)))))))
     JOIN payment_records pr ON (((pr.student_id = s.id) AND (lower(TRIM(BOTH FROM pr.payment_method)) = 'manual_enrollment'::text) AND (pr.notes IS NOT NULL) AND (upper(regexp_replace(TRIM(BOTH FROM pr.notes), '^[Gg]roup\s*'::text, ''::text)) = upper(regexp_replace(COALESCE(snp.group_name, ''::text), '^[Gg]roup\s*'::text, ''::text))) AND (pr.date = snp.class_date))))
  WHERE ((snp.note_id = student_notes.id) AND (snp.is_accessible = true) AND (snp.student_id IS NULL)))) OR (SELECT is_arnoma_admin()))));
ALTER POLICY "Admins have full access to students" ON public.students
  USING ((SELECT is_arnoma_admin()));
ALTER POLICY "Students can read own record" ON public.students
  USING (((NOT (SELECT is_arnoma_admin())) AND (auth_user_id = auth.uid())));
ALTER POLICY "Students can update own record" ON public.students
  USING (((NOT (SELECT is_arnoma_admin())) AND (auth_user_id = auth.uid())))
  WITH CHECK (((NOT (SELECT is_arnoma_admin())) AND (auth_user_id = auth.uid())));
ALTER POLICY "Students can view own profile" ON public.students
  USING (((SELECT is_arnoma_admin()) OR ((auth_user_id)::text = (auth.uid())::text)));
