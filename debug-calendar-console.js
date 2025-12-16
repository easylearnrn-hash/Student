// ═══════════════════════════════════════════════════════════════
// CALENDAR PAYMENT MATCHING DEBUGGER
// Paste this in Browser Console (F12) while viewing Calendar.html
// ═══════════════════════════════════════════════════════════════

(async function debugDecemberPayments() {
  console.log('🔍 DEBUGGING DECEMBER 1-15 PAYMENT MATCHING');
  console.log('═══════════════════════════════════════════════════\n');

  // Get all payments from Supabase
  const { data: payments, error: paymentsError } = await window.supabase
    .from('payments')
    .select('*')
    .gte('date', '2025-12-01')
    .lt('date', '2025-12-16')
    .order('for_class', { ascending: true });

  if (paymentsError) {
    console.error('❌ Error fetching payments:', paymentsError);
    return;
  }

  // Get all students
  const { data: students, error: studentsError } = await window.supabase
    .from('students')
    .select('*')
    .eq('show_in_grid', true);

  if (studentsError) {
    console.error('❌ Error fetching students:', studentsError);
    return;
  }

  console.log(`📊 Total Payments Dec 1-15: ${payments.length}`);
  console.log(`👥 Total Active Students: ${students.length}\n`);

  // Create student lookup
  const studentMap = {};
  students.forEach(s => {
    studentMap[s.id] = s;
  });

  // Helper: Get day of week (0=Sun, 1=Mon, etc.)
  function getDayOfWeek(dateStr) {
    return new Date(dateStr + 'T12:00:00').getDay();
  }

  // Helper: Check if student has class on this day
  function hasClassOnDay(student, dateStr) {
    const dow = getDayOfWeek(dateStr);
    const scheduleMap = {
      'A': [1, 3, 5],  // Mon, Wed, Fri
      'B': [2, 4, 6],  // Tue, Thu, Sat
      'C': [0],        // Sunday
      'D': [1, 3, 5],  // Mon, Wed, Fri
      'E': [2, 4],     // Tue, Thu
      'F': [6]         // Saturday
    };
    const schedule = scheduleMap[student.group_letter] || [];
    return schedule.includes(dow);
  }

  // ═══════════════════════════════════════════════════════════════
  // ANALYSIS 1: All Payments Breakdown
  // ═══════════════════════════════════════════════════════════════
  console.log('📋 ANALYSIS 1: ALL PAYMENTS BREAKDOWN');
  console.log('─────────────────────────────────────────────────────');
  
  const linked = payments.filter(p => p.student_id !== null);
  const unlinked = payments.filter(p => p.student_id === null);
  
  console.log(`✅ Linked to students: ${linked.length}`);
  console.log(`❌ Unlinked (NULL student_id): ${unlinked.length}\n`);

  if (unlinked.length > 0) {
    console.log('🔴 UNLINKED PAYMENTS (Type A Fuchsia):');
    unlinked.forEach(p => {
      console.log(`  • ${p.for_class} - $${p.amount} from "${p.payer_name || p.resolved_student_name}"`);
    });
    console.log('');
  }

  // ═══════════════════════════════════════════════════════════════
  // ANALYSIS 2: Date Mismatches (for_class != receipt date)
  // ═══════════════════════════════════════════════════════════════
  console.log('📋 ANALYSIS 2: DATE MISMATCHES');
  console.log('─────────────────────────────────────────────────────');
  
  const mismatches = linked.filter(p => {
    const receiptDate = p.date.split('T')[0];
    return p.for_class !== receiptDate;
  });

  console.log(`⚠️ Reassigned payments (for_class ≠ receipt date): ${mismatches.length}\n`);
  
  if (mismatches.length > 0) {
    console.log('List of mismatches:');
    mismatches.forEach(p => {
      const student = studentMap[p.student_id];
      const receiptDate = p.date.split('T')[0];
      const diff = Math.round((new Date(p.for_class) - new Date(receiptDate)) / (1000 * 60 * 60 * 24));
      console.log(`  • ${student?.name || 'Unknown'}`);
      console.log(`    Receipt: ${receiptDate} → for_class: ${p.for_class} (${diff > 0 ? '+' : ''}${diff} days)`);
      console.log(`    Amount: $${p.amount}, Reassigned: ${p.is_reassigned ? 'YES' : 'NO'}\n`);
    });
  }

  // ═══════════════════════════════════════════════════════════════
  // ANALYSIS 3: Duplicate Payments (same student_id + for_class)
  // ═══════════════════════════════════════════════════════════════
  console.log('📋 ANALYSIS 3: DUPLICATE PAYMENTS');
  console.log('─────────────────────────────────────────────────────');
  
  const duplicateMap = {};
  linked.forEach(p => {
    const key = `${p.student_id}|${p.for_class}`;
    if (!duplicateMap[key]) {
      duplicateMap[key] = [];
    }
    duplicateMap[key].push(p);
  });

  const duplicates = Object.values(duplicateMap).filter(arr => arr.length > 1);
  console.log(`🟡 Duplicate payments found: ${duplicates.length}\n`);

  if (duplicates.length > 0) {
    console.log('⚠️ Calendar should show YELLOW ERROR dots for these:');
    duplicates.forEach(dups => {
      const student = studentMap[dups[0].student_id];
      console.log(`  • ${student?.name || 'Unknown'} on ${dups[0].for_class}:`);
      dups.forEach(p => {
        console.log(`    - Payment ID: ${p.id}, Amount: $${p.amount}`);
      });
      console.log('');
    });
  }

  // ═══════════════════════════════════════════════════════════════
  // ANALYSIS 4: Payments for Non-Class Days
  // ═══════════════════════════════════════════════════════════════
  console.log('📋 ANALYSIS 4: PAYMENTS FOR NON-CLASS DAYS');
  console.log('─────────────────────────────────────────────────────');
  
  const nonClassDays = linked.filter(p => {
    const student = studentMap[p.student_id];
    if (!student) return false;
    return !hasClassOnDay(student, p.for_class);
  });

  console.log(`🟣 Payments on non-class days: ${nonClassDays.length}\n`);

  if (nonClassDays.length > 0) {
    console.log('⚠️ Calendar should show FUCHSIA Type B dots for these:');
    nonClassDays.forEach(p => {
      const student = studentMap[p.student_id];
      const dow = getDayOfWeek(p.for_class);
      const days = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
      console.log(`  • ${student.name} (Group ${student.group_letter})`);
      console.log(`    Payment for: ${p.for_class} (${days[dow]})`);
      console.log(`    Amount: $${p.amount}`);
      console.log(`    Problem: Group ${student.group_letter} doesn't have class on ${days[dow]}\n`);
    });
  }

  // ═══════════════════════════════════════════════════════════════
  // ANALYSIS 5: Calendar Matching Simulation
  // ═══════════════════════════════════════════════════════════════
  console.log('📋 ANALYSIS 5: CALENDAR MATCHING SIMULATION');
  console.log('─────────────────────────────────────────────────────');
  console.log('Testing payment matching logic for Dec 1-15...\n');

  // Build payment index (like Calendar does)
  const paymentIndex = {};
  linked.forEach(p => {
    if (!paymentIndex[p.student_id]) {
      paymentIndex[p.student_id] = {};
    }
    const dateKey = p.for_class;
    
    // Check for duplicate
    if (paymentIndex[p.student_id][dateKey]) {
      console.warn(`⚠️ DUPLICATE FOUND: Student ${studentMap[p.student_id]?.name} has multiple payments for ${dateKey}`);
    }
    
    paymentIndex[p.student_id][dateKey] = p;
  });

  // Test each student on each Dec 1-15 date
  const testDates = [];
  for (let day = 1; day <= 15; day++) {
    testDates.push(`2025-12-${day.toString().padStart(2, '0')}`);
  }

  let totalClasses = 0;
  let paidClasses = 0;
  let unpaidClasses = 0;

  students.forEach(student => {
    testDates.forEach(date => {
      if (hasClassOnDay(student, date)) {
        totalClasses++;
        const payment = paymentIndex[student.id]?.[date];
        
        if (payment) {
          paidClasses++;
          console.log(`✅ ${date} - ${student.name}: PAID ($${payment.amount})`);
        } else {
          unpaidClasses++;
          console.log(`❌ ${date} - ${student.name}: UNPAID`);
        }
      }
    });
  });

  console.log(`\n📊 MATCHING SUMMARY:`);
  console.log(`  Total classes Dec 1-15: ${totalClasses}`);
  console.log(`  Paid: ${paidClasses} (${((paidClasses/totalClasses)*100).toFixed(1)}%)`);
  console.log(`  Unpaid: ${unpaidClasses} (${((unpaidClasses/totalClasses)*100).toFixed(1)}%)`);

  // ═══════════════════════════════════════════════════════════════
  // FINAL SUMMARY
  // ═══════════════════════════════════════════════════════════════
  console.log('\n\n🎯 FINAL DIAGNOSIS:');
  console.log('═══════════════════════════════════════════════════');
  console.log(`Total Payments: ${payments.length}`);
  console.log(`├─ Linked: ${linked.length}`);
  console.log(`├─ Unlinked (Type A Fuchsia): ${unlinked.length}`);
  console.log(`├─ Duplicates (ERROR Yellow): ${duplicates.length}`);
  console.log(`├─ Non-class days (Type B Fuchsia): ${nonClassDays.length}`);
  console.log(`└─ Date mismatches (Reassigned): ${mismatches.length}\n`);

  console.log('🔍 WHAT TO CHECK IN CALENDAR:');
  if (unlinked.length > 0) {
    console.log(`  • Should see ${unlinked.length} Type A fuchsia dots (unlinked payments)`);
  }
  if (duplicates.length > 0) {
    console.log(`  • Should see ${duplicates.length} yellow ERROR dots (duplicates)`);
  }
  if (nonClassDays.length > 0) {
    console.log(`  • Should see ${nonClassDays.length} Type B fuchsia dots (wrong day payments)`);
  }
  if (mismatches.length > 0) {
    console.log(`  • ${mismatches.length} payments were reassigned to different dates`);
  }

  console.log('\n✅ Debug complete! Check results above.');
})();
