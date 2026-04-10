-- ============================================================
-- CLASS TAGS TABLE
-- ============================================================
-- Purpose: Store topic tags for specific group classes on specific dates
-- Each tag is a note name that represents what topic was covered
-- Tags are group-specific and date-specific (no sharing between groups)

-- Drop existing table if needed (CAUTION: removes all data)
-- DROP TABLE IF EXISTS class_tags CASCADE;

CREATE TABLE IF NOT EXISTS class_tags (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  class_date DATE NOT NULL,
  group_name TEXT NOT NULL,
  note_name TEXT NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  created_by UUID REFERENCES auth.users(id),
  
  -- Prevent duplicate tags for same group/date/note combination
  CONSTRAINT unique_class_tag UNIQUE(class_date, group_name, note_name)
);

-- Drop existing indexes if they exist
DROP INDEX IF EXISTS idx_class_tags_date_group;
DROP INDEX IF EXISTS idx_class_tags_group;
DROP INDEX IF EXISTS idx_class_tags_date;

-- Indexes for fast lookups
CREATE INDEX idx_class_tags_date_group ON class_tags(class_date, group_name);
CREATE INDEX idx_class_tags_group ON class_tags(group_name);
CREATE INDEX idx_class_tags_date ON class_tags(class_date);

-- ============================================================
-- RLS POLICIES
-- ============================================================

-- Enable RLS
ALTER TABLE class_tags ENABLE ROW LEVEL SECURITY;

-- Drop existing policies if they exist
DROP POLICY IF EXISTS "Admins can manage class tags" ON class_tags;
DROP POLICY IF EXISTS "Students can view their group tags" ON class_tags;
DROP POLICY IF EXISTS "Anon can read class tags" ON class_tags;

-- Admin full access
CREATE POLICY "Admins can manage class tags"
ON class_tags
FOR ALL
USING (
  EXISTS (
    SELECT 1 FROM admin_accounts 
    WHERE admin_accounts.auth_user_id = auth.uid()
  )
);

-- Students can view tags for their own groups
CREATE POLICY "Students can view their group tags"
ON class_tags
FOR SELECT
USING (
  group_name IN (
    SELECT students.group_name 
    FROM students 
    WHERE students.auth_user_id = auth.uid()
  )
);

-- Anonymous can read (for impersonation mode)
CREATE POLICY "Anon can read class tags"
ON class_tags
FOR SELECT
TO anon
USING (true);

COMMENT ON TABLE class_tags IS 'Stores topic tags (note names) for specific group classes on specific dates. Group-specific and unlimited.';
COMMENT ON COLUMN class_tags.class_date IS 'Date of the class (YYYY-MM-DD format)';
COMMENT ON COLUMN class_tags.group_name IS 'Group identifier (A, B, C, etc.)';
COMMENT ON COLUMN class_tags.note_name IS 'Name of the note representing the topic covered';

-- Success message
DO $$
BEGIN
  RAISE NOTICE '✅ class_tags table created successfully!';
END $$;
