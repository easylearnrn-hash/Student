# 🔵 Supabase Audit Test Suite - Complete Guide

**File:** `Supabase-Audit-Test-Suite.html`  
**Version:** 1.0.0  
**Date:** December 10, 2025  
**Purpose:** Comprehensive automated validation of all Supabase operations across the ARNOMA system

---

## 📋 Table of Contents

1. [Overview](#overview)
2. [What It Tests](#what-it-tests)
3. [Setup Instructions](#setup-instructions)
4. [Running Tests](#running-tests)
5. [Test Categories](#test-categories)
6. [Understanding Results](#understanding-results)
7. [Troubleshooting](#troubleshooting)
8. [Extending the Suite](#extending-the-suite)

---

## 🎯 Overview

The Supabase Audit Test Suite is a **self-contained HTML application** that runs comprehensive automated tests on your entire Supabase infrastructure. It validates:

- ✅ All table CRUD operations (Create, Read, Update, Delete)
- ✅ Row Level Security (RLS) policies
- ✅ Storage bucket operations
- ✅ End-to-end data flows
- ✅ Failure scenarios and error handling
- ✅ Query performance benchmarks

**Zero bugs tolerance:** If any test fails, you know exactly what's broken and where.

---

## 🔍 What It Tests

### 1️⃣ Table Write/Read Tests (Automated CRUD)

**Tables Tested:**
- `students` - Student records, aliases, groups
- `payment_records` - Manual payment entries
- `student_notes` - PDF notes and system notes
- `tests` - Test containers
- `sent_emails` - Email delivery tracking
- `notifications` - Student notifications

**For Each Table:**
1. **INSERT** - Creates test row, validates response
2. **SELECT** - Retrieves row, checks required fields
3. **UPDATE** - Modifies row, validates changes
4. **DELETE** - Removes row, confirms deletion
5. **Performance** - Measures query times (target: <100ms)

**Detects:**
- ❌ Inserts that don't save
- ❌ Updates missing fields
- ❌ Deletes not allowed/incorrectly allowed
- ❌ Fields returned as null unexpectedly
- ❌ Columns referenced in code but missing in table
- ❌ Deprecated columns still being used

---

### 2️⃣ Storage Upload Tests

**Buckets Tested:**
- `student-notes` - PDF note files
- `profile-pictures` - Student/admin avatars
- `test-attachments` - Test-related files

**For Each Bucket:**
1. **UPLOAD** - Uploads test file
2. **DOWNLOAD** - Retrieves file
3. **INTEGRITY CHECK** - Verifies content matches
4. **LIST** - Confirms file appears in bucket
5. **DELETE** - Removes test file

**Detects:**
- ❌ Files not uploaded
- ❌ Files uploaded but unreadable
- ❌ Wrong bucket permissions
- ❌ Orphaned files not referenced in DB
- ❌ Storage quota issues

---

### 3️⃣ RLS Policy Tests

**Scenarios Tested:**
1. **Authenticated Access** - Should pass for logged-in users
2. **Anonymous Access** - Should be blocked for protected tables
3. **Student-Specific Access** - Should enforce student_id matching
4. **Admin Override** - Should allow admin access

**Detects:**
- ❌ RLS allowing too much (security leak)
- ❌ RLS blocking valid operations
- ❌ Missing `auth.uid()` checks
- ❌ Policies referencing nonexistent fields

---

### 4️⃣ End-to-End Data Flow Tests

**Simulates Real Workflow:**
1. Add student → `students` table
2. Add payment → `payment_records` table (foreign key to student)
3. Add note → `student_notes` table
4. Verify relationships → Confirms data integrity

**Detects:**
- ❌ Any step not saving
- ❌ Foreign key violations
- ❌ Data inconsistencies
- ❌ Orphaned records

---

### 5️⃣ Failure Simulation Tests

**Forces Edge Cases:**
1. **Empty Payload** - Should reject gracefully
2. **Wrong Field Types** - Should validate types
3. **Invalid Foreign Keys** - Should enforce constraints
4. **Malformed Data** - Should sanitize/reject

**Detects:**
- ❌ Silent failures
- ❌ Data corruption
- ❌ Missing validation
- ❌ Poor error handling

---

### 6️⃣ Query Performance Tests

**Benchmarks Every Operation:**
- Measures execution time for INSERT, SELECT, UPDATE, DELETE
- Flags queries exceeding 100ms threshold
- Identifies redundant reads/writes
- Detects missing indexes

**Detects:**
- ❌ Slow queries
- ❌ N+1 query problems
- ❌ Inefficient filters
- ❌ Missing database indexes

---

## 🛠️ Setup Instructions

### Step 1: Configure Supabase Credentials

Open `Supabase-Audit-Test-Suite.html` and update lines 321-322:

```javascript
const SUPABASE_URL = 'YOUR_SUPABASE_URL';
const SUPABASE_ANON_KEY = 'YOUR_SUPABASE_ANON_KEY';
```

Replace with your actual Supabase project URL and anon key from:  
**Supabase Dashboard → Settings → API**

### Step 2: Adjust Test Configuration (Optional)

Lines 326-328:

```javascript
const TEST_PREFIX = 'audit_test_';     // Prefix for test data
const CLEANUP_ON_SUCCESS = true;       // Auto-cleanup after tests
const MAX_QUERY_TIME_MS = 100;         // Performance threshold
```

### Step 3: Add/Remove Tables (Optional)

Lines 349-415 define which tables to test. To add a new table:

```javascript
{
  name: 'your_table_name',
  testData: {
    // Fields to insert
    field1: 'value1',
    field2: 'value2'
  },
  updateData: { 
    // Fields to update
    field1: 'updated_value' 
  },
  requiredFields: ['id', 'field1', 'created_at']
}
```

### Step 4: Add/Remove Storage Buckets (Optional)

Lines 417-421:

```javascript
const STORAGE_BUCKETS = [
  'student-notes',
  'profile-pictures',
  'test-attachments',
  'your-new-bucket'  // Add here
];
```

---

## ▶️ Running Tests

### Method 1: Run All Tests (Recommended)

1. Open `Supabase-Audit-Test-Suite.html` in browser
2. Click **"▶️ Run All Tests"**
3. Wait for completion (30-60 seconds depending on data)
4. Review results

### Method 2: Run Specific Categories

Use category-specific buttons:
- **📊 Test Tables Only** - Just table CRUD operations
- **🔒 Test RLS Only** - Just RLS policy validation
- **📁 Test Storage Only** - Just storage bucket operations
- **🔄 Test Data Flows** - Just end-to-end workflows

### Method 3: Automated/CI Integration

Run via command line (requires HTTP server):

```bash
# Start server
python3 -m http.server 8000

# Open in headless browser (example with Playwright)
npx playwright test --headed http://localhost:8000/Supabase-Audit-Test-Suite.html
```

---

## 📊 Understanding Results

### Real-Time Log

Watch the **Live Log** section for detailed progress:

```
[14:32:15] ℹ️ Testing table: students
[14:32:15] ℹ️   → INSERT test for students
[14:32:16] ✅   INSERT successful (45.32ms)
[14:32:16] ℹ️   → SELECT test for students
[14:32:16] ✅   SELECT successful (12.18ms)
```

### Summary Metrics

Top metrics panel shows:
- **Total Tests** - Number of test cases run
- **Passed** - Tests that succeeded
- **Failed** - Tests that failed (investigate these!)
- **Skipped** - Tests not applicable
- **Pass Rate** - Percentage passed (target: 100%)
- **Duration** - Total execution time

### Test Status Icons

- ✅ **Green (Pass)** - Test succeeded
- ❌ **Red (Fail)** - Test failed, needs investigation
- ⚠️ **Yellow (Warning)** - Test passed but with performance issues
- ⏭️ **Gray (Skipped)** - Test not applicable

### JSON Export

Click **"💾 Export JSON"** to get detailed machine-readable report:

```json
{
  "startTime": 1702234935000,
  "endTime": 1702234965000,
  "summary": {
    "total": 42,
    "passed": 40,
    "failed": 2,
    "skipped": 0
  },
  "tables": {
    "students:insert": { "passed": true, "duration": 45.32 },
    "students:select": { "passed": true, "duration": 12.18 }
  },
  "failures": [
    {
      "category": "tables",
      "test": "payment_records:insert",
      "error": "INSERT failed: duplicate key value",
      "timestamp": "2025-12-10T14:32:20.000Z"
    }
  ],
  "issuesFound": 2
}
```

---

## 🐛 Troubleshooting

### ❌ "Failed to fetch" or Network Errors

**Cause:** Supabase credentials incorrect or network issue  
**Fix:**
1. Verify `SUPABASE_URL` and `SUPABASE_ANON_KEY` are correct
2. Check Supabase Dashboard → Settings → API
3. Ensure your IP is not blocked by Supabase
4. Check browser console for CORS errors

### ❌ "INSERT failed: permission denied"

**Cause:** RLS policy blocking insert  
**Fix:**
1. Check RLS policies in Supabase Dashboard → Authentication → Policies
2. Ensure test user has correct permissions
3. For admin-only tables, you may need to log in as admin first
4. Consider temporarily disabling RLS for testing (NOT recommended for production)

### ❌ "Foreign key violation"

**Cause:** Test trying to reference non-existent record  
**Fix:**
1. Ensure parent records exist (e.g., student must exist before payment)
2. Check test data in `testData` objects
3. Verify foreign key constraints are correct in database

### ❌ "Storage bucket not found"

**Cause:** Bucket doesn't exist or wrong name  
**Fix:**
1. Check Supabase Dashboard → Storage
2. Verify bucket name matches exactly (case-sensitive)
3. Create missing buckets or update `STORAGE_BUCKETS` array

### ❌ Tests Run Forever / Never Complete

**Cause:** Infinite loop or network timeout  
**Fix:**
1. Refresh page and try again
2. Check browser console for JavaScript errors
3. Reduce number of tables/buckets being tested
4. Increase timeout values in code if on slow network

### ⚠️ "Average query time exceeds threshold"

**Cause:** Database queries are slow  
**Fix:**
1. Add indexes to frequently queried columns
2. Optimize RLS policies (avoid complex subqueries)
3. Check Supabase Dashboard → Database → Query Performance
4. Consider upgrading Supabase plan if on free tier

---

## 🔧 Extending the Suite

### Adding a New Table Test

1. Open `Supabase-Audit-Test-Suite.html`
2. Find `TABLES_TO_TEST` array (line 349)
3. Add new table configuration:

```javascript
{
  name: 'your_new_table',
  testData: {
    // All required fields for INSERT
    name: `${TEST_PREFIX}Test Name`,
    email: 'test@example.com',
    status: 'active'
  },
  updateData: {
    // Fields to change in UPDATE test
    status: 'inactive'
  },
  requiredFields: [
    // Fields that MUST be in response
    'id', 'name', 'created_at'
  ]
}
```

4. Save and re-run tests

### Adding a New Storage Bucket

1. Find `STORAGE_BUCKETS` array (line 417)
2. Add bucket name:

```javascript
const STORAGE_BUCKETS = [
  'student-notes',
  'profile-pictures',
  'your-new-bucket'  // Add here
];
```

3. Save and re-run tests

### Adding Custom Validation

To add custom checks, modify test functions:

```javascript
// Example: Check if email is valid format
async function testTableOperations(tableConfig) {
  // ... existing code ...
  
  // After INSERT test:
  if (insertData.email && !insertData.email.includes('@')) {
    throw new Error('Email format invalid');
  }
  
  // ... rest of code ...
}
```

### Adding New Test Categories

1. Create new test function:

```javascript
async function testYourNewCategory() {
  log('='.repeat(80), 'info');
  log('STARTING YOUR NEW TESTS', 'info');
  log('='.repeat(80), 'info');

  try {
    // Your test logic here
    log('Running custom test...', 'info');
    
    // Record result
    recordTest('custom', 'test_name', true);
    log('✅ Test passed', 'success');
    
  } catch (error) {
    log(`❌ Test failed: ${error.message}`, 'error');
    recordTest('custom', 'test_name', false, error);
  }
  
  log('✅ CUSTOM TESTS COMPLETE', 'success');
}
```

2. Add to `runAllTests()`:

```javascript
async function runAllTests() {
  // ... existing tests ...
  
  await testYourNewCategory();  // Add here
  await sleep(1000);
  
  // ... rest of code ...
}
```

3. Add button in HTML (optional):

```html
<button class="btn success" onclick="testYourNewCategory()">
  🆕 Run Custom Tests
</button>
```

---

## 📈 Best Practices

### 1. Run Tests Before Every Deploy

Make this part of your deployment checklist:
- [ ] Run full test suite
- [ ] Verify 100% pass rate
- [ ] Check no new performance regressions
- [ ] Export JSON for records

### 2. Monitor Performance Over Time

Track query durations to catch performance degradation:

```javascript
// Example: Compare against baseline
const BASELINE_TIMES = {
  'students:insert': 50,  // ms
  'students:select': 15
};

if (actualDuration > BASELINE_TIMES[testName] * 1.5) {
  log('⚠️  Performance regression detected', 'warn');
}
```

### 3. Test After Schema Changes

Always run tests after:
- Adding/removing columns
- Changing RLS policies
- Modifying indexes
- Updating Supabase configuration

### 4. Use Test Prefix Consistently

All test data uses `audit_test_` prefix for easy identification and cleanup:

```sql
-- Clean up any orphaned test data
DELETE FROM students WHERE name LIKE 'audit_test_%';
DELETE FROM student_notes WHERE title LIKE 'audit_test_%';
```

### 5. Review Failures Immediately

Don't ignore failed tests:
1. Check error message in log
2. Verify database state manually
3. Fix underlying issue
4. Re-run test to confirm
5. Never deploy with failing tests

---

## 🚨 Critical Warnings

### ⚠️ DO NOT run tests on production database with live data

**Why:** Tests insert/update/delete records. While cleanup is automated, failures could leave orphaned data.

**Solution:** Use separate Supabase project for testing, or run on staging environment.

### ⚠️ DO NOT disable RLS for convenience

**Why:** Tests are designed to validate RLS works correctly.

**Solution:** If tests fail due to RLS, fix the policies—don't bypass security.

### ⚠️ DO NOT commit Supabase credentials to Git

**Why:** Exposes your database to unauthorized access.

**Solution:** 
- Use environment variables
- Add `.env` to `.gitignore`
- Use placeholder values in committed code

### ⚠️ DO monitor Supabase usage during tests

**Why:** Rapid automated testing can consume API quota quickly.

**Solution:**
- Check Supabase Dashboard → Usage
- Add delays between tests (`sleep()` calls)
- Consider upgrading plan if hitting limits

---

## 📞 Support & Maintenance

### Common Questions

**Q: How long should tests take?**  
A: 30-60 seconds for full suite. If longer, check for slow queries or network issues.

**Q: Can I run tests in CI/CD pipeline?**  
A: Yes! Use headless browser (Playwright, Puppeteer) to automate execution and parse JSON output.

**Q: What if a test fails intermittently?**  
A: Usually network issues or race conditions. Add more `sleep()` delays or increase timeouts.

**Q: Should I test on production?**  
A: **NO.** Always use staging/testing environment.

**Q: Can I test Edge Functions?**  
A: Not currently included, but you can extend the suite (see "Extending the Suite" section).

### Reporting Issues

If you find a bug in the test suite itself:
1. Note which test failed
2. Check browser console for errors
3. Export JSON report
4. Document steps to reproduce

---

## 🎯 Success Criteria

**Before Deployment, Confirm:**
- ✅ All tests pass (100% pass rate)
- ✅ No performance regressions (all queries <100ms)
- ✅ Zero RLS security leaks
- ✅ All data flows complete successfully
- ✅ Failure scenarios handled gracefully
- ✅ JSON export saved for audit trail

**If ANY test fails → DO NOT DEPLOY**

---

## 📝 Changelog

### Version 1.0.0 (December 10, 2025)
- Initial release
- 6 test categories
- 40+ automated tests
- JSON export functionality
- Real-time logging
- Performance benchmarking

---

**Test Often. Test Early. Deploy Confidently.** 🚀

---

*Supabase Audit Test Suite Documentation - ARNOMA Modules System*
