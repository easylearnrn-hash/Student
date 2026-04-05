-- Drop the existing policy
DROP POLICY IF EXISTS "payments_select_policy" ON payments;

-- Create the new, more inclusive policy
CREATE POLICY "payments_select_policy"
ON payments FOR SELECT
USING (
  -- Admin can see everything
  is_arnoma_admin()
  OR
  -- Student can see records explicitly linked to them via student_id OR linked_student_id
  (
    (student_id IS NOT NULL AND student_id::bigint IN (SELECT id FROM students WHERE auth_user_id = auth.uid()))
    OR
    (linked_student_id IS NOT NULL AND linked_student_id::bigint IN (SELECT id FROM students WHERE auth_user_id = auth.uid()))
  )
  OR
  -- Allow student to see unlinked records that closely match their name/aliases 
  EXISTS (
    SELECT 1 FROM students s 
    WHERE s.auth_user_id = auth.uid() 
    AND (
      -- Only match if payment doesn't explicitly belong to someone else
      (payments.student_id IS NULL AND payments.linked_student_id IS NULL)
      AND
      (
        payments.payer_name ILIKE '%' || s.name || '%'
        OR payments.resolved_student_name ILIKE '%' || s.name || '%'
        -- Since aliases is a TEXT column, we can do a simple substring match
        -- If payer_name is found anywhere inside the aliases string, it's a match
        OR (
          s.aliases IS NOT NULL 
          AND s.aliases != '' 
          AND s.aliases != '[]'
          AND (
            s.aliases ILIKE '%' || payments.payer_name || '%'
            OR s.aliases ILIKE '%' || payments.resolved_student_name || '%'
          )
        )
      )
    )
  )
);
