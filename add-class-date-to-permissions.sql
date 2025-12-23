-- ============================================================
-- ADD class_date TO PERMISSION TABLES
-- This allows each group to have independent dates for the same note
-- ============================================================

-- Add class_date to note_free_access (for FREE access per group)
ALTER TABLE note_free_access 
ADD COLUMN IF NOT EXISTS class_date DATE;

-- Add index for performance
CREATE INDEX IF NOT EXISTS idx_note_free_access_class_date 
ON note_free_access(class_date);

-- Add class_date to student_note_permissions (for PAID/opened notes per group)
ALTER TABLE student_note_permissions 
ADD COLUMN IF NOT EXISTS class_date DATE;

-- Add index for performance
CREATE INDEX IF NOT EXISTS idx_student_note_permissions_class_date 
ON student_note_permissions(class_date);

-- Add comments
COMMENT ON COLUMN note_free_access.class_date IS 'Date this note was freed for this group/student';
COMMENT ON COLUMN student_note_permissions.class_date IS 'Date this note was opened for this group';
