-- =====================================================
-- Cleanup: Reset all ongoing systems to start fresh
-- =====================================================
-- This will unset is_current for ALL note_folders,
-- allowing you to set new ongoing systems per group
-- with the updated per-group logic.
-- =====================================================

-- Unset ALL ongoing systems (reset to clean state)
UPDATE public.note_folders
SET is_current = false
WHERE is_current = true;

-- Verify the cleanup
SELECT 
  folder_name,
  group_letter,
  is_current
FROM public.note_folders
WHERE deleted_at IS NULL
ORDER BY group_letter, folder_name;

-- =====================================================
-- After running this, go to Group-Notes.html and
-- set the ongoing system for each group again.
-- Now it will work correctly per-group!
-- =====================================================
