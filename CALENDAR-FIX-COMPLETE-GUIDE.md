# CALENDAR PAYMENT LOGIC - COMPLETE REPLACEMENT GUIDE

## THE PROBLEM
Calendar.html uses an over-engineered "payment allocation" system that:
1. Tries to match payments across multiple classes (coverage maps)
2. Has broken Unicode name matching
3. Matches late payments to FUTURE classes (creates false credits)
4. Is 500+ lines of complex, buggy code

## THE SOLUTION  
Replace with the PROVEN SIMPLE LOGIC from index.html that has worked for months.

---

## STEP 1: Add the Working `checkPaymentStatus()` Function

**Location:** Around line 8500 in Calendar.html (before `renderStudentCard`)

**Add this exact function from index.html:**

```javascript
function checkPaymentStatus(student, classDate, pricePerClass, payments) {
  const dateStr = formatDateYYYYMMDD(classDate);
  const studentId = student.id;
  const laToday = new Date(); // Current date
  const todayStr = formatDateYYYYMMDD(laToday);

  // CHECK 1: Is this student marked absent?
  if (window.absencesData && window.absencesData[studentId] && window.absencesData[studentId][dateStr]) {
    return {
      status: 'absent',
      paid: false,
      amount: 0,
      balance: student.balance || 0,
      message: 'Marked Absent',
    };
  }

  // CHECK 2: Was credit applied to this class?
  if (window.creditPayments && window.creditPayments[studentId] && window.creditPayments[studentId][dateStr]) {
    return {
      status: 'credit',
      paid: true,
      amount: window.creditPayments[studentId][dateStr].amount,
      balance: student.balance || 0,
      message: `Paid from Credit`,
    };
  }

  const balance = student.balance || 0;

  // Find all payments for this student (by name or alias match)
  const studentPayments = payments.filter(p => {
    if (p.ignored) return false;

    const paymentStudentName = (p.student_name || p.studentName || '').toLowerCase().trim();
    const paymentPayerName = (p.payer_name || p.payerName || '').toLowerCase().trim();
    const paymentPayerNameRaw = (p.payer_name_raw || '').toLowerCase().trim();
    const paymentSenderName = (p.sender_name || '').toLowerCase().trim();
    const paymentResolvedName = (p.resolved_student_name || '').toLowerCase().trim();
    const studentNameLower = (student.name || '').toLowerCase().trim();

    // Check if any payment name field matches student name
    if (
      paymentStudentName === studentNameLower ||
      paymentPayerName === studentNameLower ||
      paymentPayerNameRaw === studentNameLower ||
      paymentSenderName === studentNameLower ||
      paymentResolvedName === studentNameLower
    ) {
      return true;
    }

    // Check if payment matches any student alias
    if (student.aliases && Array.isArray(student.aliases)) {
      return student.aliases.some(alias => {
        const aliasLower = alias.toLowerCase().trim();
        return (
          aliasLower === paymentStudentName ||
          aliasLower === paymentPayerName ||
          aliasLower === paymentPayerNameRaw ||
          aliasLower === paymentSenderName ||
          aliasLower === paymentResolvedName
        );
      });
    }

    return false;
  });

  // Check for payment on this date OR late payment (for PAST classes only)
  const paymentOnDate = studentPayments.find(p => {
    const paymentTimestamp = p.emailDate || p.email_date || p.date || p.timestamp;
    if (!paymentTimestamp) return false;

    const paymentDate = new Date(paymentTimestamp);
    const paymentDateStr = formatDateYYYYMMDD(paymentDate);

    // Exact date match
    if (paymentDateStr === dateStr) return true;

    // For PAST classes ONLY: allow payment from 1-7 days AFTER the class
    // CRITICAL: This prevents matching future classes
    if (dateStr < todayStr) {
      const classDate = new Date(dateStr);
      const payDate = new Date(paymentDateStr);
      const daysDiff = Math.floor((payDate - classDate) / (1000 * 60 * 60 * 24));

      // Payment can be 1-7 days AFTER the class date (not same day, not before)
      if (daysDiff > 0 && daysDiff <= 7) return true;
    }

    return false;
  });

  if (paymentOnDate) {
    const paymentAmount = parseFloat(paymentOnDate.amount || paymentOnDate.amountUSD || paymentOnDate.amount_paid_usd || 0);

    if (paymentAmount > pricePerClass) {
      const remainder = paymentAmount - pricePerClass;
      return {
        status: 'paid',
        paid: true,
        amount: paymentAmount,
        balance: balance,
        message: `Paid $${paymentAmount.toFixed(2)} ($${remainder.toFixed(2)} overpaid)`,
      };
    } else {
      return {
        status: 'paid',
        paid: true,
        amount: paymentAmount,
        balance: balance,
        message: `Paid $${paymentAmount.toFixed(2)}`,
      };
    }
  }

  // No payment found - check class timing for status

  // Future class - show as pending/upcoming
  if (classDate > laToday) {
    return {
      status: 'upcoming',
      paid: false,
      amount: 0,
      balance: balance,
      message: balance >= pricePerClass ? `Future ($${balance.toFixed(2)} available)` : 'Scheduled',
    };
  }

  // TODAY or PAST unpaid - show red dot
  if (dateStr <= todayStr) {
    return {
      status: 'unpaid',
      paid: false,
      amount: 0,
      balance: balance,
      message: balance > 0 ? `Unpaid ($${balance.toFixed(2)} balance)` : 'Not Paid',
      showActions: true,
    };
  }

  // Default future
  return {
    status: 'upcoming',
    paid: false,
    amount: 0,
    balance: balance,
    message: 'Scheduled',
  };
}
```

---

## STEP 2: Update `renderStudentCard()` to Call `checkPaymentStatus()`

**Location:** Line 8517 in Calendar.html

**Replace the beginning of `renderStudentCard()` with:**

```javascript
function renderStudentCard(student, group, classDate, index) {
  const displayName = student.name || 'Student';
  const initials = displayName
    .split(' ')
    .map(n => n[0])
    .join('');
  const normalizedId = `student-${dayEntry.dateStr}-${student.id || `${group.groupName || 'group'}-${index}`}`
    .replace(/[^a-zA-Z0-9-_]/g, '_');
  const safeName = displayName.replace(/'/g, "\\'");
  const studentId = student.id;
  const dateStr = dayEntry.dateStr;
  const pricePerClass = student.pricePerClass || 0;
  const studentBalance = student.balance || 0;
  
  // NEW: Call the working payment check logic
  const classDateObj = new Date(dateStr);
  const paymentStatus = checkPaymentStatus(student, classDateObj, pricePerClass, window.paymentsCache || []);
  
  // Use payment status to set student status
  student.status = paymentStatus.status;
  student.paid = paymentStatus.paid;
  student.paidAmount = paymentStatus.amount;
  student.statusLabel = paymentStatus.message;
  
  // Rest of the function stays the same...
```

---

## STEP 3: Remove the Broken Complex Logic

**Find and DELETE these functions (they're causing the problems):**

1. `allocatePaymentsToClasses()` - Around line 3920
2. `collectPaymentsForStudent()` - Around line 3715
3. `buildPaymentCoverage()` - Around line 3650
4. All the "coverage map" and "payment indexing" code

**Search for these and delete them:**
- `buildPaymentCoverage`
- `allocatePaymentsToClasses`
- `collectPaymentsForStudent`
- `paymentIndexes.byDate`
- `coverageMap`

---

## STEP 4: Test

1. Hard refresh Calendar (`Cmd+Shift+R`)
2. Check December 2025
3. Verify:
   - ✅ Beatrisa shows PAID (Unicode name matching works)
   - ✅ Milena/Anahit Dec 3 shows UNPAID (no false credit)
   - ✅ Future classes don't show red dots
   - ✅ Past unpaid classes show red dots

---

## WHY THIS WORKS

**Old working logic (index.html):**
- Simple: Check each student on each date
- Fast: One payment lookup per student per date
- Accurate: Clear rules (exact match OR 1-7 days late for PAST only)
- Proven: Has worked for months without issues

**New broken logic (Calendar.html):**
- Complex: 500+ lines of allocation/coverage/indexing
- Slow: Pre-processes all payments for all students
- Buggy: Unicode breaks, future classes match late payments
- Unproven: Recently added, constantly causing issues

**Keep it simple. Use what works.** ✅
