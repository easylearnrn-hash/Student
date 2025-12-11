# 🔵 Supabase Audit Test Suite - Quick Start

## ⚡ 60-Second Setup

### 1. Configure Supabase
Open `Supabase-Audit-Test-Suite.html`, find lines 321-322:

```javascript
const SUPABASE_URL = 'YOUR_SUPABASE_URL';
const SUPABASE_ANON_KEY = 'YOUR_SUPABASE_ANON_KEY';
```

Replace with your credentials from **Supabase Dashboard → Settings → API**

### 2. Open in Browser
```bash
# Option A: Direct file
open Supabase-Audit-Test-Suite.html

# Option B: HTTP server (recommended)
python3 -m http.server 8000
# Then open: http://localhost:8000/Supabase-Audit-Test-Suite.html
```

### 3. Run Tests
Click **"▶️ Run All Tests"** button

### 4. Review Results
- Watch live log for progress
- Check summary metrics at bottom
- Export JSON for detailed report

---

## 🎯 What Gets Tested

| Category | Tests | What It Validates |
|----------|-------|-------------------|
| **📊 Tables** | 24+ | INSERT, SELECT, UPDATE, DELETE for all tables |
| **📁 Storage** | 12+ | Upload, download, list, delete for all buckets |
| **🔒 RLS** | 6+ | Security policies, auth checks, access control |
| **🔄 Flows** | 4+ | End-to-end workflows (add student → payment → note) |
| **⚠️ Failures** | 6+ | Error handling, validation, edge cases |
| **⚡ Performance** | Auto | Query timing (flags anything >100ms) |

**Total: 50+ automated tests**

---

## 📊 Understanding Results

### ✅ All Green (100% Pass)
**Status:** Ready to deploy  
**Action:** Export JSON for audit trail, proceed with confidence

### ⚠️ Some Yellow (Performance Warnings)
**Status:** Functional but slow  
**Action:** Check query times, add indexes, optimize RLS policies

### ❌ Any Red (Test Failures)
**Status:** DO NOT DEPLOY  
**Action:** Review error messages, fix issues, re-run tests

---

## 🚨 Common First-Time Issues

### "Failed to fetch" Error
**Fix:** Wrong Supabase credentials. Double-check URL and anon key.

### "INSERT failed: permission denied"
**Fix:** RLS policy blocking insert. Log in as admin or adjust policies.

### "Storage bucket not found"
**Fix:** Bucket doesn't exist. Create it in Supabase Dashboard → Storage.

### Tests hang forever
**Fix:** Network timeout. Refresh page, check browser console for errors.

---

## 🔧 Customization

### Add More Tables to Test
Find `TABLES_TO_TEST` array (line 349), add:

```javascript
{
  name: 'your_table',
  testData: { /* insert data */ },
  updateData: { /* update data */ },
  requiredFields: ['id', 'created_at']
}
```

### Add More Storage Buckets
Find `STORAGE_BUCKETS` array (line 417), add:

```javascript
const STORAGE_BUCKETS = [
  'student-notes',
  'your-bucket'  // Add here
];
```

### Adjust Performance Threshold
Find `MAX_QUERY_TIME_MS` (line 328):

```javascript
const MAX_QUERY_TIME_MS = 100;  // Change to 200 for slower networks
```

---

## 📥 Export Results

Click **"💾 Export JSON"** to download complete report:

```json
{
  "summary": {
    "total": 52,
    "passed": 50,
    "failed": 2
  },
  "failures": [
    {
      "category": "tables",
      "test": "payments:insert",
      "error": "permission denied"
    }
  ]
}
```

Use this for:
- CI/CD validation
- Audit trails
- Performance tracking over time
- Debugging failed deployments

---

## 🎓 Next Steps

1. **Read Full Guide:** `SUPABASE-AUDIT-TEST-SUITE-GUIDE.md` (comprehensive documentation)
2. **Extend Tests:** Add your custom tables, buckets, and validation logic
3. **Automate:** Integrate into CI/CD pipeline (see guide for headless browser setup)
4. **Schedule:** Run weekly to catch regressions early

---

## ⚠️ Important Warnings

- **DO NOT** run on production database with live users
- **DO NOT** disable RLS policies to make tests pass
- **DO NOT** commit Supabase credentials to Git
- **DO NOT** deploy if ANY test fails

---

## 📞 Need Help?

Check the comprehensive guide for:
- Detailed test explanations
- Troubleshooting steps
- Advanced configuration
- Extension examples

**File:** `SUPABASE-AUDIT-TEST-SUITE-GUIDE.md`

---

**Ready to test?** Open `Supabase-Audit-Test-Suite.html` and click "Run All Tests"! 🚀
