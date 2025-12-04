-- ========================================================
-- QUICK UNLINK: alekevin@gmail.com
-- ========================================================
-- This will allow you to delete the user from Supabase Auth UI
-- ========================================================

-- Step 1: Find the auth_user_id
DO $$
DECLARE
  user_uuid UUID;
  student_count INT;
  admin_count INT;
BEGIN
  -- Get the auth user ID
  SELECT id INTO user_uuid
  FROM auth.users
  WHERE email = 'alekevin@gmail.com';

  IF user_uuid IS NULL THEN
    RAISE NOTICE '❌ User not found: alekevin@gmail.com';
    RETURN;
  END IF;

  RAISE NOTICE '✅ Found user: %', user_uuid;

  -- Check students table
  SELECT COUNT(*) INTO student_count
  FROM students
  WHERE auth_user_id = user_uuid;

  -- Check admin_accounts table
  SELECT COUNT(*) INTO admin_count
  FROM admin_accounts
  WHERE auth_user_id = user_uuid;

  RAISE NOTICE '📊 Links found: % students, % admin accounts', student_count, admin_count;

  -- Unlink from students table (keeps student record, removes login)
  IF student_count > 0 THEN
    UPDATE students
    SET auth_user_id = NULL
    WHERE auth_user_id = user_uuid;
    RAISE NOTICE '✅ Unlinked from % student record(s)', student_count;
  END IF;

  -- Remove from admin_accounts table
  IF admin_count > 0 THEN
    DELETE FROM admin_accounts
    WHERE auth_user_id = user_uuid;
    RAISE NOTICE '✅ Removed from % admin account(s)', admin_count;
  END IF;

  RAISE NOTICE '🎉 User unlinked! You can now delete alekevin@gmail.com from Supabase Auth UI';
END $$;

-- Verify it worked
SELECT 
  'students' as table_name,
  COUNT(*) as linked_count
FROM students
WHERE email ILIKE '%alekevin%' OR auth_user_id IN (
  SELECT id FROM auth.users WHERE email = 'alekevin@gmail.com'
)
UNION ALL
SELECT 
  'admin_accounts' as table_name,
  COUNT(*) as linked_count
FROM admin_accounts
WHERE email ILIKE '%alekevin%' OR auth_user_id IN (
  SELECT id FROM auth.users WHERE email = 'alekevin@gmail.com'
);
