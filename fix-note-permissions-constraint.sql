-- Fix student_note_permissions table constraint issue
-- This adds the missing unique constraint that the INSERT ... ON CONFLICT needs

-- First, check if the table exists and what constraints it has
SELECT * FROM pg_constraint WHERE conrelid = 'student_note_permissions'::regclass;

-- Drop existing table if it has issues
DROP TABLE IF EXISTS student_note_permissions CASCADE;

-- Recreate with proper constraints
CREATE TABLE student_note_permissions (
  id BIGSERIAL PRIMARY KEY,
  note_id BIGINT NOT NULL REFERENCES student_notes(id) ON DELETE CASCADE,
  student_id BIGINT REFERENCES students(id) ON DELETE CASCADE,
  group_name TEXT,
  is_accessible BOOLEAN DEFAULT true,
  granted_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  granted_by TEXT,
  
  -- CRITICAL: Add unique constraint for ON CONFLICT to work
  UNIQUE(note_id, student_id, group_name)
);

-- Create indexes for performance
CREATE INDEX idx_note_permissions_note ON student_note_permissions(note_id);
CREATE INDEX idx_note_permissions_student ON student_note_permissions(student_id);
CREATE INDEX idx_note_permissions_group ON student_note_permissions(group_name);
CREATE INDEX idx_note_permissions_accessible ON student_note_permissions(is_accessible);

-- Enable RLS
ALTER TABLE student_note_permissions ENABLE ROW LEVEL SECURITY;

-- Policy: Students can read their own permissions
CREATE POLICY "Students can view their note permissions"
  ON student_note_permissions
  FOR SELECT
  USING (
    auth.uid() IN (SELECT auth_user_id FROM students WHERE id = student_id)
    OR group_name IS NOT NULL
  );

-- Policy: Admins can manage all permissions
CREATE POLICY "Admins can manage note permissions"
  ON student_note_permissions
  FOR ALL
  USING (
    EXISTS (
      SELECT 1 FROM admin_accounts 
      WHERE email = (SELECT email FROM auth.users WHERE id = auth.uid())
    )
  );

-- Grant permissions
GRANT ALL ON student_note_permissions TO authenticated;
GRANT USAGE, SELECT ON SEQUENCE student_note_permissions_id_seq TO authenticated;
