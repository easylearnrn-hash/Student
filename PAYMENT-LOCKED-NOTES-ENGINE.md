# Payment-Locked Notes Engine - Implementation Guide

## 🎯 Overview

The Payment-Locked Notes Engine automatically unlocks group notes for students based on their paid calendar classes. Notes are locked by default and unlock individually per student when their corresponding class date is marked as paid.

---

## 🔧 How It Works

### 1. Class Date Computation

**Function**: `computeClassDatesForMonth(scheduleData, year, month)`

For each student and each month:
- Reads the student's weekly schedule (e.g., Monday + Friday)
- Generates all dates in that month matching their schedule days
- Adds any one-time scheduled classes
- Returns sorted array of class dates in YYYY-MM-DD format

**Example for October 2025**:
```javascript
// Student schedule: Monday + Friday
// Returns:
[
  '2025-10-03', // Friday
  '2025-10-06', // Monday
  '2025-10-10', // Friday
  '2025-10-13', // Monday
  '2025-10-17', // Friday
  '2025-10-20', // Monday
  '2025-10-24', // Friday
  '2025-10-27', // Monday
  '2025-10-31'  // Friday
]
// Total: 9 classes
```

---

### 2. Note-to-Class Mapping

**Function**: `mapNoteToClassDate(notePostedAt, classDates)`

Each note is mapped to a class date based on its `posted_at` timestamp:

**Logic**:
- A note "belongs" to the most recent class date **on or before** its posted date
- If posted before the first class → maps to first class
- If posted after last class → maps to last class

**Example**:
```javascript
// Class dates: Oct 3, 6, 10, 13, 17, 20, 24, 27, 31

// Note posted Oct 3 12:00 PM  → Class date: Oct 3
// Note posted Oct 4 9:00 AM   → Class date: Oct 3
// Note posted Oct 5 11:59 PM  → Class date: Oct 3
// Note posted Oct 6 8:00 AM   → Class date: Oct 6
// Note posted Oct 8 2:00 PM   → Class date: Oct 6
```

---

### 3. Payment Status Check

**Function**: `isClassDatePaid(classDate, paidDatesSet)`

For each class date:
- Queries `payment_records` table for the student
- Filters for `status === 'paid'`
- Builds a Set of paid dates for O(1) lookup

**Example**:
```javascript
// Student's paid dates: Oct 3, Oct 6, Oct 13
paidDatesSet = Set(['2025-10-03', '2025-10-06', '2025-10-13'])

isClassDatePaid('2025-10-03', paidDatesSet) // true  ✅
isClassDatePaid('2025-10-10', paidDatesSet) // false ❌
```

---

### 4. Note Unlock Logic

**Function**: `shouldUnlockNote(note, student, paidDatesSet, scheduleData)`

A note is unlocked if **ANY** of these conditions are true:

1. **No payment required**: `note.requires_payment === false`
2. **Free access granted**: Student has explicit free access to the note
3. **Class date paid**: The note's mapped class date is in `paidDatesSet`

**Flow Chart**:
```
Note requires payment?
│
├─ NO  → UNLOCK ✅
│
└─ YES → Has free access?
          │
          ├─ YES → UNLOCK ✅
          │
          └─ NO  → Has class_date field?
                   │
                   ├─ YES → Check if class_date is paid
                   │        │
                   │        ├─ Paid     → UNLOCK ✅
                   │        └─ Not Paid → LOCK 🔒
                   │
                   └─ NO → Map posted_at to class date
                            │
                            ├─ Mapped class paid     → UNLOCK ✅
                            └─ Mapped class not paid → LOCK 🔒
```

---

### 5. Integration with Note Loading

**Function**: `computeNotePaymentStatus(notes, student, paymentRecords, scheduleData)`

Called during `loadClassroomUpdates()`:

1. Fetches all notes for student's group
2. Fetches all payment records for student
3. Loads student's schedule data (already cached)
4. Runs payment-locked notes engine:
   - Computes class dates for relevant months
   - Maps each note to a class date
   - Checks payment status
   - Returns Map<noteId, isPaid>

5. UI renders notes:
   - Unlocked notes: Show content, allow PDF downloads
   - Locked notes: Show 🔒 icon, blur content, display payment prompt

---

## 📊 Example Scenario

### Student Profile
- **Name**: Sarah Johnson
- **Group**: C
- **Schedule**: Monday 5:00 PM, Friday 3:00 PM
- **Price per class**: $50

### October 2025 Classes
```
Date        Day      Status
-------------------------------
2025-10-03  Friday   PAID ✅
2025-10-06  Monday   PAID ✅
2025-10-10  Friday   UNPAID ❌
2025-10-13  Monday   PAID ✅
2025-10-17  Friday   UNPAID ❌
2025-10-20  Monday   UNPAID ❌
2025-10-24  Friday   UNPAID ❌
2025-10-27  Monday   PAID ✅
2025-10-31  Friday   UNPAID ❌
```

### Posted Notes
```
Note Title                    Posted Date   Mapped Class   Unlocked?
------------------------------------------------------------------------
Cardiovascular System Intro   Oct 3 2:00 PM    Oct 3       YES ✅ (Oct 3 paid)
Blood Pressure Meds           Oct 5 9:00 AM    Oct 3       YES ✅ (Oct 3 paid)
Heart Failure Case Study      Oct 7 11:00 AM   Oct 6       YES ✅ (Oct 6 paid)
Respiratory System Overview   Oct 11 8:00 AM   Oct 10      NO 🔒 (Oct 10 unpaid)
Asthma Management             Oct 14 1:00 PM   Oct 13      YES ✅ (Oct 13 paid)
COPD Guidelines               Oct 18 10:00 AM  Oct 17      NO 🔒 (Oct 17 unpaid)
```

**Result**:
- Sarah can access: 4 notes (Oct 3, Oct 6, Oct 13 classes)
- Sarah cannot access: 2 notes (Oct 10, Oct 17 classes)
- To unlock all notes: Pay for Oct 10, 17, 20, 24, 31 ($250 total)

---

## 🎨 UI Indicators

### Unlocked Note Card
```
┌─────────────────────────────────────┐
│ 📚 Cardiovascular System            │
│                                     │
│ Cardiovascular System Intro         │
│ Complete guide to heart anatomy... │
│                                     │
│ [📄 View PDF] ← Clickable          │
│                                     │
│ Posted: Oct 3, 2025                │
└─────────────────────────────────────┘
```

### Locked Note Card
```
┌─────────────────────────────────────┐
│ 🔒 Payment Required                 │
│                                     │
│ Respiratory System Overview  [BLUR] │
│ Complete guide to lungs...   [BLUR] │
│                                     │
│ ┌─────────────────────────────────┐ │
│ │ 🔒 1 file locked                │ │
│ │ Complete payment for Oct 10     │ │
│ │ to unlock                       │ │
│ └─────────────────────────────────┘ │
│                                     │
│ Posted: Oct 11, 2025               │
└─────────────────────────────────────┘
```

---

## 🔍 Debug Mode

Enable detailed logging by setting `DEBUG_MODE = true`:

```javascript
const DEBUG_MODE = true;
```

**Console Output**:
```
🔐 Payment-locked notes engine results:
   - Total notes: 25
   - Unlocked by payment: 18
   - Locked: 7

💰 Student has 12 paid dates: [
  '2025-09-02', '2025-09-06', '2025-09-09',
  '2025-09-13', '2025-09-16', '2025-09-20',
  '2025-10-03', '2025-10-06', '2025-10-13',
  '2025-10-27', '2025-11-01', '2025-11-03'
]

📝 Note "Cardiovascular Intro" posted 2025-10-03 → Class 2025-10-03 → UNLOCKED
📝 Note "Respiratory Overview" posted 2025-10-11 → Class 2025-10-10 → LOCKED
🔒 Note "Respiratory Overview" (2025-10-10) is LOCKED - payment required
```

---

## 🚀 Performance Optimizations

### 1. Cached Schedule Data
- Schedule loaded once per session
- Stored in `currentGroupScheduleData`
- Reused for all note unlock computations

### 2. Set-Based Lookups
- Paid dates stored in Set for O(1) lookup
- Note IDs with free access in Set
- Efficient for large payment histories

### 3. Single DB Query
- All payment records fetched once
- All notes fetched once
- Engine runs in-memory

### 4. Lazy Mapping
- Class dates computed only for months with notes
- Avoids generating unnecessary date arrays

---

## 🔗 Dependencies

### Database Tables
- `payment_records` - Student payment history
- `student_notes` - Group notes
- `note_free_access` - Free access grants
- `student_note_permissions` - Note assignments
- `group_schedules` - Weekly class schedules

### Global Variables
- `currentStudent` - Active student object
- `currentGroupScheduleData` - Cached schedule
- `DEBUG_MODE` - Debug logging flag

### Functions Used
- `getGroupSchedule(groupName)` - Fetches schedule
- `getSystemNameFromNote(note)` - Extracts system name
- `displayNotes(notes)` - Renders note cards

---

## ⚙️ Configuration

### Fail-Safe Defaults
All edge cases default to **UNLOCK** to prevent blocking students:

1. No schedule data → Unlock
2. Can't map note to class → Unlock
3. No class dates in month → Unlock
4. Missing payment records → Unlock
5. Invalid date format → Unlock

**Rationale**: Better to accidentally unlock a note than block a paying student.

---

## 🧪 Testing Scenarios

### Test Case 1: Normal Flow
```javascript
// Student: Group C, Schedule: Mon/Fri
// Paid: Oct 3, Oct 6
// Note posted: Oct 5

// Expected: UNLOCKED (maps to Oct 3, which is paid)
```

### Test Case 2: Unpaid Class
```javascript
// Student: Group C, Schedule: Mon/Fri
// Paid: Oct 3, Oct 6
// Note posted: Oct 11

// Expected: LOCKED (maps to Oct 10, which is unpaid)
```

### Test Case 3: Free Access Override
```javascript
// Student: Group C
// Note requires payment: true
// Free access granted: true
// Payment status: unpaid

// Expected: UNLOCKED (free access overrides payment)
```

### Test Case 4: No Schedule
```javascript
// Student: No group assigned
// Schedule: null
// Note posted: Oct 15

// Expected: UNLOCKED (fail-safe default)
```

---

## 📝 Future Enhancements

### Potential Improvements
1. **Partial Payment Credit**: Allow unlocking X notes per partial payment
2. **Note Bundles**: Group notes into packages (e.g., "Week 1 Bundle")
3. **Preview Mode**: Show first paragraph of locked notes
4. **Payment Reminders**: Email student when new notes are posted but locked
5. **Unlock History**: Track when notes were unlocked for analytics

### Database Optimizations
1. Add `unlocked_at` timestamp to track first access
2. Index on `(student_id, class_date, status)` for faster queries
3. Materialized view for note unlock status

---

## 🎓 Admin Notes

### Setting Up Notes
1. Upload note PDF to `student-notes` bucket
2. Create `student_notes` record with `requires_payment = true`
3. Set `class_date` to specific class date OR let engine map via `posted_at`
4. Assign to group via `student_note_permissions`

### Override Access
Grant free access via `note_free_access` table:
```sql
INSERT INTO note_free_access (note_id, student_id, access_type)
VALUES (123, 45, 'individual');
```

### Check Unlock Status
```sql
-- See which notes student can access
SELECT 
  sn.id,
  sn.title,
  sn.class_date,
  pr.status,
  CASE 
    WHEN sn.requires_payment = false THEN 'Unlocked (No Payment Required)'
    WHEN pr.status = 'paid' THEN 'Unlocked (Paid)'
    WHEN nfa.note_id IS NOT NULL THEN 'Unlocked (Free Access)'
    ELSE 'Locked'
  END as unlock_status
FROM student_notes sn
LEFT JOIN payment_records pr 
  ON pr.student_id = 45 
  AND pr.date::date = sn.class_date::date
LEFT JOIN note_free_access nfa 
  ON nfa.note_id = sn.id 
  AND nfa.student_id = 45
WHERE sn.id IN (
  SELECT note_id FROM student_note_permissions WHERE student_id = 45
);
```

---

## ✅ Implementation Complete

The Payment-Locked Notes Engine is now live in `student-portal.html`. Notes automatically unlock based on calendar payment status, providing a seamless pay-per-class experience.

**Key Files Modified**:
- `student-portal.html` (lines ~6862-7150) - Engine functions
- `student-portal.html` (lines ~8700-8750) - Integration with note loading

**No breaking changes** - existing functionality preserved, new engine runs in parallel.
