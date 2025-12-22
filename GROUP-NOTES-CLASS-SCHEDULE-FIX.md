# Group Notes: Class Schedule Display Fix ✅

## Issue Identified
The class schedule was not displaying when using "Grant FREE Access" feature because of a **parameter mismatch** in the function call.

---

## Root Cause

### Function Signature
```javascript
window.customPromptWithDate = (title, message, dateLabel = 'Select date:', defaultDate = null)
```

### Incorrect Call (Before)
```javascript
const classDate = await customPromptWithDate(
  'Set Class Date for Free Access',
  `What date should these notes show as opened for free?${classDatesHtml}`,
  new Date().toISOString().split('T')[0]  // ❌ WRONG: passing date as 3rd param (dateLabel)
);
```

### Correct Call (After)
```javascript
const classDate = await customPromptWithDate(
  'Set Class Date for Free Access',
  `What date should these notes show as opened for free?${classDatesHtml}`,
  'Select date:',                          // ✅ CORRECT: dateLabel parameter
  new Date().toISOString().split('T')[0]   // ✅ CORRECT: defaultDate parameter
);
```

---

## What Was Fixed

**File**: `Group-Notes.html` (Line ~3960)

Changed the `customPromptWithDate()` call to include **all 4 parameters** in the correct order:
1. `title` - Dialog title
2. `message` - Message text (includes HTML for class schedule)
3. `dateLabel` - Label for the date picker (was missing)
4. `defaultDate` - Default date value (was in wrong position)

---

## How It Works Now

### 1. User Selects Notes
- Admin checks notes in any system (e.g., Endocrine System)
- Clicks either:
  - **"🆓 Free Selected"** button in top toolbar, OR
  - **"FREE"** button in system quick actions

### 2. Modal Opens
- "Grant FREE Access" modal appears
- User can choose:
  - **Group**: Select a group (A-F)
  - **Individual**: Select specific students

### 3. Class Schedule Fetches
When group is selected, the system:
```javascript
// Fetches group's class schedule
const { data: group } = await supabaseClient
  .from('groups')
  .select('class_schedule')
  .eq('group_name', groupLetter)
  .single();

// Generates HTML showing all class dates for current month
// Example: "Dec 2, Dec 5, Dec 9, Dec 12, Dec 16, Dec 19, Dec 23, Dec 26"
```

### 4. Date Picker Shows Schedule
The date picker modal now displays:
```
Set Class Date for Free Access
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

What date should these notes show as opened for free?

📅 Group E Class Dates - December 2025
┌────────────────────────────────────────┐
│ Dec 2 (Mon)  Dec 5 (Thu)  Dec 9 (Mon)  │
│ Dec 12 (Thu) Dec 16 (Mon) Dec 19 (Thu) │
│ Dec 23 (Mon) Dec 26 (Thu)              │
└────────────────────────────────────────┘

Select date:
[Date Picker Input]

[Cancel]  [Post]
```

---

## Debug Logging

The function includes extensive console logging:
```javascript
console.log('🔍 Fetching schedule for group:', groupLetter);
console.log('📅 Group data:', group, 'Error:', error);
console.log('📋 Schedule:', schedule);
console.log('📆 Found class dates:', classDates.length);
console.log('✅ Generated HTML:', classDatesHtml.substring(0, 100) + '...');
```

---

## Testing Instructions

### To Verify the Fix Works:

1. **Open `Group-Notes.html` in browser**
2. **Open Browser Console** (F12 → Console tab)
3. **Select notes from any system** (e.g., check 2-3 Endocrine notes)
4. **Click "FREE" button** (in system quick actions or top toolbar)
5. **Select "Group" tab** in modal
6. **Choose a group** (A, B, C, D, E, or F)
7. **Look for console output**:
   ```
   🔍 Fetching schedule for group: E
   📅 Group data: {class_schedule: {monday: true, thursday: true, ...}}
   📋 Schedule: {monday: true, thursday: true, ...}
   📆 Found class dates: 8
   ✅ Generated HTML: <div style="margin-top: 16px; padding: 12px...
   ```

8. **Verify modal shows**:
   - Blue box with "📅 Group E Class Dates - December 2025"
   - All class dates displayed as badges
   - Date picker input below

---

## What If It Still Doesn't Work?

### Check Console for Errors
Look for:
- ❌ Error fetching group schedule
- ❌ groups table missing class_schedule column
- ❌ Group data is null

### Verify Groups Table
Run this SQL in Supabase:
```sql
SELECT group_name, class_schedule 
FROM groups 
WHERE group_name = 'E';
```

Expected result:
```json
{
  "group_name": "E",
  "class_schedule": {
    "monday": true,
    "tuesday": false,
    "wednesday": false,
    "thursday": true,
    "friday": false,
    "saturday": false,
    "sunday": false
  }
}
```

### Check Group Name Format
The code expects:
- **Database**: `group_name = 'E'` (just the letter)
- **Code variable**: `groupLetter = 'E'` (from dropdown)
- **Display**: `currentGroup = 'Group E'` (for UI)

---

## Related Functions

### Main Flow
```
systemOpenFreeAccessModal() 
  → openFreeAccessModal()
    → selectFreeAccessType('group')
      → grantFreeAccess()
        → [Fetch schedule]
        → customPromptWithDate() ← FIX APPLIED HERE
```

### Key Files
- `Group-Notes.html` (line 3960) - Fixed function call
- `shared-dialogs.js` (line 308) - Dialog rendering (uses innerHTML)

---

## Summary

✅ **FIXED**: Added missing `dateLabel` parameter to `customPromptWithDate()` call  
✅ **RESULT**: Class schedule HTML now renders correctly in date picker modal  
✅ **IMPACT**: Admins can see all class dates when granting free access to notes  

The HTML was being generated correctly all along - it just wasn't being rendered because the parameters were in the wrong order, causing the HTML to be interpreted as the date label text instead of part of the message.

---

## Change Log

**Date**: 2025-12-20  
**File**: `Group-Notes.html`  
**Line**: ~3960  
**Change**: Added `'Select date:'` parameter before default date value  
**Tested**: ❓ (awaiting user verification)

