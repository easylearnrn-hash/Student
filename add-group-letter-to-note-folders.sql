-- =====================================================
-- Add group_letter column to note_folders table
-- =====================================================
-- This allows each group (A-F) to have its own set of
-- note folders and separate "ongoing" system tracking.
-- =====================================================

-- Add group_letter column (nullable first to avoid breaking existing data)
ALTER TABLE public.note_folders 
ADD COLUMN IF NOT EXISTS group_letter TEXT;

-- Create index for performance
CREATE INDEX IF NOT EXISTS idx_note_folders_group 
  ON public.note_folders(group_letter) 
  WHERE deleted_at IS NULL;

-- Update existing records to have no group (global folders)
-- You can choose to assign them to specific groups or leave them as NULL
-- NULL = global folders, visible to all groups (backward compatibility)

-- Optional: Drop the old UNIQUE constraint on folder_name if it exists
-- and add a new one that includes group_letter
ALTER TABLE public.note_folders 
DROP CONSTRAINT IF EXISTS note_folders_folder_name_key;

-- Drop existing composite constraint if it exists (from previous migration attempt)
ALTER TABLE public.note_folders 
DROP CONSTRAINT IF EXISTS note_folders_folder_name_group_key;

-- Add new composite unique constraint: folder_name must be unique PER group
-- Using DO block to handle constraint creation gracefully
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint 
    WHERE conname = 'note_folders_folder_name_group_key'
  ) THEN
    ALTER TABLE public.note_folders 
    ADD CONSTRAINT note_folders_folder_name_group_key 
    UNIQUE (folder_name, group_letter);
  END IF;
END$$;

-- =====================================================
-- After running this migration:
-- =====================================================
-- 1. Existing folders will have group_letter = NULL (global)
-- 2. New folders created per group will have group_letter set
-- 3. Each group can have its own "Gastrointestinal System", etc.
-- 4. Each group can have its own ongoing system (is_current flag)
-- =====================================================
