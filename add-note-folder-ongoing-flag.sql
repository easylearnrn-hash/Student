-- Add ongoing flag to note_folders so admins can highlight the system currently being taught
ALTER TABLE public.note_folders
  ADD COLUMN IF NOT EXISTS is_current BOOLEAN DEFAULT FALSE;

-- Normalize nulls created before the column existed
UPDATE public.note_folders
SET is_current = COALESCE(is_current, FALSE);
