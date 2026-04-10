-- ============================================================================
-- CHECK ADMIN_ACCOUNTS TABLE STRUCTURE
-- ============================================================================
-- First, let's see what columns actually exist

SELECT column_name, data_type 
FROM information_schema.columns 
WHERE table_name = 'admin_accounts' 
ORDER BY ordinal_position;
