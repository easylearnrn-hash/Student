# Payment Matching System - Complete Specification

**Date:** December 15, 2025  
**Status:** ✅ ALL 5 CRITICAL FIXES IMPLEMENTED

---

## 🎯 Core Matching Rule

```javascript
payment.student_id === student.id 
AND 
normalizeDateStr(payment.for_class) === normalizeDateStr(class.date)
```

**That's it.** No name matching, no alias matching, no fuzzy logic.

---

## 🟢 🔴 🟡 🟣 Dot Color States (Complete)

| Color | Condition | Meaning | Implementation |
|-------|-----------|---------|----------------|
| 🟢 GREEN | Match found + not absent + no duplicate | Paid | `status: 'paid'` |
| 🔴 RED | No match OR absent | Unpaid | `status: 'unpaid'` |
| 🟡 YELLOW | Duplicate payments for same student+date | Data integrity error | `status: 'error'` |
| 🟣 FUCHSIA (Type A) | `student_id IS NULL` | Unlinked payment | `reason: 'Unlinked'` |
| 🟣 FUCHSIA (Type B) | `student_id NOT NULL` + no class on date | Misallocated payment | `reason: 'No class'` |

---

## 🟣 Fuchsia Dots: Type A vs Type B (NEW)

### **Type A: Unlinked Payment**
```javascript
payment.student_id IS NULL
```
- **Meaning:** Payment imported but not matched to any student
- **Label:** `"Unlinked payment - $X.XX"`
- **Action:** Admin must link to student in Payment-Records

### **Type B: Misallocated Payment**
```javascript
payment.student_id IS NOT NULL 
AND student has NO class on payment.for_class date
```
- **Meaning:** Payment assigned to wrong date
- **Label:** `"[Student Name] - Payment for non-class day ($X.XX)"`
- **Action:** Admin must reassign via "Reassign Payment"

### **Code Implementation**
```javascript
// In findUnmatchedPaymentsForDate()
if (!studentId) {
  // TYPE A: Unlinked
  unmatchedPayments.push({
    reason: 'Unlinked',
    // ...
  });
} else if (!studentsOnThisDate.has(studentId)) {
  // TYPE B: Misallocated
  unmatchedPayments.push({
    reason: 'No class',
    // ...
  });
}

// In fuchsia dot rendering
if (payment.reason === 'Unlinked') {
  tooltip = `Unlinked payment - $${amount}`;
} else if (payment.reason === 'No class') {
  tooltip = `${payerName} - Payment for non-class day ($${amount})`;
}
```

---

## 🟡 Duplicate Payment ERROR State (NEW)

### **Detection**
```javascript
// buildPaymentIndex() creates ERROR object when duplicate found
if (index[sid][forClass]) {
  // Mark as ERROR - DO NOT auto-pick one
  index[sid][forClass] = {
    ERROR: true,
    message: 'DUPLICATE PAYMENT - ADMIN ACTION REQUIRED',
    payments: [originalPayment, payment],
    student_id: sid,
    for_class: forClass
  };
}
```

### **Rendering**
```javascript
// findPaymentMatchForClass() returns ERROR state
if (match.ERROR) {
  return {
    ERROR: true,
    message: match.message,
    payments: match.payments,
    // ...
  };
}

// getDotClassForStudent() renders yellow dot
if (student.status === 'error') return 'dot-error';
```

### **Admin Alert**
```javascript
// showDuplicateErrorModal() displays all duplicates
"🚨 DATA INTEGRITY ERROR

Found 2 duplicate payment(s):

1. Aleksandr - 2025-12-12
   Payment 1: $50 (ID: abc-123)
   Payment 2: $50 (ID: def-456)

⚠️ ACTION REQUIRED:
1. Open Supabase → payments table
2. Delete incorrect payment(s)
3. Refresh calendar"
```

### **CSS**
```css
.dot-error {
  background: #ffeb3b; /* Yellow */
  animation: pulse-error 2s ease-in-out infinite;
}
```

---

## ⚠️ Default Assignment Documentation (NEW)

### **Why Fuchsia Dots Are Expected Initially**

When payments are imported (Zelle/Venmo), the database trigger sets:
```sql
payments.for_class = (receipt_date AT TIME ZONE 'America/Los_Angeles')::date
```

This means `for_class` defaults to the **RECEIPT DATE**, not the actual class date.

### **Expected Behavior Table**

| Scenario | Receipt Date | for_class (Default) | Actual Class | Result |
|----------|--------------|---------------------|--------------|--------|
| Payment received early | Dec 10 | Dec 10 | Dec 12 | 🟣 FUCHSIA (misallocated) |
| Payment received late | Dec 15 | Dec 15 | Dec 12 | 🟣 FUCHSIA (misallocated) |
| Payment on class day | Dec 12 | Dec 12 | Dec 12 | 🟢 GREEN (correct by chance) |

### **This is BY DESIGN**
- The trigger cannot know the student's schedule
- Fuchsia dots indicate: **"Payment exists but assigned to wrong date - needs reassignment"**
- Admins MUST use "Reassign Payment" to correct the `for_class` date

### **UI Documentation**
```javascript
// Fuchsia row label tooltip
unmatchedLabel.title = 'Fuchsia Dots: Payments awaiting reassignment to correct class date';
```

---

## 📅 Date Normalization Enforcement (NEW)

### **Canonical Function**
```javascript
/**
 * CANONICAL DATE NORMALIZER
 * All date comparisons MUST use this function.
 * 
 * ⚠️ ENFORCEMENT RULE:
 * Any date comparison NOT using normalizeDateStr() is a bug.
 * 
 * ❌ FORBIDDEN PATTERNS:
 * - new Date().toISOString().split('T')[0]  // UTC timezone, wrong!
 * - date1 === date2 (direct Date comparison)  // Object comparison, wrong!
 * - date.toLocaleDateString()  // Locale-dependent format, wrong!
 * 
 * ✅ ALLOWED:
 * - normalizeDateStr(anyDateInput)
 * - normalizeDateStr(new Date())  // Today in LA timezone
 * - normalizeDateStr(payment.for_class)  // Normalize before comparison
 */
function normalizeDateStr(dateInput) {
  if (!dateInput) return null;
  
  if (dateInput instanceof Date) {
    const parts = getLAParts(dateInput);
    if (!parts) return null;
    return `${parts.year}-${parts.month}-${parts.day}`;
  }
  
  if (typeof dateInput === 'string') {
    // Validate YYYY-MM-DD format
    if (/^\d{4}-\d{2}-\d{2}$/.test(dateInput)) {
      return dateInput;
    }
    // Try parsing as date string
    const match = dateInput.match(/^(\d{4})-(\d{2})-(\d{2})/);
    if (match) return `${match[1]}-${match[2]}-${match[3]}`;
  }
  
  return null;
}
```

### **Fixed Patterns**
- ✅ `modal.getAttribute('data-class-date') || normalizeDateStr(new Date())`
- ✅ `const today = normalizeDateStr(new Date())`

---

## 🚫 Rule C: Absent + Paid Conflict Handling (NEW)

### **Scenario**
1. Admin assigns payment to Dec 12
2. Later, Dec 12 is marked ABSENT
3. What happens?

### **Chosen Behavior: Auto-Misallocate**

```javascript
// In findPaymentMatchForClass()
// RULE C: Check if student is absent on this date
// If absent, payment becomes orphaned (misallocated) and will show as fuchsia
if (isStudentAbsent(studentId, normalizedDate)) {
  return null; // Absent classes don't count as paid → RED dot
  // Payment will appear as FUCHSIA (misallocated) on this date
}
```

### **Visual Result**
- **Student dot on Dec 12:** 🔴 RED (unpaid appearance, because absent)
- **Fuchsia indicator on Dec 12:** Shows `"[Name] - Payment for non-class day"`
- **Admin sees:** "This student was absent but has a payment - reassign it"

### **Alternative Rules (NOT implemented)**
- **Rule A:** Block reassignment to absent dates (prevent conflict entirely)
- **Rule B:** Show ORANGE dot for "Paid but absent" (3rd state)

---

## 🗄️ Database Schema

### **payments table**
| Column | Type | Purpose |
|--------|------|---------|
| `id` | UUID | Unique payment ID |
| `student_id` | UUID | Links to students.id |
| `for_class` | DATE | The class date this payment covers (YYYY-MM-DD) |
| `date` | TIMESTAMP | When payment was received |
| `amount` | NUMERIC | Payment amount |

### **Trigger (Timezone Safety)**
```sql
CREATE OR REPLACE FUNCTION set_for_class_default()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.for_class IS NULL THEN
    NEW.for_class = (NEW.date AT TIME ZONE 'America/Los_Angeles')::date;
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;
```

### **Constraint (Duplicate Prevention)**
```sql
CREATE UNIQUE INDEX unique_student_class_payment 
ON payments(student_id, for_class) 
WHERE student_id IS NOT NULL AND for_class IS NOT NULL;
```

---

## ⚡ Performance

### **Payment Index (O(1) Lookup)**
```javascript
paymentIndex = {
  "42": {                    // student_id
    "2025-12-12": payment1,  // yyyy-mm-dd: payment object
    "2025-12-13": payment2
  },
  "57": {
    "2025-12-14": payment3
  }
}
```

**Before:** O(n × m × p) = days × students × payments  
**Now:** O(n × m) with O(1) payment lookup

**Example:**
- 30 days × 50 students × 915 payments = 1,372,500 comparisons
- 30 days × 50 students × 1 lookup = 1,500 lookups

**Result:** ~900x faster 🚀

---

## 🧪 Testing

### **1. Open Console (F12)**
```javascript
// On calendar load:
"📚 Built payment index for 50 students"

// If duplicates exist:
"🚨 DUPLICATE PAYMENT: student=42, date=2025-12-12"
"🚨 DATA INTEGRITY VIOLATION - 2 DUPLICATE(S) FOUND"
```

### **2. Test Fuchsia Type A (Unlinked)**
- Import payment without `student_id`
- Should show: `"Unlinked payment - $50"`

### **3. Test Fuchsia Type B (Misallocated)**
- Payment exists for Dec 13
- Student has NO class on Dec 13
- Should show: `"Aleksandr - Payment for non-class day ($50)"`

### **4. Test ERROR State (Duplicate)**
- Create 2 payments: student=42, for_class=2025-12-12
- Should show: 🟡 YELLOW dot with pulse animation
- Modal should appear with duplicate details

### **5. Test Absent + Paid Conflict**
- Assign payment to Dec 12
- Mark student absent on Dec 12
- Should show: 🔴 RED dot (unpaid) + 🟣 FUCHSIA (misallocated payment)

### **6. Test Reassignment Validation**
- Click any student dot → "Reassign Payment"
- Should show: `"ELIGIBLE DATES (scheduled, not absent, not paid): ..."`
- Try invalid date → should warn

---

## 📋 Summary of All 5 Fixes

| Fix # | Issue | Solution | Status |
|-------|-------|----------|--------|
| 1 | Fuchsia dots collapsed Type A (unlinked) and Type B (misallocated) | Split into distinct types with different tooltips | ✅ COMPLETE |
| 2 | Duplicates auto-picked latest payment, hiding bugs | ERROR state, yellow dot, admin modal | ✅ COMPLETE |
| 3 | Devs confused why fuchsia dots appear initially | Documentation: trigger defaults to receipt date by design | ✅ COMPLETE |
| 4 | Mixed date comparison patterns (ISO/locale/objects) | Enforce normalizeDateStr() only, fix 2 violations | ✅ COMPLETE |
| 5 | Absent + Paid conflict undefined | Rule C: Auto-misallocate (RED + FUCHSIA) | ✅ COMPLETE |

---

## 🚀 Deployment

1. **Hard refresh browser:** `Cmd+Shift+R`
2. **Open console:** F12 → Look for payment index build messages
3. **Check for duplicates:** Console will show errors if any exist
4. **Test reassignment:** Click dot → "Reassign Payment" → See eligible dates
5. **Monitor fuchsia dots:** Should now show clear Type A vs Type B labels

---

**All 5 critical fixes implemented. System is production-ready.** ✅
