/**
 * ========================================
 * STUDENT PORTAL COMPREHENSIVE TEST SUITE
 * ========================================
 * 
 * Tests ALL major Student Portal features:
 * - Payment calculation & display
 * - Unpaid classes tracking
 * - Credit payment system
 * - Absence tracking
 * - Systems carousel rendering
 * - Payment-locked notes engine
 * - Schedule parsing
 * - Balance calculations
 */

// ==========================================================================
// EMBEDDED STUDENT PORTAL LOGIC (For Testing)
// ==========================================================================

const DEBUG_MODE = false;
const debugLog = (...args) => DEBUG_MODE && console.log(...args);

// Helper: Format date as YYYY-MM-DD from Date object (timezone-safe)
function formatDateYYYYMMDD(date) {
  if (!date) return '';
  const year = date.getFullYear();
  const month = String(date.getMonth() + 1).padStart(2, '0');
  const day = String(date.getDate()).padStart(2, '0');
  return `${year}-${month}-${day}`;
}

// Helper: Create Date from YYYY-MM-DD string (timezone-safe)
function createDateFromDateStr(dateStr) {
  if (!dateStr) return null;
  const parts = dateStr.split('-');
  if (parts.length !== 3) return null;
  return new Date(parseInt(parts[0]), parseInt(parts[1]) - 1, parseInt(parts[2]));
}

// Helper: Get day of week from date string
function getDayOfWeek(dateStr) {
  const date = createDateFromDateStr(dateStr);
  if (!date) return null;
  const days = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];
  return days[date.getDay()];
}

// Helper: Compute class dates for a month
function computeClassDatesForMonth(year, month, daysOfWeek, studentStartDate = null) {
  const classDates = [];
  const daysInMonth = new Date(year, month + 1, 0).getDate();
  
  for (let day = 1; day <= daysInMonth; day++) {
    const date = new Date(year, month, day);
    const dayOfWeek = date.getDay();
    const dayName = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'][dayOfWeek];
    
    if (daysOfWeek.includes(dayName)) {
      const dateStr = formatDateYYYYMMDD(date);
      
      // Skip if before student start date
      if (studentStartDate && date < studentStartDate) {
        continue;
      }
      
      classDates.push(dateStr);
    }
  }
  
  return classDates;
}

// Helper: Check if class date is paid
function isClassDatePaid(dateStr, paymentRecords, creditPayments = []) {
  if (!dateStr) return false;
  
  const classDate = createDateFromDateStr(dateStr);
  if (!classDate) return false;
  
  const classMonth = classDate.getMonth();
  const classYear = classDate.getFullYear();
  
  // Check credit payments first (exact match only)
  if (creditPayments.includes(dateStr)) {
    return true;
  }
  
  // Check payment records (exact date or same month)
  for (const payment of paymentRecords) {
    if (!payment.dateStr) continue;
    
    // Exact date match
    if (payment.dateStr === dateStr) {
      return true;
    }
    
    // Same month match (payment applies to any class in same month)
    const paymentDate = createDateFromDateStr(payment.dateStr);
    if (paymentDate &&
        paymentDate.getMonth() === classMonth &&
        paymentDate.getFullYear() === classYear) {
      return true;
    }
  }
  
  return false;
}

// Calculate unpaid classes and amount
function calculateUnpaidClasses(student, payments, schedule, absences = [], creditPayments = [], skippedDates = [], todayStr = null) {
  const today = todayStr || formatDateYYYYMMDD(new Date());
  const pricePerClass = student.price_per_class !== undefined ? parseFloat(student.price_per_class) : 50;
  
  if (!schedule || !schedule.days || !schedule.days.length) {
    return { unpaidClasses: [], unpaidAmount: 0, totalPastClasses: 0 };
  }
  
  // Get student start date
  let studentStartDate = null;
  if (student.start_date) {
    const parts = student.start_date.split('-');
    if (parts.length === 3) {
      studentStartDate = new Date(parseInt(parts[0]), parseInt(parts[1]) - 1, parseInt(parts[2]));
    }
  }
  
  // Compute all class dates from start date until today
  const allClassDates = [];
  const todayDate = createDateFromDateStr(today);
  const startDate = studentStartDate || new Date(2024, 0, 1); // Default to Jan 1, 2024
  
  let currentDate = new Date(startDate);
  while (currentDate <= todayDate) {
    const year = currentDate.getFullYear();
    const month = currentDate.getMonth();
    const daysInMonth = new Date(year, month + 1, 0).getDate();
    
    // Compute class dates for this month, but only up to today
    for (let day = 1; day <= daysInMonth; day++) {
      const date = new Date(year, month, day);
      const dayOfWeek = date.getDay();
      const dayName = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'][dayOfWeek];
      
      if (schedule.days.includes(dayName)) {
        const dateStr = formatDateYYYYMMDD(date);
        
        // Skip if before student start date
        if (studentStartDate && date < studentStartDate) {
          continue;
        }
        
        // Only include if date is today or in the past
        if (dateStr <= today) {
          allClassDates.push(dateStr);
        }
      }
    }
    
    // Move to next month
    currentDate = new Date(year, month + 1, 1);
  }
  
  // Filter out skipped classes, absences, and paid classes
  const unpaidClasses = allClassDates.filter(dateStr => {
    // Skip if class was canceled/skipped
    if (skippedDates.includes(dateStr)) return false;
    
    // Skip if student was absent
    if (absences.includes(dateStr)) return false;
    
    // Include if NOT paid
    return !isClassDatePaid(dateStr, payments, creditPayments);
  });
  
  const unpaidAmount = unpaidClasses.length * pricePerClass;
  
  return {
    unpaidClasses,
    unpaidAmount,
    totalPastClasses: allClassDates.length
  };
}

// Calculate payment summary
function calculatePaymentSummary(student, payments, unpaidInfo) {
  const totalPaid = payments.reduce((sum, p) => sum + (parseFloat(p.amount) || 0), 0);
  const balance = parseFloat(student.balance) || 0;
  const unpaidAmount = unpaidInfo.unpaidAmount || 0;
  
  return {
    totalPaid,
    balance,
    unpaidAmount,
    paidClasses: unpaidInfo.totalPastClasses - unpaidInfo.unpaidClasses.length,
    unpaidClasses: unpaidInfo.unpaidClasses.length,
    totalClasses: unpaidInfo.totalPastClasses
  };
}

// Render systems carousel (simplified for testing)
function renderSystemsCarousel(systems, selectedSystem = null) {
  if (!systems || systems.length === 0) {
    return { cards: [], error: 'No systems configured' };
  }
  
  // Check for duplicates
  const systemNames = systems.map(s => s.name);
  const uniqueNames = new Set(systemNames);
  if (systemNames.length !== uniqueNames.size) {
    const duplicates = systemNames.filter((name, index) => systemNames.indexOf(name) !== index);
    return { cards: [], error: 'Duplicate systems detected', duplicates: [...new Set(duplicates)] };
  }
  
  const cards = systems.map(system => ({
    name: system.name,
    status: system.status || 'not-started',
    progress: Math.max(0, Math.min(100, system.progress || 0)),
    selected: selectedSystem === system.name,
    totalNotes: system.totalNotes || 0
  }));
  
  return { cards, error: null };
}

// Parse schedule string
function parseScheduleString(scheduleStr) {
  if (!scheduleStr) return { days: [], time: null };
  
  const daysOfWeek = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];
  const days = [];
  
  // Extract days
  daysOfWeek.forEach(day => {
    const shortDay = day.substring(0, 3); // Mon, Tue, Wed, etc.
    if (scheduleStr.includes(day) || scheduleStr.includes(shortDay)) {
      days.push(day);
    }
  });
  
  // Extract time
  const timeMatch = scheduleStr.match(/(\d{1,2}):(\d{2})\s*(AM|PM)/i);
  let time = null;
  if (timeMatch) {
    time = timeMatch[0]; // "7:00 PM"
  }
  
  return { days, time };
}

// Payment-locked notes: Check if note should be unlocked
function shouldUnlockNote(note, student, paymentRecords, scheduleData, creditPayments = []) {
  // Free notes are always unlocked
  if (!note.requires_payment) {
    return { unlocked: true, reason: 'free-note' };
  }
  
  // Map note to class date
  const classDate = note.class_date || note.upload_date;
  if (!classDate) {
    return { unlocked: false, reason: 'no-date' };
  }
  
  const dateStr = classDate.substring(0, 10); // YYYY-MM-DD
  
  // Check if paid
  const isPaid = isClassDatePaid(dateStr, paymentRecords, creditPayments);
  
  return {
    unlocked: isPaid,
    reason: isPaid ? 'paid' : 'unpaid',
    classDate: dateStr
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
    price_per_class: options.pricePerClass !== undefined ? options.pricePerClass : 20,
    group_letter: options.group || 'A',
    start_date: options.startDate || '2025-12-01',
  };
}

// Helper to create mock payment
function createMockPayment(dateStr, amount) {
  return {
    dateStr,
    amount: Number(amount),
    date: dateStr,
  };
}

// ========================================
// TEST GROUP 1: Payment Calculation
// ========================================
console.log('\n🔵 TEST GROUP 1: Payment Calculation\n');

// Test 1.1: Total paid calculation
(function test_1_1_Total_Paid() {
  const student = createMockStudent();
  const payments = [
    createMockPayment('2025-12-01', 20),
    createMockPayment('2025-12-08', 20),
    createMockPayment('2025-12-15', 20),
  ];
  const unpaidInfo = { unpaidAmount: 0, unpaidClasses: [], totalPastClasses: 3 };
  
  const summary = calculatePaymentSummary(student, payments, unpaidInfo);
  const passed = summary.totalPaid === 60;
  
  logTest('1.1: Total paid calculation', passed, {
    totalPaid: summary.totalPaid,
    expected: 60
  });
})();

// Test 1.2: Balance tracking
(function test_1_2_Balance_Tracking() {
  const student = createMockStudent({ balance: 120 });
  const payments = [createMockPayment('2025-12-01', 20)];
  const unpaidInfo = { unpaidAmount: 40, unpaidClasses: ['2025-12-08', '2025-12-15'], totalPastClasses: 3 };
  
  const summary = calculatePaymentSummary(student, payments, unpaidInfo);
  const passed = summary.balance === 120 && summary.unpaidAmount === 40;
  
  logTest('1.2: Balance and unpaid tracking', passed, {
    balance: summary.balance,
    unpaidAmount: summary.unpaidAmount
  });
})();

// Test 1.3: Paid vs unpaid classes count
(function test_1_3_Class_Counts() {
  const student = createMockStudent();
  const payments = [createMockPayment('2025-12-01', 20)];
  const unpaidInfo = { unpaidAmount: 40, unpaidClasses: ['2025-12-08', '2025-12-15'], totalPastClasses: 3 };
  
  const summary = calculatePaymentSummary(student, payments, unpaidInfo);
  const passed = summary.paidClasses === 1 && summary.unpaidClasses === 2 && summary.totalClasses === 3;
  
  logTest('1.3: Paid vs unpaid class counts', passed, {
    paidClasses: summary.paidClasses,
    unpaidClasses: summary.unpaidClasses,
    totalClasses: summary.totalClasses
  });
})();

// ========================================
// TEST GROUP 2: Unpaid Classes Calculation
// ========================================
console.log('\n🔵 TEST GROUP 2: Unpaid Classes Calculation\n');

// Test 2.1: Basic unpaid calculation
(function test_2_1_Basic_Unpaid() {
  const student = createMockStudent({
    pricePerClass: 20,
    startDate: '2025-12-01'
  });
  const schedule = { days: ['Monday', 'Wednesday', 'Friday'], time: '7:00 PM' };
  const payments = [createMockPayment('2025-11-15', 20)]; // Payment in NOVEMBER (different month)
  
  const result = calculateUnpaidClasses(student, payments, schedule, [], [], [], '2025-12-10');
  
  // Mon: 1, 8 | Wed: 3, 10 | Fri: 5 = 5 classes, NO December payment = 5 unpaid
  const passed = result.unpaidClasses.length === 5 && result.unpaidAmount === 100;
  
  logTest('2.1: Basic unpaid class calculation', passed, {
    unpaidClasses: result.unpaidClasses.length,
    unpaidAmount: result.unpaidAmount,
    totalClasses: result.totalPastClasses
  });
})();

// Test 2.2: Absences excluded from unpaid
(function test_2_2_Absences_Excluded() {
  const student = createMockStudent({ startDate: '2025-12-01' });
  const schedule = { days: ['Monday', 'Wednesday'], time: '7:00 PM' };
  const payments = [];
  const absences = ['2025-12-03']; // Absent on Wed Dec 3
  
  const result = calculateUnpaidClasses(student, payments, schedule, absences, [], [], '2025-12-10');
  
  // Mon: 1, 8 | Wed: 3(absent), 10 = 4 classes, 1 absent = 3 unpaid
  const passed = result.unpaidClasses.length === 3 && !result.unpaidClasses.includes('2025-12-03');
  
  logTest('2.2: Absences excluded from unpaid count', passed, {
    unpaidClasses: result.unpaidClasses,
    absences
  });
})();

// Test 2.3: Skipped classes excluded
(function test_2_3_Skipped_Excluded() {
  const student = createMockStudent({ startDate: '2025-12-01' });
  const schedule = { days: ['Monday', 'Wednesday'], time: '7:00 PM' };
  const payments = [];
  const skipped = ['2025-12-03']; // Class canceled on Wed Dec 3
  
  const result = calculateUnpaidClasses(student, payments, schedule, [], [], skipped, '2025-12-10');
  
  // Mon: 1, 8 | Wed: 3(skipped), 10 = 4 classes, 1 skipped = 3 unpaid
  const passed = result.unpaidClasses.length === 3 && !result.unpaidClasses.includes('2025-12-03');
  
  logTest('2.3: Skipped classes excluded from unpaid count', passed, {
    unpaidClasses: result.unpaidClasses,
    skipped
  });
})();

// Test 2.4: Student start date respected
(function test_2_4_Start_Date() {
  const student = createMockStudent({ startDate: '2025-12-08' }); // Started Dec 8 (Monday)
  const schedule = { days: ['Monday', 'Wednesday'], time: '7:00 PM' };
  const payments = [];
  
  const result = calculateUnpaidClasses(student, payments, schedule, [], [], [], '2025-12-10');
  
  // Only Dec 8 (Mon), 10 (Wed) should count (Dec 1, 3 are before start date)
  const passed = result.unpaidClasses.length === 2 && 
                 result.unpaidClasses.includes('2025-12-08') &&
                 result.unpaidClasses.includes('2025-12-10');
  
  logTest('2.4: Classes before start date excluded', passed, {
    startDate: student.start_date,
    unpaidClasses: result.unpaidClasses
  });
})();

// Test 2.5: Same month payment covers all classes
(function test_2_5_Same_Month_Coverage() {
  const student = createMockStudent({ startDate: '2025-12-01' });
  const schedule = { days: ['Monday', 'Wednesday'], time: '7:00 PM' };
  const payments = [createMockPayment('2025-12-15', 80)]; // One payment on Dec 15
  
  const result = calculateUnpaidClasses(student, payments, schedule, [], [], [], '2025-12-10');
  
  // All December classes should be marked as paid (same month matching)
  const passed = result.unpaidClasses.length === 0;
  
  logTest('2.5: Same month payment covers all December classes', passed, {
    unpaidClasses: result.unpaidClasses.length,
    paymentDate: '2025-12-15'
  });
})();

// ========================================
// TEST GROUP 3: Credit Payment System
// ========================================
console.log('\n🔵 TEST GROUP 3: Credit Payment System\n');

// Test 3.1: Credit payment marks class as paid
(function test_3_1_Credit_Payment() {
  const dateStr = '2025-12-06';
  const payments = [];
  const creditPayments = ['2025-12-06'];
  
  const isPaid = isClassDatePaid(dateStr, payments, creditPayments);
  const passed = isPaid === true;
  
  logTest('3.1: Credit payment marks class as paid', passed, {
    dateStr,
    isPaid
  });
})();

// Test 3.2: Credit payment in unpaid calculation
(function test_3_2_Credit_In_Unpaid_Calc() {
  const student = createMockStudent({ startDate: '2025-12-01' });
  const schedule = { days: ['Monday', 'Wednesday'], time: '7:00 PM' };
  const payments = [];
  const creditPayments = ['2025-12-01']; // Paid via credit on Dec 1 (Monday)
  
  const result = calculateUnpaidClasses(student, payments, schedule, [], creditPayments, [], '2025-12-10');
  
  // Mon: 1(credit), 8 | Wed: 3, 10 = 4 classes, 1 credit = 3 unpaid
  const passed = result.unpaidClasses.length === 3 && !result.unpaidClasses.includes('2025-12-01');
  
  logTest('3.2: Credit payment excluded from unpaid', passed, {
    unpaidClasses: result.unpaidClasses,
    creditPayments
  });
})();

// Test 3.3: Multiple credit payments
(function test_3_3_Multiple_Credits() {
  const student = createMockStudent({ startDate: '2025-12-01' });
  const schedule = { days: ['Monday', 'Wednesday'], time: '7:00 PM' };
  const payments = [];
  const creditPayments = ['2025-12-01', '2025-12-03', '2025-12-08'];
  
  const result = calculateUnpaidClasses(student, payments, schedule, [], creditPayments, [], '2025-12-10');
  
  // Mon: 1(credit), 8(credit) | Wed: 3(credit), 10 = 4 classes, 3 credit = 1 unpaid
  const passed = result.unpaidClasses.length === 1 && result.unpaidClasses[0] === '2025-12-10';
  
  logTest('3.3: Multiple credit payments work correctly', passed, {
    unpaidClasses: result.unpaidClasses.length,
    creditPayments: creditPayments.length
  });
})();

// ========================================
// TEST GROUP 4: Absence Tracking
// ========================================
console.log('\n🔵 TEST GROUP 4: Absence Tracking\n');

// Test 4.1: Single absence
(function test_4_1_Single_Absence() {
  const student = createMockStudent({ startDate: '2025-12-01' });
  const schedule = { days: ['Monday'], time: '7:00 PM' };
  const payments = [];
  const absences = ['2025-12-08']; // Absent on Dec 8 (Monday)
  
  const result = calculateUnpaidClasses(student, payments, schedule, absences, [], [], '2025-12-10');
  
  // Mon: 1, 8(absent) = 2 classes, 1 absent = 1 unpaid
  const passed = result.unpaidClasses.length === 1 && result.unpaidClasses[0] === '2025-12-01';
  
  logTest('4.1: Single absence correctly excluded', passed, {
    unpaidClasses: result.unpaidClasses,
    absences
  });
})();

// Test 4.2: Multiple absences
(function test_4_2_Multiple_Absences() {
  const student = createMockStudent({ startDate: '2025-12-01' });
  const schedule = { days: ['Monday', 'Wednesday'], time: '7:00 PM' };
  const payments = [];
  const absences = ['2025-12-01', '2025-12-03', '2025-12-08'];
  
  const result = calculateUnpaidClasses(student, payments, schedule, absences, [], [], '2025-12-10');
  
  // Mon: 1(absent), 8(absent) | Wed: 3(absent), 10 = 4 classes, 3 absent = 1 unpaid
  const passed = result.unpaidClasses.length === 1 && result.unpaidClasses[0] === '2025-12-10';
  
  logTest('4.2: Multiple absences correctly excluded', passed, {
    unpaidClasses: result.unpaidClasses.length,
    absences: absences.length
  });
})();

// Test 4.3: Absence + payment combination
(function test_4_3_Absence_Payment_Combo() {
  const student = createMockStudent({ startDate: '2025-12-01' });
  const schedule = { days: ['Monday', 'Wednesday'], time: '7:00 PM' };
  const payments = [createMockPayment('2025-11-20', 20)]; // Payment in NOVEMBER (doesn't cover December)
  const absences = ['2025-12-03'];
  
  const result = calculateUnpaidClasses(student, payments, schedule, absences, [], [], '2025-12-10');
  
  // Mon: 1, 8 | Wed: 3(absent), 10 = 4 classes, 0 paid (Nov payment), 1 absent = 3 unpaid
  const passed = result.unpaidClasses.length === 3 && 
                 result.unpaidClasses.includes('2025-12-01') &&
                 result.unpaidClasses.includes('2025-12-08') &&
                 result.unpaidClasses.includes('2025-12-10');
  
  logTest('4.3: Absence + payment combination works', passed, {
    unpaidClasses: result.unpaidClasses,
    paidClasses: 0,
    absences: 1
  });
})();

// ========================================
// TEST GROUP 5: Systems Carousel
// ========================================
console.log('\n🔵 TEST GROUP 5: Systems Carousel\n');

// Test 5.1: Basic carousel rendering
(function test_5_1_Basic_Carousel() {
  const systems = [
    { name: 'Cardiovascular', status: 'in-progress', progress: 45, totalNotes: 12 },
    { name: 'Respiratory', status: 'not-started', progress: 0, totalNotes: 8 },
    { name: 'Neurological', status: 'completed', progress: 100, totalNotes: 15 }
  ];
  
  const result = renderSystemsCarousel(systems);
  const passed = result.cards.length === 3 && result.error === null;
  
  logTest('5.1: Basic carousel rendering', passed, {
    cardsCount: result.cards.length,
    error: result.error
  });
})();

// Test 5.2: No systems (empty state)
(function test_5_2_Empty_Carousel() {
  const systems = [];
  
  const result = renderSystemsCarousel(systems);
  const passed = result.cards.length === 0 && result.error === 'No systems configured';
  
  logTest('5.2: Empty carousel shows error message', passed, {
    error: result.error
  });
})();

// Test 5.3: Duplicate detection
(function test_5_3_Duplicate_Detection() {
  const systems = [
    { name: 'Cardiovascular', status: 'in-progress', progress: 45 },
    { name: 'Respiratory', status: 'not-started', progress: 0 },
    { name: 'Cardiovascular', status: 'completed', progress: 100 } // Duplicate!
  ];
  
  const result = renderSystemsCarousel(systems);
  const passed = result.error === 'Duplicate systems detected' && 
                 result.duplicates.includes('Cardiovascular');
  
  logTest('5.3: Duplicate systems detected', passed, {
    error: result.error,
    duplicates: result.duplicates
  });
})();

// Test 5.4: Selected system highlighting
(function test_5_4_Selected_System() {
  const systems = [
    { name: 'Cardiovascular', status: 'in-progress', progress: 45 },
    { name: 'Respiratory', status: 'not-started', progress: 0 }
  ];
  
  const result = renderSystemsCarousel(systems, 'Cardiovascular');
  const selectedCard = result.cards.find(c => c.selected);
  const passed = selectedCard && selectedCard.name === 'Cardiovascular';
  
  logTest('5.4: Selected system highlighted', passed, {
    selectedSystem: selectedCard?.name
  });
})();

// Test 5.5: Progress clamping (0-100)
(function test_5_5_Progress_Clamping() {
  const systems = [
    { name: 'System1', progress: -10 },
    { name: 'System2', progress: 150 },
    { name: 'System3', progress: 50 }
  ];
  
  const result = renderSystemsCarousel(systems);
  const passed = result.cards[0].progress === 0 && 
                 result.cards[1].progress === 100 &&
                 result.cards[2].progress === 50;
  
  logTest('5.5: Progress values clamped to 0-100', passed, {
    progress1: result.cards[0].progress,
    progress2: result.cards[1].progress,
    progress3: result.cards[2].progress
  });
})();

// ========================================
// TEST GROUP 6: Schedule Parsing
// ========================================
console.log('\n🔵 TEST GROUP 6: Schedule Parsing\n');

// Test 6.1: Full day names with time
(function test_6_1_Full_Day_Names() {
  const scheduleStr = 'Monday, Wednesday, Friday at 7:00 PM';
  const parsed = parseScheduleString(scheduleStr);
  
  const passed = parsed.days.length === 3 &&
                 parsed.days.includes('Monday') &&
                 parsed.days.includes('Wednesday') &&
                 parsed.days.includes('Friday') &&
                 parsed.time === '7:00 PM';
  
  logTest('6.1: Full day names parsed correctly', passed, {
    days: parsed.days,
    time: parsed.time
  });
})();

// Test 6.2: Abbreviated day names
(function test_6_2_Abbreviated_Days() {
  const scheduleStr = 'Tue, Thu 6:30 PM';
  const parsed = parseScheduleString(scheduleStr);
  
  const passed = parsed.days.length === 2 &&
                 parsed.days.includes('Tuesday') &&
                 parsed.days.includes('Thursday') &&
                 parsed.time === '6:30 PM';
  
  logTest('6.2: Abbreviated day names parsed correctly', passed, {
    days: parsed.days,
    time: parsed.time
  });
})();

// Test 6.3: AM time parsing
(function test_6_3_AM_Time() {
  const scheduleStr = 'Monday at 10:30 AM';
  const parsed = parseScheduleString(scheduleStr);
  
  const passed = parsed.days.includes('Monday') && parsed.time === '10:30 AM';
  
  logTest('6.3: AM time parsed correctly', passed, {
    time: parsed.time
  });
})();

// Test 6.4: Empty schedule string
(function test_6_4_Empty_Schedule() {
  const parsed = parseScheduleString('');
  
  const passed = parsed.days.length === 0 && parsed.time === null;
  
  logTest('6.4: Empty schedule handled gracefully', passed, {
    days: parsed.days,
    time: parsed.time
  });
})();

// ========================================
// TEST GROUP 7: Payment-Locked Notes Engine
// ========================================
console.log('\n🔵 TEST GROUP 7: Payment-Locked Notes Engine\n');

// Test 7.1: Free note always unlocked
(function test_7_1_Free_Note() {
  const note = {
    name: 'Free Note',
    requires_payment: false,
    class_date: '2025-12-06'
  };
  const student = createMockStudent();
  const payments = [];
  
  const result = shouldUnlockNote(note, student, payments, null, []);
  const passed = result.unlocked === true && result.reason === 'free-note';
  
  logTest('7.1: Free note always unlocked', passed, {
    unlocked: result.unlocked,
    reason: result.reason
  });
})();

// Test 7.2: Paid note unlocked
(function test_7_2_Paid_Note() {
  const note = {
    name: 'Paid Note',
    requires_payment: true,
    class_date: '2025-12-06'
  };
  const student = createMockStudent();
  const payments = [createMockPayment('2025-12-06', 20)];
  
  const result = shouldUnlockNote(note, student, payments, null, []);
  const passed = result.unlocked === true && result.reason === 'paid';
  
  logTest('7.2: Paid note unlocked', passed, {
    unlocked: result.unlocked,
    reason: result.reason
  });
})();

// Test 7.3: Unpaid note locked
(function test_7_3_Unpaid_Note() {
  const note = {
    name: 'Unpaid Note',
    requires_payment: true,
    class_date: '2025-12-06'
  };
  const student = createMockStudent();
  const payments = [];
  
  const result = shouldUnlockNote(note, student, payments, null, []);
  const passed = result.unlocked === false && result.reason === 'unpaid';
  
  logTest('7.3: Unpaid note locked', passed, {
    unlocked: result.unlocked,
    reason: result.reason
  });
})();

// Test 7.4: Same month payment unlocks note
(function test_7_4_Same_Month_Unlock() {
  const note = {
    name: 'December Note',
    requires_payment: true,
    class_date: '2025-12-06'
  };
  const student = createMockStudent();
  const payments = [createMockPayment('2025-12-15', 20)]; // Payment later in month
  
  const result = shouldUnlockNote(note, student, payments, null, []);
  const passed = result.unlocked === true && result.reason === 'paid';
  
  logTest('7.4: Same month payment unlocks note', passed, {
    unlocked: result.unlocked,
    noteDate: '2025-12-06',
    paymentDate: '2025-12-15'
  });
})();

// Test 7.5: Credit payment unlocks note
(function test_7_5_Credit_Unlock() {
  const note = {
    name: 'Credit Note',
    requires_payment: true,
    class_date: '2025-12-06'
  };
  const student = createMockStudent();
  const payments = [];
  const creditPayments = ['2025-12-06'];
  
  const result = shouldUnlockNote(note, student, payments, null, creditPayments);
  const passed = result.unlocked === true && result.reason === 'paid';
  
  logTest('7.5: Credit payment unlocks note', passed, {
    unlocked: result.unlocked,
    reason: result.reason
  });
})();

// Test 7.6: Note without date
(function test_7_6_No_Date_Note() {
  const note = {
    name: 'No Date Note',
    requires_payment: true,
    class_date: null
  };
  const student = createMockStudent();
  const payments = [];
  
  const result = shouldUnlockNote(note, student, payments, null, []);
  const passed = result.unlocked === false && result.reason === 'no-date';
  
  logTest('7.6: Note without date locked', passed, {
    unlocked: result.unlocked,
    reason: result.reason
  });
})();

// ========================================
// TEST GROUP 8: Date Helper Functions
// ========================================
console.log('\n🔵 TEST GROUP 8: Date Helper Functions\n');

// Test 8.1: Format date (timezone-safe)
(function test_8_1_Format_Date() {
  const date = new Date(2025, 11, 6); // Dec 6, 2025
  const formatted = formatDateYYYYMMDD(date);
  
  const passed = formatted === '2025-12-06';
  
  logTest('8.1: Date formatting (timezone-safe)', passed, {
    formatted,
    expected: '2025-12-06'
  });
})();

// Test 8.2: Create date from string
(function test_8_2_Create_Date() {
  const dateStr = '2025-12-06';
  const date = createDateFromDateStr(dateStr);
  
  const passed = date !== null &&
                 date.getFullYear() === 2025 &&
                 date.getMonth() === 11 && // December (0-indexed)
                 date.getDate() === 6;
  
  logTest('8.2: Create date from string (timezone-safe)', passed, {
    year: date?.getFullYear(),
    month: date?.getMonth(),
    day: date?.getDate()
  });
})();

// Test 8.3: Get day of week
(function test_8_3_Day_Of_Week() {
  const dateStr = '2025-12-08'; // Monday
  const day = getDayOfWeek(dateStr);
  
  const passed = day === 'Monday';
  
  logTest('8.3: Get day of week from date string', passed, {
    dateStr,
    day,
    expected: 'Monday'
  });
})();

// Test 8.4: Compute class dates for month
(function test_8_4_Compute_Class_Dates() {
  const year = 2025;
  const month = 11; // December
  const daysOfWeek = ['Monday', 'Wednesday'];
  
  const dates = computeClassDatesForMonth(year, month, daysOfWeek);
  
  // December 2025: Mon = 1, 8, 15, 22, 29 | Wed = 3, 10, 17, 24, 31
  const passed = dates.length === 10 &&
                 dates.includes('2025-12-01') &&
                 dates.includes('2025-12-03') &&
                 dates.includes('2025-12-31');
  
  logTest('8.4: Compute class dates for month', passed, {
    datesCount: dates.length,
    firstDate: dates[0],
    lastDate: dates[dates.length - 1]
  });
})();

// ========================================
// TEST GROUP 9: Edge Cases & Integration
// ========================================
console.log('\n🔵 TEST GROUP 9: Edge Cases & Integration\n');

// Test 9.1: Student with no schedule
(function test_9_1_No_Schedule() {
  const student = createMockStudent();
  const payments = [];
  const schedule = null;
  
  const result = calculateUnpaidClasses(student, payments, schedule);
  const passed = result.unpaidClasses.length === 0 && result.unpaidAmount === 0;
  
  logTest('9.1: Student with no schedule handled', passed, {
    unpaidClasses: result.unpaidClasses.length
  });
})();

// Test 9.2: Complex scenario (all features)
(function test_9_2_Complex_Scenario() {
  const student = createMockStudent({
    pricePerClass: 25,
    balance: 150,
    startDate: '2025-12-01'
  });
  const schedule = { days: ['Monday', 'Wednesday', 'Friday'], time: '7:00 PM' };
  const payments = [
    createMockPayment('2025-12-02', 25), // Mon Dec 2
    createMockPayment('2025-12-15', 25), // Covers all December (same month)
  ];
  const absences = ['2025-12-04']; // Absent Wed Dec 4
  const creditPayments = ['2025-12-09']; // Credit Mon Dec 9
  const skipped = ['2025-12-06']; // Canceled Fri Dec 6
  
  const result = calculateUnpaidClasses(student, payments, schedule, absences, creditPayments, skipped, '2025-12-10');
  
  // Dec: 2(paid), 4(absent), 6(skipped), 9(credit) = 4 classes, all accounted for = 0 unpaid
  const passed = result.unpaidClasses.length === 0;
  
  logTest('9.2: Complex scenario (all features combined)', passed, {
    unpaidClasses: result.unpaidClasses.length,
    totalClasses: result.totalPastClasses,
    payments: payments.length,
    absences: absences.length,
    credits: creditPayments.length,
    skipped: skipped.length
  });
})();

// Test 9.3: Future classes not counted as unpaid
(function test_9_3_Future_Classes() {
  const student = createMockStudent({ startDate: '2025-12-01' });
  const schedule = { days: ['Monday', 'Wednesday'], time: '7:00 PM' };
  const payments = [];
  
  const result = calculateUnpaidClasses(student, payments, schedule, [], [], [], '2025-12-05');
  
  // Only Dec 2, 4 should count (Dec 9+ are future)
  const passed = result.totalPastClasses === 2 && result.unpaidClasses.length === 2;
  
  logTest('9.3: Future classes not counted', passed, {
    totalPastClasses: result.totalPastClasses,
    unpaidClasses: result.unpaidClasses.length
  });
})();

// Test 9.4: High balance calculation
(function test_9_4_High_Balance() {
  const student = createMockStudent({ balance: 500, pricePerClass: 20 });
  const payments = [
    createMockPayment('2025-12-01', 100),
    createMockPayment('2025-12-08', 200)
  ];
  const unpaidInfo = { unpaidAmount: 60, unpaidClasses: ['2025-12-15', '2025-12-22', '2025-12-29'], totalPastClasses: 6 };
  
  const summary = calculatePaymentSummary(student, payments, unpaidInfo);
  const passed = summary.totalPaid === 300 &&
                 summary.balance === 500 &&
                 summary.unpaidAmount === 60;
  
  logTest('9.4: High balance and payments tracked correctly', passed, {
    totalPaid: summary.totalPaid,
    balance: summary.balance,
    unpaidAmount: summary.unpaidAmount
  });
})();

// Test 9.5: Zero price per class
(function test_9_5_Zero_Price() {
  const student = createMockStudent({ pricePerClass: 0, startDate: '2025-12-01' });
  const schedule = { days: ['Monday'], time: '7:00 PM' };
  const payments = [];
  
  const result = calculateUnpaidClasses(student, payments, schedule, [], [], [], '2025-12-10');
  
  // 2 unpaid classes * $0 = $0
  const passed = result.unpaidAmount === 0 && result.unpaidClasses.length > 0;
  
  logTest('9.5: Zero price per class handled', passed, {
    unpaidAmount: result.unpaidAmount,
    unpaidClasses: result.unpaidClasses.length
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
window.studentPortalTestResults = testResults;
