/**
 * ========================================
 * CALENDAR DOT PAYMENT MATCHING TEST SUITE
 * ========================================
 * 
 * Comprehensive testing for Calendar.html payment dot matching logic
 * Tests the critical `findPaymentMatchForClass()` and `determineClassStatus()` functions
 */

// ==========================================================================
// CALENDAR PAYMENT MATCHING ENGINE (Embedded for Testing)
// ==========================================================================

const DEBUG_MODE = false;

// Helper: Format date as YYYY-MM-DD from Date object
function formatDateYYYYMMDD(date) {
  if (!date) return '';
  const year = date.getFullYear();
  const month = String(date.getMonth() + 1).padStart(2, '0');
  const day = String(date.getDate()).padStart(2, '0');
  return `${year}-${month}-${day}`;
}

// Helper: Create Date from YYYY-MM-DD string
function createDateFromDateStr(dateStr) {
  if (!dateStr) return null;
  const parts = dateStr.split('-');
  if (parts.length !== 3) return null;
  return new Date(parseInt(parts[0]), parseInt(parts[1]) - 1, parseInt(parts[2]));
}

// Helper: Format currency
function formatCurrency(amount) {
  return Number(amount).toFixed(2);
}

// Helper: Get student balance
function getStudentBalance(student) {
  return Number(student.balance) || 0;
}

/**
 * Core function: Find payment match for a specific class date
 * Priority 1: Exact date match
 * Priority 2: ANY payment in same month (user requirement: "payment applies regardless of date")
 */
function findPaymentMatchForClass(student, dateStr, todayStr = null) {
  const studentPayments = student.payments || [];
  if (!studentPayments.length) return null;

  const today = todayStr || formatDateYYYYMMDD(new Date());
  const classDate = createDateFromDateStr(dateStr);
  if (!classDate) return null;

  // Extract class month/year for matching
  const classMonth = classDate.getMonth();
  const classYear = classDate.getFullYear();

  // Priority 1: Exact date match (highest priority - specific payment for specific class)
  const exactMatch = studentPayments.find(payment => payment.dateStr === dateStr);
  if (exactMatch) {
    return exactMatch;
  }

  // No matching for future classes
  if (dateStr >= today) {
    return null;
  }

  // Priority 2: ANY payment in the same month
  // User requirement: "whenever the system sees payment from the student it should apply regardless of the date"
  const sameMonthPayment = studentPayments.find(payment => {
    if (!payment.dateStr) return false;
    const paymentDate = createDateFromDateStr(payment.dateStr);
    if (!paymentDate) return false;
    
    // Payment must be in the same month/year as the class
    const paymentMonth = paymentDate.getMonth();
    const paymentYear = paymentDate.getFullYear();
    
    return (paymentMonth === classMonth && paymentYear === classYear);
  });

  return sameMonthPayment || null;
}

/**
 * Determine class payment status for a student on a specific date
 * Returns: { status, label, balance, paidAmount, paymentDate, paymentTime }
 * Status: 'paid', 'unpaid', 'upcoming', 'absent', 'canceled', 'skipped', 'credit'
 */
function determineClassStatus(student, dateStr, skipInfo = null, todayStr = null) {
  if (!student || !dateStr) return null;

  const balance = getStudentBalance(student);
  const pricePerClass = Number(student.price_per_class || student.pricePerClass) || 0;
  const today = todayStr || formatDateYYYYMMDD(new Date());

  // Priority 1: Check if class was canceled or skipped
  if (skipInfo) {
    const isCanceled = skipInfo.type === 'class-canceled';
    return {
      status: isCanceled ? 'canceled' : 'skipped',
      label: skipInfo.note || (isCanceled ? 'Class canceled' : 'Class skipped'),
      balance,
      paidAmount: 0,
    };
  }

  // Priority 2: Check if student was absent
  if (student.absences && student.absences.includes(dateStr)) {
    return {
      status: 'absent',
      label: 'Marked absent',
      balance,
      paidAmount: 0,
    };
  }

  // Priority 3: Check for payment match
  const paymentMatch = findPaymentMatchForClass(student, dateStr, today);
  if (paymentMatch && paymentMatch.amount > 0) {
    const paidAmount = paymentMatch.amount;
    const overpayAmount = pricePerClass > 0 ? paidAmount - pricePerClass : 0;
    const labelBase = `Paid ${formatCurrency(paidAmount)} $`;
    const label = overpayAmount > 0
      ? `${labelBase} (${formatCurrency(overpayAmount)} $ overpaid)`
      : labelBase;
    
    return {
      status: 'paid',
      label,
      balance,
      paidAmount,
      paymentDate: paymentMatch.dateStr,
      paymentTime: paymentMatch.timeStr || '',
    };
  }

  // Priority 4: Check if paid via credit
  if (student.creditPayments && student.creditPayments.includes(dateStr)) {
    return {
      status: 'credit',
      label: `Paid from credit (${formatCurrency(pricePerClass)} $)`,
      balance,
      paidAmount: pricePerClass,
    };
  }

  // Priority 5: Future class (no payment yet)
  if (dateStr > today) {
    return {
      status: 'upcoming',
      label: balance > 0 ? `Upcoming (balance ${formatCurrency(balance)} $)` : 'Upcoming class',
      balance,
      paidAmount: 0,
    };
  }

  // Priority 6: Unpaid (past or today, no payment, no absence)
  return {
    status: 'unpaid',
    label: balance > 0 ? `Unpaid (${formatCurrency(balance)} $ balance)` : 'Unpaid',
    balance,
    paidAmount: 0,
    owedAmount: pricePerClass,
  };
}

// ==========================================================================
// TEST SUITE
// ==========================================================================

const testResults = {
  total: 0,
  passed: 0,
  failed: 0,
  tests: []
};

function logTest(name, passed, details = '') {
  testResults.total++;
  if (passed) {
    testResults.passed++;
    console.log(`✅ PASS: ${name}`, details);
  } else {
    testResults.failed++;
    console.error(`❌ FAIL: ${name}`, details);
  }
  testResults.tests.push({ name, passed, details });
}

// Helper to create mock student
function createMockStudent(options = {}) {
  return {
    id: options.id || 1,
    name: options.name || 'Test Student',
    balance: options.balance || 0,
    price_per_class: options.pricePerClass || 20,
    payments: options.payments || [],
    absences: options.absences || [],
    creditPayments: options.creditPayments || [],
  };
}

// Helper to create mock payment
function createMockPayment(dateStr, amount, timeStr = '14:00:00') {
  return {
    dateStr,
    amount: Number(amount),
    timeStr,
  };
}

// ========================================
// TEST GROUP 1: Exact Date Match
// ========================================
console.log('\n🔵 TEST GROUP 1: Exact Date Match\n');

// Test 1.1: Payment on exact class date
(function test_1_1_Exact_Date_Match() {
  const student = createMockStudent({
    payments: [
      createMockPayment('2025-12-06', 20)
    ]
  });
  
  const match = findPaymentMatchForClass(student, '2025-12-06', '2025-12-10');
  const passed = match !== null && match.amount === 20 && match.dateStr === '2025-12-06';
  
  logTest('1.1: Exact date match returns payment', passed, {
    classDate: '2025-12-06',
    paymentDate: match?.dateStr,
    amount: match?.amount
  });
})();

// Test 1.2: No payment on class date
(function test_1_2_No_Exact_Match() {
  const student = createMockStudent({
    payments: [
      createMockPayment('2025-12-10', 20)
    ]
  });
  
  const match = findPaymentMatchForClass(student, '2025-12-06', '2025-12-10');
  // Should still match because same month (Priority 2)
  const passed = match !== null && match.dateStr === '2025-12-10';
  
  logTest('1.2: Different date, same month → month match', passed, {
    classDate: '2025-12-06',
    paymentDate: match?.dateStr
  });
})();

// Test 1.3: Multiple payments, exact match takes priority
(function test_1_3_Exact_Match_Priority() {
  const student = createMockStudent({
    payments: [
      createMockPayment('2025-12-03', 25), // Other payment in month
      createMockPayment('2025-12-06', 20), // Exact match
      createMockPayment('2025-12-10', 30), // Other payment in month
    ]
  });
  
  const match = findPaymentMatchForClass(student, '2025-12-06', '2025-12-10');
  const passed = match !== null && match.dateStr === '2025-12-06' && match.amount === 20;
  
  logTest('1.3: Exact match has priority over other month payments', passed, {
    classDate: '2025-12-06',
    paymentDate: match?.dateStr,
    amount: match?.amount
  });
})();

// ========================================
// TEST GROUP 2: Same Month Matching
// ========================================
console.log('\n🔵 TEST GROUP 2: Same Month Matching\n');

// Test 2.1: Payment later in same month
(function test_2_1_Payment_Later_Same_Month() {
  const student = createMockStudent({
    payments: [
      createMockPayment('2025-12-15', 20)
    ]
  });
  
  const match = findPaymentMatchForClass(student, '2025-12-06', '2025-12-16');
  const passed = match !== null && match.dateStr === '2025-12-15';
  
  logTest('2.1: Payment later in same month → matches', passed, {
    classDate: '2025-12-06',
    paymentDate: match?.dateStr
  });
})();

// Test 2.2: Payment earlier in same month
(function test_2_2_Payment_Earlier_Same_Month() {
  const student = createMockStudent({
    payments: [
      createMockPayment('2025-12-03', 20)
    ]
  });
  
  const match = findPaymentMatchForClass(student, '2025-12-10', '2025-12-16');
  const passed = match !== null && match.dateStr === '2025-12-03';
  
  logTest('2.2: Payment earlier in same month → matches', passed, {
    classDate: '2025-12-10',
    paymentDate: match?.dateStr
  });
})();

// Test 2.3: Payment in different month (no match)
(function test_2_3_Different_Month_No_Match() {
  const student = createMockStudent({
    payments: [
      createMockPayment('2025-11-15', 20) // November payment
    ]
  });
  
  const match = findPaymentMatchForClass(student, '2025-12-06', '2025-12-10');
  const passed = match === null;
  
  logTest('2.3: Payment in different month → no match', passed, {
    classDate: '2025-12-06',
    paymentDate: match?.dateStr,
    expected: null
  });
})();

// Test 2.4: Payment in different year (no match)
(function test_2_4_Different_Year_No_Match() {
  const student = createMockStudent({
    payments: [
      createMockPayment('2024-12-06', 20) // 2024 payment
    ]
  });
  
  const match = findPaymentMatchForClass(student, '2025-12-06', '2025-12-10');
  const passed = match === null;
  
  logTest('2.4: Payment in different year → no match', passed, {
    classDate: '2025-12-06',
    paymentDate: match?.dateStr,
    expected: null
  });
})();

// Test 2.5: Multiple payments in same month (first match wins)
(function test_2_5_Multiple_Same_Month() {
  const student = createMockStudent({
    payments: [
      createMockPayment('2025-12-03', 20),
      createMockPayment('2025-12-10', 25),
      createMockPayment('2025-12-15', 30),
    ]
  });
  
  const match = findPaymentMatchForClass(student, '2025-12-06', '2025-12-16');
  // Should return first match found (Dec 3)
  const passed = match !== null && match.dateStr === '2025-12-03';
  
  logTest('2.5: Multiple same-month payments → first match', passed, {
    classDate: '2025-12-06',
    paymentDate: match?.dateStr,
    amount: match?.amount
  });
})();

// ========================================
// TEST GROUP 3: Future Class Behavior
// ========================================
console.log('\n🔵 TEST GROUP 3: Future Class Behavior\n');

// Test 3.1: Future class with payment (no match)
(function test_3_1_Future_Class_No_Match() {
  const student = createMockStudent({
    payments: [
      createMockPayment('2025-12-06', 20)
    ]
  });
  
  const match = findPaymentMatchForClass(student, '2025-12-10', '2025-12-05');
  const passed = match === null;
  
  logTest('3.1: Future class → no payment match', passed, {
    classDate: '2025-12-10',
    today: '2025-12-05',
    match: match
  });
})();

// Test 3.2: Class on today with payment (matches)
(function test_3_2_Class_Today_Matches() {
  const student = createMockStudent({
    payments: [
      createMockPayment('2025-12-06', 20)
    ]
  });
  
  const match = findPaymentMatchForClass(student, '2025-12-06', '2025-12-06');
  const passed = match !== null && match.dateStr === '2025-12-06';
  
  logTest('3.2: Class on today → matches payment', passed, {
    classDate: '2025-12-06',
    today: '2025-12-06',
    paymentDate: match?.dateStr
  });
})();

// Test 3.3: Past class with future payment in same month (matches)
(function test_3_3_Past_Class_Future_Payment() {
  const student = createMockStudent({
    payments: [
      createMockPayment('2025-12-15', 20) // Payment on Dec 15
    ]
  });
  
  const match = findPaymentMatchForClass(student, '2025-12-06', '2025-12-20');
  const passed = match !== null && match.dateStr === '2025-12-15';
  
  logTest('3.3: Past class, future payment same month → matches', passed, {
    classDate: '2025-12-06',
    paymentDate: match?.dateStr,
    today: '2025-12-20'
  });
})();

// ========================================
// TEST GROUP 4: Class Status Determination
// ========================================
console.log('\n🔵 TEST GROUP 4: Class Status Determination\n');

// Test 4.1: Paid class status
(function test_4_1_Paid_Status() {
  const student = createMockStudent({
    pricePerClass: 20,
    balance: 50,
    payments: [createMockPayment('2025-12-06', 20)]
  });
  
  const status = determineClassStatus(student, '2025-12-06', null, '2025-12-10');
  const passed = status !== null && 
                 status.status === 'paid' && 
                 status.paidAmount === 20 &&
                 status.paymentDate === '2025-12-06';
  
  logTest('4.1: Paid class → correct status', passed, {
    status: status?.status,
    paidAmount: status?.paidAmount,
    label: status?.label
  });
})();

// Test 4.2: Unpaid class status
(function test_4_2_Unpaid_Status() {
  const student = createMockStudent({
    pricePerClass: 20,
    balance: 50,
    payments: []
  });
  
  const status = determineClassStatus(student, '2025-12-06', null, '2025-12-10');
  const passed = status !== null && 
                 status.status === 'unpaid' && 
                 status.paidAmount === 0 &&
                 status.owedAmount === 20;
  
  logTest('4.2: Unpaid class → correct status', passed, {
    status: status?.status,
    owedAmount: status?.owedAmount,
    label: status?.label
  });
})();

// Test 4.3: Upcoming class status
(function test_4_3_Upcoming_Status() {
  const student = createMockStudent({
    pricePerClass: 20,
    balance: 30,
    payments: []
  });
  
  const status = determineClassStatus(student, '2025-12-15', null, '2025-12-10');
  const passed = status !== null && 
                 status.status === 'upcoming' && 
                 status.paidAmount === 0;
  
  logTest('4.3: Future class → upcoming status', passed, {
    status: status?.status,
    label: status?.label
  });
})();

// Test 4.4: Absent class status (Priority 2)
(function test_4_4_Absent_Status() {
  const student = createMockStudent({
    pricePerClass: 20,
    absences: ['2025-12-06'],
    payments: [createMockPayment('2025-12-06', 20)] // Even with payment
  });
  
  const status = determineClassStatus(student, '2025-12-06', null, '2025-12-10');
  const passed = status !== null && 
                 status.status === 'absent' && 
                 status.paidAmount === 0;
  
  logTest('4.4: Absent overrides payment → absent status', passed, {
    status: status?.status,
    label: status?.label
  });
})();

// Test 4.5: Canceled class status (Priority 1)
(function test_4_5_Canceled_Status() {
  const student = createMockStudent({
    pricePerClass: 20,
    payments: [createMockPayment('2025-12-06', 20)] // Even with payment
  });
  
  const skipInfo = { type: 'class-canceled', note: 'Holiday' };
  const status = determineClassStatus(student, '2025-12-06', skipInfo, '2025-12-10');
  const passed = status !== null && 
                 status.status === 'canceled' && 
                 status.paidAmount === 0;
  
  logTest('4.5: Canceled overrides all → canceled status', passed, {
    status: status?.status,
    label: status?.label
  });
})();

// Test 4.6: Credit payment status
(function test_4_6_Credit_Status() {
  const student = createMockStudent({
    pricePerClass: 20,
    balance: 30,
    creditPayments: ['2025-12-06']
  });
  
  const status = determineClassStatus(student, '2025-12-06', null, '2025-12-10');
  const passed = status !== null && 
                 status.status === 'credit' && 
                 status.paidAmount === 20;
  
  logTest('4.6: Credit payment → credit status', passed, {
    status: status?.status,
    paidAmount: status?.paidAmount,
    label: status?.label
  });
})();

// ========================================
// TEST GROUP 5: Overpayment Detection
// ========================================
console.log('\n🔵 TEST GROUP 5: Overpayment Detection\n');

// Test 5.1: Exact payment amount
(function test_5_1_Exact_Payment() {
  const student = createMockStudent({
    pricePerClass: 20,
    payments: [createMockPayment('2025-12-06', 20)]
  });
  
  const status = determineClassStatus(student, '2025-12-06', null, '2025-12-10');
  const passed = status !== null && 
                 status.paidAmount === 20 &&
                 !status.label.includes('overpaid');
  
  logTest('5.1: Exact payment → no overpay label', passed, {
    paidAmount: status?.paidAmount,
    label: status?.label
  });
})();

// Test 5.2: Overpayment detection
(function test_5_2_Overpayment() {
  const student = createMockStudent({
    pricePerClass: 20,
    payments: [createMockPayment('2025-12-06', 30)]
  });
  
  const status = determineClassStatus(student, '2025-12-06', null, '2025-12-10');
  const passed = status !== null && 
                 status.paidAmount === 30 &&
                 status.label.includes('overpaid') &&
                 status.label.includes('10.00');
  
  logTest('5.2: Overpayment → shows overpaid amount', passed, {
    paidAmount: status?.paidAmount,
    label: status?.label
  });
})();

// Test 5.3: Underpayment (partial payment)
(function test_5_3_Underpayment() {
  const student = createMockStudent({
    pricePerClass: 20,
    payments: [createMockPayment('2025-12-06', 15)]
  });
  
  const status = determineClassStatus(student, '2025-12-06', null, '2025-12-10');
  const passed = status !== null && 
                 status.status === 'paid' && // Still marked as paid
                 status.paidAmount === 15 &&
                 !status.label.includes('overpaid');
  
  logTest('5.3: Underpayment → marked paid, shows actual amount', passed, {
    status: status?.status,
    paidAmount: status?.paidAmount,
    label: status?.label
  });
})();

// ========================================
// TEST GROUP 6: Edge Cases
// ========================================
console.log('\n🔵 TEST GROUP 6: Edge Cases\n');

// Test 6.1: No payments at all
(function test_6_1_No_Payments() {
  const student = createMockStudent({
    payments: []
  });
  
  const match = findPaymentMatchForClass(student, '2025-12-06', '2025-12-10');
  const passed = match === null;
  
  logTest('6.1: No payments → no match', passed, {
    match
  });
})();

// Test 6.2: Invalid date string
(function test_6_2_Invalid_Date() {
  const student = createMockStudent({
    payments: [createMockPayment('2025-12-06', 20)]
  });
  
  const match = findPaymentMatchForClass(student, 'invalid-date', '2025-12-10');
  const passed = match === null;
  
  logTest('6.2: Invalid date string → no match', passed, {
    match
  });
})();

// Test 6.3: Zero amount payment (ignored)
(function test_6_3_Zero_Payment() {
  const student = createMockStudent({
    payments: [createMockPayment('2025-12-06', 0)]
  });
  
  const status = determineClassStatus(student, '2025-12-06', null, '2025-12-10');
  const passed = status !== null && status.status !== 'paid';
  
  logTest('6.3: Zero amount payment → not marked paid', passed, {
    status: status?.status,
    paidAmount: status?.paidAmount
  });
})();

// Test 6.4: Null student
(function test_6_4_Null_Student() {
  const status = determineClassStatus(null, '2025-12-06', null, '2025-12-10');
  const passed = status === null;
  
  logTest('6.4: Null student → returns null', passed, {
    status
  });
})();

// Test 6.5: Balance display in unpaid status
(function test_6_5_Balance_Display() {
  const student = createMockStudent({
    balance: 120,
    pricePerClass: 20,
    payments: []
  });
  
  const status = determineClassStatus(student, '2025-12-06', null, '2025-12-10');
  const passed = status !== null && 
                 status.balance === 120 &&
                 status.label.includes('120.00');
  
  logTest('6.5: Balance shown in unpaid label', passed, {
    balance: status?.balance,
    label: status?.label
  });
})();

// ========================================
// TEST GROUP 7: Month Boundary Edge Cases
// ========================================
console.log('\n🔵 TEST GROUP 7: Month Boundary Edge Cases\n');

// Test 7.1: Last day of month
(function test_7_1_Last_Day_Of_Month() {
  const student = createMockStudent({
    payments: [
      createMockPayment('2025-12-31', 20) // Dec 31
    ]
  });
  
  const match = findPaymentMatchForClass(student, '2025-12-15', '2026-01-05');
  const passed = match !== null && match.dateStr === '2025-12-31';
  
  logTest('7.1: Last day of month payment → matches', passed, {
    classDate: '2025-12-15',
    paymentDate: match?.dateStr
  });
})();

// Test 7.2: First day of month
(function test_7_2_First_Day_Of_Month() {
  const student = createMockStudent({
    payments: [
      createMockPayment('2025-12-01', 20) // Dec 1
    ]
  });
  
  const match = findPaymentMatchForClass(student, '2025-12-15', '2025-12-20');
  const passed = match !== null && match.dateStr === '2025-12-01';
  
  logTest('7.2: First day of month payment → matches', passed, {
    classDate: '2025-12-15',
    paymentDate: match?.dateStr
  });
})();

// Test 7.3: Cross-month boundary (no match)
(function test_7_3_Cross_Month_Boundary() {
  const student = createMockStudent({
    payments: [
      createMockPayment('2025-11-30', 20) // Nov 30
    ]
  });
  
  const match = findPaymentMatchForClass(student, '2025-12-01', '2025-12-05');
  const passed = match === null; // Different months = no match
  
  logTest('7.3: Nov 30 → Dec 1 (different months) → no match', passed, {
    classDate: '2025-12-01',
    paymentDate: match?.dateStr,
    expected: null
  });
})();

// Test 7.4: February leap year
(function test_7_4_February_Leap_Year() {
  const student = createMockStudent({
    payments: [
      createMockPayment('2024-02-29', 20) // Feb 29, 2024 (leap year)
    ]
  });
  
  const match = findPaymentMatchForClass(student, '2024-02-15', '2024-03-01');
  const passed = match !== null && match.dateStr === '2024-02-29';
  
  logTest('7.4: Feb 29 leap year → matches Feb class', passed, {
    classDate: '2024-02-15',
    paymentDate: match?.dateStr
  });
})();

// ========================================
// TEST GROUP 8: Real-World Scenarios
// ========================================
console.log('\n🔵 TEST GROUP 8: Real-World Scenarios\n');

// Test 8.1: Student pays once in December, has 4 classes
(function test_8_1_One_Payment_Multiple_Classes() {
  const student = createMockStudent({
    pricePerClass: 20,
    payments: [
      createMockPayment('2025-12-15', 80) // Single payment for whole month
    ]
  });
  
  // Check all 4 classes in December
  const class1 = findPaymentMatchForClass(student, '2025-12-06', '2025-12-31');
  const class2 = findPaymentMatchForClass(student, '2025-12-13', '2025-12-31');
  const class3 = findPaymentMatchForClass(student, '2025-12-20', '2025-12-31');
  const class4 = findPaymentMatchForClass(student, '2025-12-27', '2025-12-31');
  
  const allMatch = class1 && class2 && class3 && class4;
  const passed = allMatch && 
                 class1.dateStr === '2025-12-15' &&
                 class2.dateStr === '2025-12-15' &&
                 class3.dateStr === '2025-12-15' &&
                 class4.dateStr === '2025-12-15';
  
  logTest('8.1: One payment covers all month classes', passed, {
    classes: 4,
    allMatch,
    paymentDate: class1?.dateStr
  });
})();

// Test 8.2: Student pays after class (late payment)
(function test_8_2_Late_Payment() {
  const student = createMockStudent({
    pricePerClass: 20,
    payments: [
      createMockPayment('2025-12-20', 20) // Payment on Dec 20
    ]
  });
  
  const classStatus = determineClassStatus(student, '2025-12-06', null, '2025-12-25');
  const passed = classStatus !== null && 
                 classStatus.status === 'paid' &&
                 classStatus.paymentDate === '2025-12-20';
  
  logTest('8.2: Late payment still covers class (same month)', passed, {
    classDate: '2025-12-06',
    paymentDate: classStatus?.paymentDate,
    status: classStatus?.status
  });
})();

// Test 8.3: Student with high balance, unpaid class
(function test_8_3_High_Balance_Unpaid() {
  const student = createMockStudent({
    pricePerClass: 20,
    balance: 200, // High balance
    payments: [] // But no payment for this class
  });
  
  const status = determineClassStatus(student, '2025-12-06', null, '2025-12-10');
  const passed = status !== null && 
                 status.status === 'unpaid' &&
                 status.balance === 200 &&
                 status.label.includes('200.00');
  
  logTest('8.3: High balance + no payment → still unpaid', passed, {
    status: status?.status,
    balance: status?.balance,
    label: status?.label
  });
})();

// Test 8.4: Multiple students, one class date (isolation)
(function test_8_4_Student_Isolation() {
  const student1 = createMockStudent({
    id: 1,
    name: 'Student 1',
    payments: [createMockPayment('2025-12-06', 20)]
  });
  
  const student2 = createMockStudent({
    id: 2,
    name: 'Student 2',
    payments: [] // No payment
  });
  
  const status1 = determineClassStatus(student1, '2025-12-06', null, '2025-12-10');
  const status2 = determineClassStatus(student2, '2025-12-06', null, '2025-12-10');
  
  const passed = status1.status === 'paid' && status2.status === 'unpaid';
  
  logTest('8.4: Student isolation → independent statuses', passed, {
    student1: status1.status,
    student2: status2.status
  });
})();

// ========================================
// FINAL TEST REPORT
// ========================================
console.log('\n========================================');
console.log('📊 FINAL TEST REPORT');
console.log('========================================\n');

const passRate = (testResults.passed / testResults.total * 100).toFixed(1);
console.log(`Total Tests: ${testResults.total}`);
console.log(`✅ Passed: ${testResults.passed}`);
console.log(`❌ Failed: ${testResults.failed}`);
console.log(`📈 Pass Rate: ${passRate}%\n`);

if (testResults.failed > 0) {
  console.log('❌ FAILED TESTS:\n');
  testResults.tests
    .filter(t => !t.passed)
    .forEach(t => console.log(`  - ${t.name}`, t.details));
} else {
  console.log('✅ ALL TESTS PASSED! 🎉\n');
}

console.log('========================================\n');

// Export results
window.calendarPaymentTestResults = testResults;
