# 🔒 FIX RLS ERRORS - Student Portal Absence/Cancellation Data

## 🚨 Errors Found:
```
[Error] Failed to load resource: student_absences (network connection lost)
[Error] CORS error: skipped_classes (access control checks failed)
```

## 🎯 Root Cause:
**Missing RLS policies** for student portal queries. Students couldn't read:
- Their own absences (`student_absences` table)
- Cancelled classes for their group (`skipped_classes` table)

## ✅ Solution Applied:

### 1. Created SQL Fix File: `fix-absence-tables-rls.sql`

**What it does:**
- Drops old/broken policies
- Creates proper student read access via `students` table lookup
- Grants admins full access to both tables
- Includes verification queries

### 2. Updated Error Logging in `student-portal.html`

**Before:**
```javascript
debugDebug('⚠️ Error loading absences:', error); // Silent in production
```

**After:**
```javascript
console.error('⚠️ RLS Error loading absences:', error.message, error);
debugDebug('⚠️ Error loading absences:', error);
```

Now shows RLS errors **in production console** (not just DEBUG_MODE).

---

## 📋 How to Apply Fix:

### Step 1: Open Supabase SQL Editor
1. Go to your Supabase project dashboard
2. Click **SQL Editor** in left sidebar

### Step 2: Run the SQL Fix
1. Open the file: `fix-absence-tables-rls.sql`
2. Copy the entire contents
3. Paste into Supabase SQL Editor
4. Click **Run** ▶️

### Step 3: Verify Policies Applied
Check the output shows:
```sql
-- Should see 4 policies total:
- Students can read their own absences
- Admins can manage all absences
- Students can read their group skipped classes
- Admins can manage all skipped classes
```

### Step 4: Test Student Portal
1. Hard refresh student portal: `Cmd+Shift+R`
2. Check browser console - errors should be **gone**
3. Verify absence counter shows correct number
4. Verify cancelled classes don't show as unpaid

---

## 🔍 What Each Policy Does:

### `student_absences` Table:
```sql
-- Students see ONLY their own absence records
WHERE student_id IN (
  SELECT id FROM students WHERE auth_user_id = auth.uid()
)
```

### `skipped_classes` Table:
```sql
-- Students see cancelled classes for their group
WHERE group_name IN (
  SELECT COALESCE(group_name, "group") 
  FROM students WHERE auth_user_id = auth.uid()
)
```

---

## ⚠️ Important Notes:

1. **Auth Linkage Required**: Student must have `auth_user_id` set in `students` table
   - Already fixed for Aleksandr (ID 72)
   - Other students may need same fix

2. **Group Name Format**: Uses `COALESCE(group_name, "group")` to handle both column names

3. **No Breaking Changes**: These policies only **add** student read access
   - Admin access unchanged (full control)
   - Data integrity preserved

---

## 🧪 Test Queries (Optional):

After applying, test with a student's `auth_user_id`:

```sql
-- Test absences access (replace UUID with real student)
SELECT * FROM student_absences 
WHERE student_id IN (
  SELECT id FROM students 
  WHERE auth_user_id = 'c7b21994-a096-4f16-949b-70548ef6a961'
);

-- Test skipped classes access
SELECT * FROM skipped_classes 
WHERE group_name IN (
  SELECT COALESCE(group_name, "group") 
  FROM students 
  WHERE auth_user_id = 'c7b21994-a096-4f16-949b-70548ef6a961'
);
```

Both should return data (not RLS errors).

---

## 📊 Impact:

**BEFORE:** Student portal couldn't calculate unpaid classes correctly
- Absences showed as unpaid (wrong)
- Cancelled classes showed as unpaid (wrong)
- Absence counter was always 0

**AFTER:** Correct absence/cancellation tracking
- Absences excluded from unpaid calculations ✅
- Cancelled classes excluded from schedule ✅
- Absence counter shows real count ✅

---

Changes committed and pushed to GitHub ✅
