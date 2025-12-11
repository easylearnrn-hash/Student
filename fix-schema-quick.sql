-- ============================================================================
-- QUICK SCHEMA FIXES FOR TEST SUITE
-- Run this FIRST, before the RLS policy fixes
-- ============================================================================

-- Fix #1: Make sent_emails.template_name nullable
-- Current: template_name TEXT NOT NULL
-- Needed: template_name TEXT (nullable)
-- Reason: Test suite doesn't provide this value

ALTER TABLE sent_emails 
ALTER COLUMN template_name DROP NOT NULL;

-- Fix #2: Add message column to notifications if missing
-- Test suite expects: { student_id, type, message, is_read }
-- This adds the missing column

DO $$ 
BEGIN
  IF NOT EXISTS (
    SELECT 1 
    FROM information_schema.columns 
    WHERE table_name = 'notifications' 
    AND column_name = 'message'
  ) THEN
    ALTER TABLE notifications ADD COLUMN message TEXT;
    RAISE NOTICE '✅ Added message column to notifications table';
  ELSE
    RAISE NOTICE 'ℹ️  message column already exists';
  END IF;
END $$;

-- ============================================================================
-- VERIFICATION QUERIES
-- ============================================================================

-- Verify sent_emails fix
SELECT 
  column_name, 
  data_type, 
  is_nullable,
  CASE WHEN is_nullable = 'YES' THEN '✅ Nullable' ELSE '❌ NOT NULL' END as status
FROM information_schema.columns 
WHERE table_name = 'sent_emails' 
AND column_name = 'template_name';

-- Verify notifications has message column
SELECT 
  column_name, 
  data_type,
  '✅ Column exists' as status
FROM information_schema.columns 
WHERE table_name = 'notifications' 
AND column_name = 'message';

-- Show all notifications columns
SELECT 
  column_name, 
  data_type,
  is_nullable
FROM information_schema.columns 
WHERE table_name = 'notifications'
ORDER BY ordinal_position;

SELECT '✅ Schema fixes complete! Now run fix-test-suite-schema-issues.sql for RLS policies' as next_step;
