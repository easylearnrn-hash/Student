-- ========================================================
-- GET ALL PAYMENT TABLE SCHEMAS
-- ========================================================

-- 1. PAYMENTS table schema
SELECT 
    'PAYMENTS TABLE' as table_name,
    column_name,
    data_type,
    character_maximum_length,
    is_nullable
FROM information_schema.columns
WHERE table_name = 'payments'
ORDER BY ordinal_position;

-- 2. PAYMENT_RECORDS table schema
SELECT 
    'PAYMENT_RECORDS TABLE' as table_name,
    column_name,
    data_type,
    character_maximum_length,
    is_nullable
FROM information_schema.columns
WHERE table_name = 'payment_records'
ORDER BY ordinal_position;

-- 3. CREDIT_PAYMENTS table schema
SELECT 
    'CREDIT_PAYMENTS TABLE' as table_name,
    column_name,
    data_type,
    character_maximum_length,
    is_nullable
FROM information_schema.columns
WHERE table_name = 'credit_payments'
ORDER BY ordinal_position;

-- 4. MANUAL_PAYMENT_MOVES table schema
SELECT 
    'MANUAL_PAYMENT_MOVES TABLE' as table_name,
    column_name,
    data_type,
    character_maximum_length,
    is_nullable
FROM information_schema.columns
WHERE table_name = 'manual_payment_moves'
ORDER BY ordinal_position;

-- 5. Sample from PAYMENTS
SELECT 'PAYMENTS SAMPLE' as info;
SELECT * FROM payments LIMIT 2;

-- 6. Sample from PAYMENT_RECORDS
SELECT 'PAYMENT_RECORDS SAMPLE' as info;
SELECT * FROM payment_records LIMIT 2;

-- 7. Sample from CREDIT_PAYMENTS
SELECT 'CREDIT_PAYMENTS SAMPLE' as info;
SELECT * FROM credit_payments LIMIT 2;
