-- ============================================================
-- NOTE FREE ACCESS TABLE
-- Stores free access grants (payment bypass) for notes
-- Supports both group-level and individual student access
-- ============================================================

-- Create table
CREATE TABLE IF NOT EXISTS note_free_access (
  id BIGSERIAL PRIMARY KEY,
  note_id BIGINT NOT NULL REFERENCES student_notes(id) ON DELETE CASCADE,
  access_type TEXT NOT NULL CHECK (access_type IN ('group', 'individual')),
  group_letter TEXT CHECK (group_letter IN ('A', 'B', 'C', 'D', 'E', 'F')),
  student_id BIGINT REFERENCES students(id) ON DELETE CASCADE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  created_by TEXT,
  
  -- Ensure either group_letter OR student_id is set (not both)
  CONSTRAINT free_access_type_check CHECK (
    (access_type = 'group' AND group_letter IS NOT NULL AND student_id IS NULL) OR
    (access_type = 'individual' AND student_id IS NOT NULL AND group_letter IS NULL)
  ),
  
  -- Prevent duplicates
  CONSTRAINT unique_group_access UNIQUE (note_id, group_letter),
  CONSTRAINT unique_student_access UNIQUE (note_id, student_id)
);

-- Create indexes for performance
CREATE INDEX idx_note_free_access_note_id ON note_free_access(note_id);
CREATE INDEX idx_note_free_access_group ON note_free_access(group_letter) WHERE group_letter IS NOT NULL;
CREATE INDEX idx_note_free_access_student ON note_free_access(student_id) WHERE student_id IS NOT NULL;

-- Enable RLS
ALTER TABLE note_free_access ENABLE ROW LEVEL SECURITY;

-- Admin policy: Full access
CREATE POLICY "Admin full access to note_free_access"
  ON note_free_access
  FOR ALL
  USING (
    EXISTS (
      SELECT 1 FROM admin_accounts
      WHERE email = auth.jwt() ->> 'email'
    )
  );

-- Student policy: Read only for their own access records
CREATE POLICY "Students can view their free access"
  ON note_free_access
  FOR SELECT
  USING (
    -- Check if student has free access via group
    (
      access_type = 'group'
      AND group_letter = (
        SELECT group_letter FROM students
        WHERE auth_user_id = auth.uid()
      )
    )
    OR
    -- Check if student has individual free access
    (
      access_type = 'individual'
      AND student_id IN (
        SELECT id FROM students
        WHERE auth_user_id = auth.uid()
      )
    )
  );

-- Comments
COMMENT ON TABLE note_free_access IS 'Stores free access grants (payment bypass) for student notes';
COMMENT ON COLUMN note_free_access.note_id IS 'References student_notes.id';
COMMENT ON COLUMN note_free_access.access_type IS 'Type of access: group (whole group) or individual (specific students)';
COMMENT ON COLUMN note_free_access.group_letter IS 'Group letter (A-F) for group-level free access';
COMMENT ON COLUMN note_free_access.student_id IS 'Student ID for individual free access';
COMMENT ON COLUMN note_free_access.created_by IS 'Admin email who granted the access';

