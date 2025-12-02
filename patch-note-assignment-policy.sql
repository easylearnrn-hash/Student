-- Patch: Align note assignment policy with canonical group codes
-- Run this in Supabase SQL editor after deploying to production.

BEGIN;

DROP POLICY IF EXISTS "Students can view assigned notes" ON public.note_assignments;

CREATE POLICY "Students can view assigned notes"
  ON public.note_assignments
  FOR SELECT
  USING (
    deleted_at IS NULL
    AND EXISTS (
      SELECT 1
      FROM public.students
      WHERE students.email = auth.jwt() ->> 'email'
        AND students.show_in_grid IS TRUE
        AND UPPER(
          REGEXP_REPLACE(COALESCE(students.group_name, ''), '^group\\s*', '')
        ) = UPPER(
          REGEXP_REPLACE(COALESCE(public.note_assignments.group_id, ''), '^group\\s*', '')
        )
    )
  );

COMMIT;

