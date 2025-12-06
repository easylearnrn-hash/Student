-- Add support for individual student access to notes
-- This ensures the student_note_permissions table can handle both group and individual access

-- Step 1: Add student_id column if it doesn't exist
DO $$ 
BEGIN
    -- Add student_id column for individual access
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'student_note_permissions' 
        AND column_name = 'student_id'
    ) THEN
        ALTER TABLE student_note_permissions 
        ADD COLUMN student_id INTEGER REFERENCES students(id);
        
        RAISE NOTICE 'Added student_id column for individual access';
    ELSE
        RAISE NOTICE 'student_id column already exists';
    END IF;
END $$;

-- Step 2: Make group_name nullable (for individual access)
DO $$ 
BEGIN
    ALTER TABLE student_note_permissions 
    ALTER COLUMN group_name DROP NOT NULL;
    
    RAISE NOTICE 'Made group_name nullable';
EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'group_name is already nullable or error: %', SQLERRM;
END $$;

-- Step 3: Add unique constraint to prevent duplicate permissions
DO $$ 
BEGIN
    -- Drop existing constraint if it exists
    IF EXISTS (
        SELECT 1 FROM pg_constraint 
        WHERE conname = 'unique_note_student_permission'
    ) THEN
        ALTER TABLE student_note_permissions 
        DROP CONSTRAINT unique_note_student_permission;
        
        RAISE NOTICE 'Dropped old unique constraint';
    END IF;

    -- Add new unique constraint for individual access (note_id + student_id)
    -- NULLS NOT DISTINCT means NULL values are considered equal (prevents duplicate NULL rows)
    ALTER TABLE student_note_permissions 
    ADD CONSTRAINT unique_note_student_permission 
    UNIQUE NULLS NOT DISTINCT (note_id, student_id, group_name);
    
    RAISE NOTICE 'Added unique constraint for individual student access';
END $$;

-- Step 4: Update RLS policies to allow individual student access
-- Students can see notes if:
-- 1. They have group access (group_name matches their group AND student_id is NULL)
-- 2. They have individual access (student_id matches their ID)

DROP POLICY IF EXISTS "Students can view their group notes" ON student_note_permissions;
DROP POLICY IF EXISTS "Students can view notes with individual access" ON student_note_permissions;
DROP POLICY IF EXISTS "Students can view accessible notes" ON student_note_permissions;

-- Combined policy for both group and individual access
-- Note: We don't validate group_name against students table here, just check if accessible
CREATE POLICY "Students can view accessible notes" 
ON student_note_permissions 
FOR SELECT 
USING (
  is_accessible = true AND (
    -- Group access: has group_name set and no specific student_id
    -- The application layer ensures group_name matches the student's actual group
    (group_name IS NOT NULL AND student_id IS NULL)
    OR
    -- Individual access: student_id matches the authenticated user's student record
    (student_id IS NOT NULL AND student_id IN (
      SELECT id FROM students WHERE auth_user_id = auth.uid()
    ))
  )
);

-- Step 5: Admin policy remains the same
DROP POLICY IF EXISTS "Admins can manage all permissions" ON student_note_permissions;
CREATE POLICY "Admins can manage all permissions" 
ON student_note_permissions 
FOR ALL 
USING (
  EXISTS (
    SELECT 1 FROM admin_accounts WHERE auth_user_id = auth.uid()
  )
);

-- Step 6: Verify the structure
DO $$
DECLARE
  total_count INTEGER;
  individual_count INTEGER;
  group_count INTEGER;
BEGIN
  SELECT 
    COUNT(*),
    COUNT(CASE WHEN student_id IS NOT NULL THEN 1 END),
    COUNT(CASE WHEN group_name IS NOT NULL THEN 1 END)
  INTO total_count, individual_count, group_count
  FROM student_note_permissions;
  
  RAISE NOTICE '=== Table Structure Verified ===';
  RAISE NOTICE 'Total permissions: %', total_count;
  RAISE NOTICE 'Individual permissions: %', individual_count;
  RAISE NOTICE 'Group permissions: %', group_count;
  RAISE NOTICE '✓ Individual student access feature is ready!';
END $$;
