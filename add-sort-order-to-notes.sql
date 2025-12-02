-- Add sort_order column to note_folders (for folder reordering)
ALTER TABLE note_folders
ADD COLUMN IF NOT EXISTS sort_order INTEGER DEFAULT 0;

-- Update existing folders with sequential sort order
WITH ranked_folders AS (
  SELECT id, ROW_NUMBER() OVER (ORDER BY created_at) - 1 AS new_order
  FROM note_folders
)
UPDATE note_folders
SET sort_order = ranked_folders.new_order
FROM ranked_folders
WHERE note_folders.id = ranked_folders.id;

-- Add sort_order column to note_assignments (for note reordering within folders)
ALTER TABLE note_assignments
ADD COLUMN IF NOT EXISTS sort_order INTEGER DEFAULT 0;

-- Update existing assignments with sequential sort order per folder
WITH ranked_assignments AS (
  SELECT 
    na.id, 
    ROW_NUMBER() OVER (
      PARTITION BY nt.folder_id, na.group_id 
      ORDER BY na.assigned_at
    ) - 1 AS new_order
  FROM note_assignments na
  JOIN note_templates nt ON na.template_id = nt.id
  WHERE na.deleted_at IS NULL
)
UPDATE note_assignments
SET sort_order = ranked_assignments.new_order
FROM ranked_assignments
WHERE note_assignments.id = ranked_assignments.id;

-- Create index for better query performance
CREATE INDEX IF NOT EXISTS idx_note_folders_sort_order ON note_folders(sort_order);
CREATE INDEX IF NOT EXISTS idx_note_assignments_sort_order ON note_assignments(sort_order);
