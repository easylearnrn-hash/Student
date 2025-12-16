# Calendar Payment Consolidation - Implementation Guide

## 🎯 Goal
Simplify payment logic by using only the `payments` table with a `for_class` column to handle reassignments.

## 📊 Before & After

### Before (Current - 4 tables)
```
payments             → Zelle/Venmo imports + manual cash
payment_records      → Legacy manual entries
credit_payments      → Credit applications
manual_payment_moves → Payment reassignments
```

### After (Consolidated - 1 table)
```
payments
  ├── date           → When payment was made
  ├── for_class      → Which class it covers (NULL = auto, set = manual)
  ├── source         → 'zelle', 'manual', 'credit', etc.
  └── ... all other fields
```

---

## 🔧 Calendar.html Changes Required

### 1. Update `loadPayments()` Function

**Location:** Line ~6360-6420

**Before:**
```javascript
async function loadPayments() {
  // Load from payments table
  const { data: automatedPayments } = await supabase
    .from('payments')
    .select('*');
  
  // Load from payment_records table
  const { data: manualPayments } = await supabase
    .from('payment_records')
    .select('*');
  
  // Load from credit_payments
  const creditLookup = await loadCreditPayments();
  
  // Combine all sources
  return [...automatedPayments, ...manualPayments];
}
```

**After:**
```javascript
async function loadPayments() {
  // Load ALL payments from single table
  const { data: payments, error } = await supabase
    .from('payments')
    .select('*')
    .order('date', { ascending: false });
  
  if (error) {
    console.error('❌ Error loading payments:', error);
    return [];
  }
  
  debugLog('💰 Loaded payments:', payments.length);
  window.paymentsCache = payments;
  return payments;
}
```

---

### 2. Update Payment Matching Logic

**Location:** Line ~5400-5550 (inside `checkPaymentStatus()`)

**Before:**
```javascript
// Complex matching across multiple tables
const manualPayment = paymentRecords.find(p => 
  p.student_id === studentId && p.date === dateStr
);

const autoPayment = payments.find(p => 
  matchesStudent(p) && p.date <= dateStr
);

const creditPayment = creditLookup[studentId]?.[dateStr];

// Priority logic...
```

**After:**
```javascript
// Simple: Check if payment covers this class date
function findPaymentForClass(studentId, classDate) {
  return window.paymentsCache.find(payment => {
    // Must match student
    const matchesStudent = 
      payment.student_id === studentId ||
      payment.linked_student_id === studentId ||
      resolveStudentMatch(payment, studentId);
    
    if (!matchesStudent) return false;
    
    // Check coverage:
    // 1. If for_class is set → payment covers that exact date
    // 2. If for_class is NULL → auto-allocate to nearest past class
    
    if (payment.for_class !== null) {
      // Manual assignment: exact match only
      return payment.for_class === classDate;
    } else {
      // Auto-allocation: payment covers class on/before payment date
      return payment.date >= classDate && 
             payment.date <= getTodayStr() &&
             isNearestClass(payment.date, classDate, studentId);
    }
  });
}

const payment = findPaymentForClass(studentId, dateStr);
if (payment) {
  return {
    status: 'paid',
    paid: true,
    amount: payment.amount,
    paymentDate: payment.date,
    source: payment.source // 'zelle', 'manual', 'credit', etc.
  };
}
```

---

### 3. Remove Manual Payment Moves System

**Delete these sections:**
- `loadManualPaymentMovesFromSupabase()` (Line ~4214-4260)
- `recordManualPaymentMove()` (Line ~4266-4312)
- `applyManualMovesToAllocation()` (Line ~4314-4344)
- `MANUAL_PAYMENT_MOVES_TABLE` constant (Line ~4168)
- `manualPaymentMovesState` cache (Line ~4169-4173)

**Why:** Payment reassignments are now handled by updating `for_class` directly.

---

### 4. Update Move Payment Functions

**Location:** Line ~11844-12059 (`movePaymentToPrevious`, `movePaymentToNext`, `executeManualPaymentMove`)

**Before:**
```javascript
async function executeManualPaymentMove({ studentId, fromDate, toDate, amount }) {
  // Write to manual_payment_moves table
  await recordManualPaymentMove(studentId, fromDate, toDate, amount);
  
  // Clear caches
  studentAllocationCache.delete(`${studentId}-2025-12`);
  await loadManualPaymentMovesFromSupabase(true);
  clearMonthCache();
  renderCalendar();
}
```

**After:**
```javascript
async function executeManualPaymentMove({ studentId, fromDate, toDate, amount }) {
  // Find payment made on fromDate
  const payment = window.paymentsCache.find(p =>
    (p.student_id === studentId || p.linked_student_id === studentId) &&
    p.date === fromDate &&
    Math.abs(p.amount - amount) < 0.01
  );
  
  if (!payment) {
    throw new Error('Payment not found');
  }
  
  // Update for_class to reassign payment
  const { error } = await supabase
    .from('payments')
    .update({ for_class: toDate })
    .eq('id', payment.id);
  
  if (error) throw error;
  
  // Update cache
  payment.for_class = toDate;
  
  // Clear allocation cache and re-render
  studentAllocationCache.clear();
  clearMonthCache();
  renderCalendar();
  
  showSuccessToast(`✅ Payment reassigned to ${toDate}`);
}
```

---

### 5. Update Apply Credit Function

**Location:** Line ~11556-11681

**Before:**
```javascript
async function applyFromCredit(studentId, dateStr, pricePerClass) {
  // Update student balance
  await supabase.from('students').update({ balance: newBalance });
  
  // Create record in credit_payments table
  await CreditPaymentManager.applyCreditPayment(studentId, dateStr, amount);
}
```

**After:**
```javascript
async function applyFromCredit(studentId, dateStr, pricePerClass) {
  const student = window.studentsCache.find(s => s.id === studentId);
  const currentBalance = Number(student.balance) || 0;
  
  if (currentBalance < pricePerClass) {
    throw new Error('Insufficient credit balance');
  }
  
  const newBalance = currentBalance - pricePerClass;
  
  // Update student balance
  const { error: balanceError } = await supabase
    .from('students')
    .update({ balance: newBalance })
    .eq('id', studentId);
  
  if (balanceError) throw balanceError;
  
  // Create payment record with source='credit'
  const { error: paymentError } = await supabase
    .from('payments')
    .insert({
      student_id: studentId,
      amount: pricePerClass,
      date: dateStr,
      for_class: dateStr,  // Credit always applies to exact class
      email_date: dateStr + 'T12:00:00',
      payer_name: student.name,
      resolved_student_name: student.name,
      source: 'credit',
      message: 'Applied from account balance'
    });
  
  if (paymentError) throw paymentError;
  
  // Update local cache
  student.balance = newBalance;
  await loadPayments();
  
  showSuccessToast(`✅ Applied ${formatCurrency(pricePerClass)}$ from credit`);
}
```

---

### 6. Update Cash Payment Function

**Location:** Line ~11483-11552

**Before:**
```javascript
async function markPaidManually(studentId, dateStr, pricePerClass) {
  const paymentRecord = {
    student_id: studentId,
    amount: paymentAmount,
    date: dateStr,
    // ... fields
  };
  
  await supabase.from('payments').insert([paymentRecord]);
}
```

**After:**
```javascript
async function markPaidManually(studentId, dateStr, pricePerClass) {
  const student = window.studentsCache.find(s => s.id === studentId);
  const result = await showCashPaymentDialog(student, dateStr, pricePerClass);
  
  if (!result.confirmed) return;
  
  const paymentRecord = {
    student_id: studentId,
    student_name: student.name,
    amount: result.amount,
    date: dateStr,
    for_class: dateStr,  // Cash payment always for exact class
    email_date: dateStr + 'T12:00:00',
    payer_name: student.name,
    resolved_student_name: student.name,
    source: 'cash_manual',
    message: 'Cash payment - manually recorded'
  };
  
  const { error } = await supabase
    .from('payments')
    .insert([paymentRecord]);
  
  if (error) throw error;
  
  await loadPayments();
  invalidateDayCache(dateStr);
  renderCalendar();
  
  showSuccessToast('💵 Cash payment recorded');
}
```

---

### 7. Remove Credit Payment Manager

**Delete:**
- `window.CreditPaymentManager` (Line ~8015-8192)
- `loadCreditPayments()` calls
- `creditPaymentsLookup` global variable

**Why:** Credit payments are now regular payment records with `source='credit'`.

---

## 🗄️ Database Migration Steps

1. **Run migration SQL** (created in `consolidate-payments-migration.sql`)
   ```sql
   -- Adds for_class column
   -- Migrates manual_payment_moves → for_class
   -- Migrates payment_records → payments
   -- Migrates credit_payments → payments
   ```

2. **Verify migration**
   ```sql
   SELECT * FROM payment_coverage LIMIT 20;
   ```

3. **Test Calendar.html** with new logic

4. **Archive old tables** (only after confirming everything works)
   ```sql
   -- Save backups
   CREATE TABLE payment_records_archive AS SELECT * FROM payment_records;
   CREATE TABLE credit_payments_archive AS SELECT * FROM credit_payments;
   CREATE TABLE manual_payment_moves_archive AS SELECT * FROM manual_payment_moves;
   
   -- Drop originals
   DROP TABLE payment_records;
   DROP TABLE credit_payments;
   DROP TABLE manual_payment_moves;
   ```

---

## ✅ Benefits

1. **Simpler queries**: One table instead of 4
2. **Faster performance**: Single index lookup instead of multiple joins
3. **Cleaner logic**: `for_class` makes reassignments explicit
4. **Easier debugging**: All payment data in one place
5. **Better data integrity**: No sync issues between tables

---

## 🧪 Testing Checklist

- [ ] Payments load correctly
- [ ] Green dots appear for paid classes
- [ ] Red dots appear for unpaid classes
- [ ] Manual cash payments work
- [ ] Credit applications work
- [ ] Payment reassignment (← → arrows) works
- [ ] Student balance updates correctly
- [ ] Payment history shows all sources (Zelle, manual, credit)
- [ ] No console errors
- [ ] Calendar performance is good (no slowdowns)

---

## 🚨 Rollback Plan

If something breaks:

1. Restore old Calendar.html from backup
2. Keep migration tables as-is (old tables still exist)
3. Drop `for_class` column if needed:
   ```sql
   ALTER TABLE payments DROP COLUMN for_class;
   ```

---

## 📝 Example Payment Record

```json
{
  "id": "pay_123",
  "student_id": 45,
  "amount": 15.00,
  "date": "2025-12-10",
  "for_class": "2025-12-13",  // ← Payment reassigned to different class
  "email_date": "2025-12-10T14:30:00",
  "payer_name": "John Doe",
  "resolved_student_name": "John Doe",
  "source": "zelle",
  "message": "Weekly payment"
}
```

**Interpretation:**
- Payment made on Dec 10
- But it covers the class on Dec 13 (reassigned)
- Source was Zelle
- Student is John Doe (ID 45)

---

## 🎨 Payment Source Types

After consolidation, `source` field will distinguish:

- `zelle` - Automated Zelle import
- `venmo` - Automated Venmo import
- `cash_manual` - Admin entered cash payment
- `credit` - Applied from student balance
- `manual_legacy` - Migrated from payment_records table

This makes reporting and filtering much cleaner!

---

**Next Steps:**
1. Review migration SQL
2. Run migration on Supabase
3. Update Calendar.html payment logic
4. Test thoroughly
5. Archive old tables
6. Deploy 🚀
