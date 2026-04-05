CREATE OR REPLACE FUNCTION get_my_zelle_payments(p_student_id bigint)
RETURNS SETOF payments
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_student RECORD;
  v_name_lower text;
  v_alias_lower text;
BEGIN
  -- 1) Verify permissions: Admin OR the active student
  IF NOT is_arnoma_admin() THEN
    IF auth.uid() IS NULL OR NOT EXISTS (
      SELECT 1 FROM students WHERE id = p_student_id AND auth_user_id = auth.uid()
    ) THEN
      RAISE EXCEPTION 'Not authorized to view payments for this student';
    END IF;
  END IF;

  RETURN QUERY
  SELECT p.* FROM payments p
  WHERE 
    p.student_id = p_student_id 
    OR p.linked_student_id = p_student_id
    OR EXISTS (
      SELECT 1 FROM students s 
      WHERE s.id = p_student_id AND 
      (
        -- Check if any of the payment names contains the student name 
        (p.payer_name ILIKE '%' || s.name || '%') OR
        (p.resolved_student_name ILIKE '%' || s.name || '%') OR
        -- Check aliases
        (
          SELECT bool_or(
            p.payer_name ILIKE '%' || a || '%' OR
            p.resolved_student_name ILIKE '%' || a || '%' OR
            p.student_name ILIKE '%' || a || '%'
          ) FROM unnest(s.aliases) as a WHERE a != ''
        )
      )
    );
END;
$$;
