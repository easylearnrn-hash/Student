-- ============================================================
-- GROUP PERMISSIONS SYSTEM FOR STUDENT NOTES
-- ============================================================
-- This allows you to:
-- 1. Store ONE copy of each PDF (in system folders)
-- 2. Control which groups can access each PDF
-- 3. Update PDFs once and all groups see the changes
-- ============================================================

-- Step 1: Create new permissions table
CREATE TABLE IF NOT EXISTS student_note_permissions (
  id BIGSERIAL PRIMARY KEY,
  note_id BIGINT REFERENCES student_notes(id) ON DELETE CASCADE,
  group_name TEXT NOT NULL,
  is_accessible BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now(),
  UNIQUE(note_id, group_name)
);

-- Enable RLS
ALTER TABLE student_note_permissions ENABLE ROW LEVEL SECURITY;

-- Allow authenticated users to read permissions
CREATE POLICY "Allow authenticated users to read permissions"
ON student_note_permissions
FOR SELECT
TO authenticated
USING (true);

-- Allow authenticated users to manage permissions
CREATE POLICY "Allow authenticated users to manage permissions"
ON student_note_permissions
FOR ALL
TO authenticated
USING (true)
WITH CHECK (true);

-- Step 2: Modify student_notes table to remove group_name (it's now in permissions)
-- We'll keep group_name for backward compatibility but add a new field
ALTER TABLE student_notes 
ADD COLUMN IF NOT EXISTS is_system_note BOOLEAN DEFAULT false;

-- Step 3: Update existing notes to mark them as system notes
-- (Run this AFTER you've reorganized your storage to use system folders)
-- UPDATE student_notes SET is_system_note = true WHERE group_name IN (
--   'Medical Terminology',
--   'Human Anatomy',
--   'Medication Suffixes and Drug Classes',
--   -- ... etc for all 24 systems
-- );

-- ============================================================
-- EXAMPLE: Grant access to all groups for a specific note
-- ============================================================
-- After uploading a PDF, run this to make it available to all groups:
-- 
-- INSERT INTO student_note_permissions (note_id, group_name, is_accessible)
-- VALUES 
--   ((SELECT id FROM student_notes WHERE title = 'Cardiovascular System - Complete Notes'), 'Group A', true),
--   ((SELECT id FROM student_notes WHERE title = 'Cardiovascular System - Complete Notes'), 'Group B', true),
--   ((SELECT id FROM student_notes WHERE title = 'Cardiovascular System - Complete Notes'), 'Group C', false), -- Hidden for Group C
--   ((SELECT id FROM student_notes WHERE title = 'Cardiovascular System - Complete Notes'), 'Group D', true),
--   ((SELECT id FROM student_notes WHERE title = 'Cardiovascular System - Complete Notes'), 'Group E', true),
--   ((SELECT id FROM student_notes WHERE title = 'Cardiovascular System - Complete Notes'), 'Group F', true);

-- ============================================================
-- HELPER FUNCTION: Grant access to all groups at once
-- ============================================================
CREATE OR REPLACE FUNCTION grant_note_to_all_groups(
  p_note_id BIGINT,
  p_exclude_groups TEXT[] DEFAULT ARRAY[]::TEXT[]
)
RETURNS void
LANGUAGE plpgsql
AS $$
DECLARE
  v_group TEXT;
BEGIN
  FOREACH v_group IN ARRAY ARRAY['Group A', 'Group B', 'Group C', 'Group D', 'Group E', 'Group F']
  LOOP
    INSERT INTO student_note_permissions (note_id, group_name, is_accessible)
    VALUES (
      p_note_id,
      v_group,
      NOT (v_group = ANY(p_exclude_groups))
    )
    ON CONFLICT (note_id, group_name) 
    DO UPDATE SET is_accessible = NOT (v_group = ANY(p_exclude_groups));
  END LOOP;
END;
$$;

-- ============================================================
-- EXAMPLE USAGE:
-- ============================================================
-- Grant a note to all groups:
-- SELECT grant_note_to_all_groups(
--   (SELECT id FROM student_notes WHERE title = 'Medical Terminology - Complete Notes')
-- );

-- Grant a note to all groups EXCEPT Group C:
-- SELECT grant_note_to_all_groups(
--   (SELECT id FROM student_notes WHERE title = 'Pharmacology - Complete Notes'),
--   ARRAY['Group C']
-- );

-- ============================================================
-- BULK GRANT: Give all existing notes to all groups
-- ============================================================
-- Run this after setting up the system to grant all current notes to all groups:
-- 
-- DO $$
-- DECLARE
--   v_note RECORD;
-- BEGIN
--   FOR v_note IN SELECT id FROM student_notes WHERE deleted = false
--   LOOP
--     PERFORM grant_note_to_all_groups(v_note.id);
--   END LOOP;
-- END $$;
