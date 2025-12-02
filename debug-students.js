// ============================================================
// 🔍 ARNOMA UNIVERSAL MODULE DIAGNOSTIC
// ============================================================
// Paste this in console on ANY ARNOMA module page
// Auto-detects which module you're on and runs appropriate checks
// ============================================================

console.clear();

// Detect current module
const currentPage = window.location.pathname.split('/').pop() || document.title;
const pageTitle = document.title;

console.log('%c🔍 ARNOMA MODULE DIAGNOSTIC', 'color: lime; font-size: 20px; font-weight: bold;');
console.log('%cCurrent Page: ' + currentPage, 'color: cyan; font-size: 14px;');
console.log('%cPage Title: ' + pageTitle, 'color: cyan; font-size: 14px;');
console.log('═'.repeat(60));

// ============================================================
// 1. UNIVERSAL CHECKS (All Modules)
// ============================================================
console.log('\n%c📦 CORE DEPENDENCIES', 'color: yellow; font-weight: bold;');
console.log('  Supabase:', typeof supabase !== 'undefined' ? '✅ LOADED' : '❌ MISSING');
console.log('  ArnomaAuth:', typeof ArnomaAuth !== 'undefined' ? '✅ LOADED' : '❌ MISSING');
console.log('  customAlert:', typeof customAlert === 'function' ? '✅ LOADED' : '❌ MISSING');
console.log('  customConfirm:', typeof customConfirm === 'function' ? '✅ LOADED' : '❌ MISSING');
console.log('  customPrompt:', typeof customPrompt === 'function' ? '✅ LOADED' : '❌ MISSING');

// Check for DEBUG_MODE
console.log('\n%c🐛 DEBUG MODE', 'color: yellow; font-weight: bold;');
console.log('  DEBUG_MODE:', typeof DEBUG_MODE !== 'undefined' ? (DEBUG_MODE ? '🟢 ENABLED' : '🔴 DISABLED') : '⚪ NOT DEFINED');

// Check localStorage/sessionStorage
console.log('\n%c💾 STORAGE', 'color: yellow; font-weight: bold;');
const authSession = localStorage.getItem('arnoma:auth:session');
const authUser = localStorage.getItem('arnoma:auth:user');
const impersonationToken = sessionStorage.getItem('impersonation_token');
console.log('  Auth Session:', authSession ? '✅ FOUND' : '❌ MISSING');
console.log('  Auth User:', authUser ? '✅ FOUND' : '❌ MISSING');
console.log('  Impersonation Token:', impersonationToken ? '⚠️ ACTIVE' : 'None');

// ============================================================
// 2. MODULE-SPECIFIC CHECKS
// ============================================================

if (pageTitle.includes('Student Manager') || currentPage.includes('Student-Manager')) {
  console.log('\n%c👥 STUDENT MANAGER CHECKS', 'color: cyan; font-weight: bold;');
  console.log('  students array:', typeof students !== 'undefined' ? `✅ ${students.length} records` : '❌ MISSING');
  console.log('  filteredStudents:', typeof filteredStudents !== 'undefined' ? `✅ ${filteredStudents.length} records` : '❌ MISSING');
  console.log('  DOMCache:', typeof DOMCache !== 'undefined' ? '✅ LOADED' : '❌ MISSING');
  console.log('  DataCache:', typeof DataCache !== 'undefined' ? '✅ LOADED' : '❌ MISSING');
  
  const grid = document.getElementById('studentsGrid');
  console.log('  studentsGrid element:', grid ? `✅ FOUND (${grid.children.length} cards)` : '❌ MISSING');
  
  console.log('\n  Key Functions:');
  console.log('    loadStudents:', typeof loadStudents === 'function' ? '✅' : '❌');
  console.log('    renderStudentCards:', typeof renderStudentCards === 'function' ? '✅' : '❌');
  console.log('    canonicalizeGroupCode:', typeof canonicalizeGroupCode === 'function' ? '✅' : '❌');
  console.log('    parseEmailField:', typeof parseEmailField === 'function' ? '✅' : '❌');
  
  if (typeof students !== 'undefined' && students.length > 0) {
    console.log('\n  Sample Student:', students[0]);
  }
}

else if (pageTitle.includes('Calendar') || currentPage.includes('Calendar')) {
  console.log('\n%c📅 CALENDAR CHECKS', 'color: cyan; font-weight: bold;');
  console.log('  studentsCache:', typeof window.studentsCache !== 'undefined' ? `✅ ${window.studentsCache.length} records` : '❌ MISSING');
  console.log('  groupsCache:', typeof window.groupsCache !== 'undefined' ? `✅ ${window.groupsCache.length} records` : '❌ MISSING');
  console.log('  paymentsCache:', typeof window.paymentsCache !== 'undefined' ? `✅ ${window.paymentsCache.length} records` : '❌ MISSING');
  console.log('  DOMCache:', typeof DOMCache !== 'undefined' ? '✅ LOADED' : '❌ MISSING');
  console.log('  DataCache:', typeof DataCache !== 'undefined' ? '✅ LOADED' : '❌ MISSING');
  
  const calendar = document.getElementById('calendar');
  console.log('  calendar element:', calendar ? `✅ FOUND` : '❌ MISSING');
  
  console.log('\n  Key Functions:');
  console.log('    renderCalendar:', typeof renderCalendar === 'function' ? '✅' : '❌');
  console.log('    fetchStudents:', typeof fetchStudents === 'function' ? '✅' : '❌');
  console.log('    canonicalizeGroupCode:', typeof canonicalizeGroupCode === 'function' ? '✅' : '❌');
}

else if (pageTitle.includes('Student Portal') || currentPage.includes('student-portal')) {
  console.log('\n%c🎓 STUDENT PORTAL CHECKS', 'color: cyan; font-weight: bold;');
  console.log('  currentStudent:', typeof currentStudent !== 'undefined' ? '✅ LOADED' : '❌ MISSING');
  console.log('  paymentRecords:', typeof paymentRecords !== 'undefined' ? `✅ ${paymentRecords?.length || 0} records` : '❌ MISSING');
  
  console.log('\n  Key Functions:');
  console.log('    loadStudentData:', typeof loadStudentData === 'function' ? '✅' : '❌');
  console.log('    loadPaymentRecords:', typeof loadPaymentRecords === 'function' ? '✅' : '❌');
  console.log('    exitImpersonation:', typeof exitImpersonation === 'function' ? '✅' : '❌');
  
  if (typeof currentStudent !== 'undefined') {
    console.log('\n  Current Student:', currentStudent);
  }
}

else if (pageTitle.includes('Email System') || currentPage.includes('Email-System')) {
  console.log('\n%c📧 EMAIL SYSTEM CHECKS', 'color: cyan; font-weight: bold;');
  
  const emailTemplates = localStorage.getItem('arnoma-email-templates-v7');
  const automations = localStorage.getItem('arnoma-automations-v1');
  const sentEmails = localStorage.getItem('arnoma-sent-emails-v1');
  
  console.log('  Email Templates:', emailTemplates ? `✅ ${JSON.parse(emailTemplates).length} templates` : '❌ MISSING');
  console.log('  Automations:', automations ? `✅ ${JSON.parse(automations).length} automations` : '❌ MISSING');
  console.log('  Sent Emails:', sentEmails ? `✅ ${JSON.parse(sentEmails).length} emails` : '❌ MISSING');
  
  console.log('\n  Key Functions:');
  console.log('    sendEmail:', typeof sendEmail === 'function' ? '✅' : '❌');
  console.log('    saveTemplate:', typeof saveTemplate === 'function' ? '✅' : '❌');
}

else if (pageTitle.includes('Payment Records') || currentPage.includes('Payment-Records')) {
  console.log('\n%c💰 PAYMENT RECORDS CHECKS', 'color: cyan; font-weight: bold;');
  console.log('  allPayments:', typeof allPayments !== 'undefined' ? `✅ ${allPayments?.length || 0} records` : '❌ MISSING');
  console.log('  filteredPayments:', typeof filteredPayments !== 'undefined' ? `✅ ${filteredPayments?.length || 0} records` : '❌ MISSING');
  
  console.log('\n  Key Functions:');
  console.log('    loadPayments:', typeof loadPayments === 'function' ? '✅' : '❌');
  console.log('    applyFilters:', typeof applyFilters === 'function' ? '✅' : '❌');
  console.log('    exportToPDF:', typeof exportToPDF === 'function' ? '✅' : '❌');
}

else if (pageTitle.includes('Notes Manager') || currentPage.includes('Notes-Manager')) {
  console.log('\n%c� NOTES MANAGER CHECKS', 'color: cyan; font-weight: bold;');
  console.log('  notes array:', typeof notes !== 'undefined' ? `✅ ${notes?.length || 0} records` : '❌ MISSING');
  
  console.log('\n  Key Functions:');
  console.log('    loadNotes:', typeof loadNotes === 'function' ? '✅' : '❌');
  console.log('    uploadNote:', typeof uploadNote === 'function' ? '✅' : '❌');
}

else if (pageTitle.includes('PDF Viewer') || currentPage.includes('Protected-PDF-Viewer')) {
  console.log('\n%c📄 PDF VIEWER CHECKS', 'color: cyan; font-weight: bold;');
  console.log('  PDF.js:', typeof pdfjsLib !== 'undefined' ? '✅ LOADED' : '❌ MISSING');
  console.log('  currentPDF:', typeof currentPDF !== 'undefined' ? '✅ LOADED' : '❌ MISSING');
  
  console.log('\n  Security Features:');
  console.log('    Right-click disabled:', document.oncontextmenu !== null ? '✅' : '❌');
  console.log('    Text selection disabled:', getComputedStyle(document.body).userSelect === 'none' ? '✅' : '❌');
}

else if (pageTitle.includes('PharmaQuest') || currentPage.includes('PharmaQuest')) {
  console.log('\n%c💊 PHARMAQUEST CHECKS', 'color: cyan; font-weight: bold;');
  console.log('  gameLevel:', typeof gameLevel !== 'undefined' ? `✅ ${gameLevel}` : '❌ MISSING');
  console.log('  score:', typeof score !== 'undefined' ? `✅ ${score}` : '❌ MISSING');
  
  console.log('\n  Key Functions:');
  console.log('    startGame:', typeof startGame === 'function' ? '✅' : '❌');
  console.log('    loadQuestion:', typeof loadQuestion === 'function' ? '✅' : '❌');
}

else if (pageTitle.includes('Login') || currentPage.includes('Login')) {
  console.log('\n%c🔐 LOGIN PAGE CHECKS', 'color: cyan; font-weight: bold;');
  console.log('  Login form exists:', document.querySelector('form') ? '✅ FOUND' : '❌ MISSING');
  
  console.log('\n  Key Functions:');
  console.log('    handleLogin:', typeof handleLogin === 'function' ? '✅' : '❌');
}

else {
  console.log('\n%c❓ UNKNOWN MODULE', 'color: orange; font-weight: bold;');
  console.log('  This diagnostic doesn\'t have specific checks for this page yet.');
}

// ============================================================
// 3. ERROR CHECKING
// ============================================================
console.log('\n%c⚠️ BROWSER CONSOLE ERRORS', 'color: red; font-weight: bold;');
console.log('  Check above for any red error messages');

// ============================================================
// 4. HELPFUL ACTIONS
// ============================================================
console.log('\n%c🔧 AVAILABLE ACTIONS', 'color: lime; font-weight: bold;');

// Offer reload function for Student Manager
if (typeof loadStudents === 'function') {
  console.log('  Run: loadStudents() - Reload student data');
}

// Offer reload for Calendar
if (typeof fetchStudents === 'function') {
  console.log('  Run: fetchStudents() - Reload calendar data');
}

// Offer session check
if (typeof ArnomaAuth !== 'undefined' && typeof supabase !== 'undefined') {
  console.log('  Run: ArnomaAuth.ensureSession(supabase) - Check auth session');
}

// ============================================================
// 5. TIPS
// ============================================================
console.log('\n%c💡 TROUBLESHOOTING TIPS', 'color: yellow; font-weight: bold;');
console.log('  1. If Supabase is missing, check if script loaded (network tab)');
console.log('  2. If data arrays are empty, check Supabase connection & RLS policies');
console.log('  3. If DEBUG_MODE is disabled, enable it for verbose logging');
console.log('  4. If auth is missing, check localStorage/sessionStorage');
console.log('  5. Force reload: Cmd+Shift+R (Mac) or Ctrl+Shift+R (Windows)');

console.log('\n═'.repeat(60));
console.log('%c✅ DIAGNOSTIC COMPLETE', 'color: lime; font-size: 16px; font-weight: bold;');
console.log('═'.repeat(60));
