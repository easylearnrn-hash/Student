-- Adds a class_group column so payment/credit tracking can distinguish
-- between two different groups' classes for the same student on the same
-- date (needed for cross-group one-time "Add Student" enrollments in
-- Calendar-NEW.html). NULL class_group = the student's normal/home-group
-- class, so all existing rows keep working unchanged.

ALTER TABLE public.payment_records ADD COLUMN IF NOT EXISTS class_group TEXT;
ALTER TABLE public.credit_payments ADD COLUMN IF NOT EXISTS class_group TEXT;

-- credit_payments currently has a UNIQUE(student_id, class_date) constraint,
-- which blocks a student from having two credit payments on the same date
-- (one per group). Relax it to include class_group.
DO $$
DECLARE
  cname text;
BEGIN
  SELECT con.conname INTO cname
  FROM pg_constraint con
  JOIN pg_class rel ON rel.oid = con.conrelid
  WHERE rel.relname = 'credit_payments'
    AND con.contype = 'u'
    AND con.conkey = (
      SELECT array_agg(attnum ORDER BY attnum)
      FROM pg_attribute
      WHERE attrelid = rel.oid AND attname IN ('student_id', 'class_date')
    )
  LIMIT 1;

  IF cname IS NOT NULL THEN
    EXECUTE format('ALTER TABLE public.credit_payments DROP CONSTRAINT %I', cname);
  END IF;
END $$;

CREATE UNIQUE INDEX IF NOT EXISTS credit_payments_student_date_group_unique
  ON public.credit_payments (student_id, class_date, COALESCE(class_group, ''));
