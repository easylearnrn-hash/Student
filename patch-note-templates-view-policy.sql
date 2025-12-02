-- Patch: Allow students to SELECT note_templates linked to their group assignments
-- Run this after deploying to production.

BEGIN;

DROP POLICY IF EXISTS "Students can view note templates" ON public.note_templates;

CREATE POLICY "Students can view note templates"
  ON public.note_templates
  FOR SELECT
  USING (
    deleted_at IS NULL
    AND EXISTS (
      SELECT 1
      FROM public.note_assignments
      WHERE note_assignments.template_id = public.note_templates.id
        AND note_assignments.deleted_at IS NULL
        AND EXISTS (
          SELECT 1
          FROM public.students
          WHERE students.email = auth.jwt() ->> 'email'
            AND students.show_in_grid IS TRUE
            AND UPPER(
              REGEXP_REPLACE(COALESCE(students.group_name, ''), '^group\\s*', '')
            ) = UPPER(
              REGEXP_REPLACE(COALESCE(note_assignments.group_id, ''), '^group\\s*', '')
            )
        )
    )
  );

COMMIT;
