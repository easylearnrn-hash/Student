-- Allow authenticated students to insert their own payment_records rows.
-- Required for Stripe payments: student-portal.html writes a payment_records row
-- after a successful Stripe charge using the student's own JWT session.
-- Without this, the insert silently fails (RLS blocks it) and the green dot
-- never appears in Calendar-NEW.
--
-- Run this in Supabase SQL Editor.

CREATE POLICY "Students can insert own stripe payments"
ON payment_records FOR INSERT
TO authenticated
WITH CHECK (
  student_id::text IN (
    SELECT id::text FROM students WHERE auth_user_id = auth.uid()
  )
);
