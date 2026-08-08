-- Add portal_blocked column to students table
-- When true, the student is blocked from accessing the student portal
-- and is redirected to the payment gate on login.
ALTER TABLE students ADD COLUMN IF NOT EXISTS portal_blocked boolean DEFAULT false;
