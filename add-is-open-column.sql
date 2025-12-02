-- Add is_open column to existing note_assignments table
ALTER TABLE public.note_assignments 
ADD COLUMN IF NOT EXISTS is_open BOOLEAN DEFAULT false;

-- Set all existing assignments to closed by default
UPDATE public.note_assignments 
SET is_open = false 
WHERE is_open IS NULL;

-- Verify the column was added
SELECT column_name, data_type, column_default 
FROM information_schema.columns 
WHERE table_name = 'note_assignments' 
AND column_name = 'is_open';
