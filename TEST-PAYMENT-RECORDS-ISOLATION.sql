-- ============================================================================
-- 🚨 CRITICAL TEST: Verify payment_records isolation between students
-- ============================================================================

-- =============================================================================
-- TEST 1: Check RLS is ENABLED on payment_records
-- =============================================================================
SELECT 
  tablename,
  CASE 
    WHEN rowsecurity THEN '✅ RLS ENABLED' 
    ELSE '❌ CRITICAL: RLS DISABLED!' 
  END as "RLS Status"
FROM pg_tables 
WHERE tablename = 'payment_records';

-- Expected: ✅ RLS ENABLED

-- =============================================================================
-- TEST 2: List ALL policies on payment_records table
-- =============================================================================
SELECT 
  policyname,
  cmd as "Operation",
  roles as "Who Can Access",
  qual::text as "Access Condition"
FROM pg_policies 
WHERE tablename = 'payment_records'
ORDER BY cmd;

-- Expected: Should see 4 policies (SELECT, INSERT, UPDATE, DELETE)
-- SELECT should require: is_arnoma_admin() OR student_id matches auth.uid()

-- =============================================================================
-- TEST 3: Show sample payment_records with student info
-- =============================================================================
SELECT 
  pr.id as "Payment Record ID",
  pr.student_id,
  s.name as "Student Name",
  s.auth_user_id as "Student Auth UID",
  pr.amount,
  pr.date,
  pr.status,
  CASE 
    WHEN s.auth_user_id IS NULL THEN '⚠️ Student has no auth account'
    ELSE '✅ Student has auth account'
  END as "Auth Status"
FROM payment_records pr
LEFT JOIN students s ON s.id = pr.student_id
ORDER BY pr.id
LIMIT 10;

-- =============================================================================
-- TEST 4: Group payment_records by student - show counts
-- =============================================================================
SELECT 
  s.id as "Student ID",
  s.name as "Student Name",
  s.auth_user_id as "Auth UID",
  COUNT(pr.id) as "Payment Record Count",
  array_agg(pr.id ORDER BY pr.id) as "Payment Record IDs"
FROM students s
LEFT JOIN payment_records pr ON pr.student_id = s.id
WHERE s.auth_user_id IS NOT NULL
  AND s.show_in_grid = true
GROUP BY s.id, s.name, s.auth_user_id
HAVING COUNT(pr.id) > 0
ORDER BY s.id
LIMIT 10;

-- Expected: Each student should have their OWN payment records, no sharing

-- =============================================================================
-- TEST 5: CRITICAL - Check for payment_records with SAME ID across students
-- =============================================================================
SELECT 
  pr.id as "Payment Record ID",
  COUNT(DISTINCT s.id) as "Number of Students with This Record",
  string_agg(DISTINCT s.name, ', ') as "Student Names",
  CASE 
    WHEN COUNT(DISTINCT s.id) > 1 THEN '❌ CRITICAL BREACH - Multiple students share this record!'
    ELSE '✅ Only one student'
  END as "Isolation Check"
FROM payment_records pr
JOIN students s ON s.id = pr.student_id
GROUP BY pr.id
HAVING COUNT(DISTINCT s.id) > 1;

-- Expected: ZERO ROWS (no payment records shared between students)

-- =============================================================================
-- TEST 6: Simulate what Student A can see vs Student B
-- =============================================================================
WITH student_a AS (
  SELECT s.id, s.name, s.auth_user_id
  FROM students s
  WHERE s.auth_user_id IS NOT NULL
    AND s.show_in_grid = true
  LIMIT 1
),
student_b AS (
  SELECT s.id, s.name, s.auth_user_id
  FROM students s
  WHERE s.auth_user_id IS NOT NULL
    AND s.show_in_grid = true
    AND s.id != (SELECT id FROM student_a)
  LIMIT 1
)
SELECT 
  'Student A' as "Student",
  (SELECT name FROM student_a) as "Name",
  (SELECT COUNT(*) FROM payment_records WHERE student_id = (SELECT id FROM student_a)) as "Records They See"
UNION ALL
SELECT 
  'Student B',
  (SELECT name FROM student_b),
  (SELECT COUNT(*) FROM payment_records WHERE student_id = (SELECT id FROM student_b));

-- Expected: Each student sees different counts (their own data only)

-- =============================================================================
-- TEST 7: Check if any payment_record belongs to multiple students
-- =============================================================================
SELECT 
  pr.id,
  pr.student_id,
  s.name,
  pr.amount,
  pr.date
FROM payment_records pr
JOIN students s ON s.id = pr.student_id
WHERE pr.student_id IN (
  SELECT student_id 
  FROM payment_records 
  GROUP BY student_id 
  HAVING COUNT(*) > 0
)
ORDER BY pr.student_id, pr.id
LIMIT 20;

-- Review: Each payment_record should have exactly ONE student_id

-- =============================================================================
-- TEST 8: Verify the SELECT policy logic is correct
-- =============================================================================
SELECT 
  policyname,
  CASE 
    WHEN qual::text LIKE '%is_arnoma_admin()%' 
         AND qual::text LIKE '%student_id%' 
         AND qual::text LIKE '%auth.uid()%'
    THEN '✅ SECURE - Requires admin OR student_id match'
    ELSE '❌ INSECURE - Policy may allow unauthorized access!'
  END as "Policy Security",
  qual::text as "Full Policy Logic"
FROM pg_policies 
WHERE tablename = 'payment_records'
  AND cmd = 'SELECT';

-- Expected: ✅ SECURE

-- =============================================================================
-- TEST 9: Simulate what anonymous (unauthenticated) users can see
-- =============================================================================
SELECT 
  policyname,
  roles,
  CASE 
    WHEN 'anon' = ANY(roles) AND cmd = 'SELECT' THEN '❌ SECURITY BREACH - Anonymous can read!'
    WHEN 'public' = ANY(roles) AND cmd = 'SELECT' THEN '❌ SECURITY BREACH - Public can read!'
    ELSE '✅ No anonymous access'
  END as "Anonymous Access Check"
FROM pg_policies 
WHERE tablename = 'payment_records'
  AND cmd = 'SELECT';

-- Expected: ✅ No anonymous access

-- =============================================================================
-- TEST 10: Final verdict on payment_records security
-- =============================================================================
SELECT 
  CASE 
    WHEN (
      -- RLS is enabled
      (SELECT rowsecurity FROM pg_tables WHERE tablename = 'payment_records') = true
      AND
      -- No anonymous SELECT access
      (SELECT COUNT(*) FROM pg_policies 
       WHERE tablename = 'payment_records' 
       AND cmd = 'SELECT'
       AND ('anon' = ANY(roles) OR 'public' = ANY(roles))) = 0
      AND
      -- SELECT policy requires student_id match OR admin
      (SELECT COUNT(*) FROM pg_policies 
       WHERE tablename = 'payment_records'
       AND cmd = 'SELECT'
       AND qual::text LIKE '%is_arnoma_admin()%'
       AND qual::text LIKE '%student_id%') > 0
      AND
      -- No payment records shared between students
      (SELECT COUNT(*) FROM (
        SELECT pr.id
        FROM payment_records pr
        JOIN students s ON s.id = pr.student_id
        GROUP BY pr.id
        HAVING COUNT(DISTINCT s.id) > 1
      ) AS shared) = 0
    )
    THEN '✅✅✅ PAYMENT_RECORDS ARE SECURE - Students can only see their own!'
    ELSE '❌❌❌ SECURITY ISSUE IN PAYMENT_RECORDS - INVESTIGATE ABOVE TESTS!'
  END as "🔒 PAYMENT_RECORDS SECURITY VERDICT 🔒";

-- =============================================================================
-- MANUAL TESTING INSTRUCTIONS:
-- =============================================================================
-- 
-- To verify with actual student login:
-- 
-- 1. Open Payment-Records.html in browser
-- 2. Log out if logged in as admin
-- 3. Log in as a STUDENT account (get credentials from students table)
-- 4. The page should either:
--    a) Redirect you away (students can't access admin tools), OR
--    b) Show ONLY that student's payment records
-- 
-- 5. Open browser console (F12) and run:
--    SELECT * FROM payment_records;
--    
-- 6. If you see OTHER student names → SECURITY BREACH
-- 7. If you see ONLY the logged-in student's name → SECURE ✅
-- 
-- Expected: Students should NOT be able to access Payment-Records.html at all
-- (it's an admin-only tool)
-- =============================================================================
