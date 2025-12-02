-- ============================================================
-- STUDENT SELF-REGISTRATION SUPPORT FUNCTION
-- ============================================================
-- Gives the public site a safe way to verify that an email
-- exists in the students table without exposing the whole table.
-- ============================================================

CREATE OR REPLACE FUNCTION public.verify_student_registration_email(
  p_email text
)
RETURNS TABLE (
  id bigint,
  name text,
  email text,
  auth_user_id uuid
)
LANGUAGE sql
SECURITY DEFINER
SET search_path = public
AS $$
  WITH normalized_input AS (
    SELECT lower(trim(p_email)) AS target_email
  )
  SELECT s.id, s.name, s.email, s.auth_user_id
  FROM students s
  CROSS JOIN normalized_input input
  CROSS JOIN LATERAL (
    SELECT trim(COALESCE(s.email::text, '')) AS email_text
  ) raw_value
  CROSS JOIN LATERAL (
    SELECT lower(trim(both '"' FROM trim(candidate))) AS normalized_email
    FROM regexp_split_to_table(
      CASE
        WHEN raw_value.email_text LIKE '[%' AND raw_value.email_text LIKE '%]'
          THEN trim(both '[]' FROM raw_value.email_text)
        ELSE raw_value.email_text
      END,
      ','
    ) AS candidate
  ) email_candidates
  WHERE email_candidates.normalized_email <> ''
    AND email_candidates.normalized_email = input.target_email
  LIMIT 1;
$$;

GRANT EXECUTE ON FUNCTION public.verify_student_registration_email(text)
TO anon, authenticated;

-- ============================================================
-- LINK AUTH USER TO STUDENT RECORD (BYPASSES RLS SAFELY)
-- ============================================================

CREATE OR REPLACE FUNCTION public.link_student_auth_account(
  p_student_id bigint,
  p_auth_user_id uuid
)
RETURNS TABLE (
  id bigint,
  name text,
  email text,
  auth_user_id uuid,
  role text
)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  updated_record students%ROWTYPE;
BEGIN
  IF p_student_id IS NULL OR p_auth_user_id IS NULL THEN
    RAISE EXCEPTION 'Student ID and auth user ID are both required.' USING ERRCODE = '23502';
  END IF;

  UPDATE students s
  SET auth_user_id = p_auth_user_id,
      role = COALESCE(s.role, 'student')
  WHERE s.id = p_student_id
    AND (s.auth_user_id IS NULL OR s.auth_user_id = p_auth_user_id)
  RETURNING * INTO updated_record;

  IF NOT FOUND THEN
    IF EXISTS (SELECT 1 FROM students s WHERE s.id = p_student_id) THEN
      RAISE EXCEPTION 'This student record is already linked to a different account.' USING ERRCODE = '23505';
    ELSE
      RAISE EXCEPTION 'Student record not found for the provided ID.' USING ERRCODE = 'P0002';
    END IF;
  END IF;

  RETURN QUERY
  SELECT updated_record.id,
         updated_record.name,
         updated_record.email,
         updated_record.auth_user_id,
         updated_record.role;
END;
$$;

GRANT EXECUTE ON FUNCTION public.link_student_auth_account(bigint, uuid)
TO anon, authenticated;
