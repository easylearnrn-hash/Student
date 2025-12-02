// ============================================================
// 🔍 ARNOMA MODULES COMPREHENSIVE DIAGNOSTIC SCRIPT
// ============================================================
// Copy and paste this entire script into your browser console
// while on any ARNOMA module page
// ============================================================

(async function ARNOMADiagnostic() {
  console.clear();
  console.log('%c🔍 ARNOMA MODULES DIAGNOSTIC STARTING...', 'color: #00ff00; font-size: 20px; font-weight: bold;');
  console.log('%c════════════════════════════════════════════════════════════', 'color: #00ff00;');
  
  const results = {
    timestamp: new Date().toISOString(),
    currentPage: window.location.href,
    moduleName: document.title,
    errors: [],
    warnings: [],
    info: [],
    buttons: [],
    functions: [],
    supabase: {},
    localStorage: {},
    sessionStorage: {},
    auth: {},
    dom: {},
    network: []
  };

  // ============================================================
  // 1. PAGE & ENVIRONMENT INFO
  // ============================================================
  console.log('%c\n📄 PAGE INFORMATION', 'color: cyan; font-size: 16px; font-weight: bold;');
  results.info.push({
    type: 'page',
    url: window.location.href,
    title: document.title,
    userAgent: navigator.userAgent,
    viewport: `${window.innerWidth}x${window.innerHeight}`,
    timestamp: new Date().toLocaleString()
  });
  console.log('URL:', window.location.href);
  console.log('Title:', document.title);
  console.log('Viewport:', `${window.innerWidth}x${window.innerHeight}`);

  // ============================================================
  // 2. JAVASCRIPT ERRORS (from console)
  // ============================================================
  console.log('%c\n🐛 JAVASCRIPT ERRORS', 'color: red; font-size: 16px; font-weight: bold;');
  const originalError = console.error;
  const capturedErrors = [];
  console.error = function(...args) {
    capturedErrors.push({
      timestamp: new Date().toISOString(),
      message: args.join(' ')
    });
    originalError.apply(console, args);
  };

  // ============================================================
  // 3. SUPABASE CONNECTION & AUTH
  // ============================================================
  console.log('%c\n🔐 SUPABASE & AUTHENTICATION', 'color: yellow; font-size: 16px; font-weight: bold;');
  
  if (typeof supabase !== 'undefined') {
    results.supabase.initialized = true;
    console.log('✅ Supabase client initialized');
    
    try {
      const { data: { session }, error } = await supabase.auth.getSession();
      if (error) {
        results.errors.push({ type: 'auth', message: error.message });
        console.error('❌ Auth session error:', error.message);
      } else if (session) {
        results.auth.loggedIn = true;
        results.auth.email = session.user?.email;
        results.auth.role = session.user?.role;
        results.auth.userId = session.user?.id;
        console.log('✅ User logged in:', session.user?.email);
      } else {
        results.auth.loggedIn = false;
        console.log('⚠️  No active session');
      }
    } catch (e) {
      results.errors.push({ type: 'auth', message: e.message });
      console.error('❌ Auth check failed:', e.message);
    }
  } else {
    results.supabase.initialized = false;
    results.errors.push({ type: 'supabase', message: 'Supabase not initialized' });
    console.error('❌ Supabase not initialized');
  }

  // ============================================================
  // 4. STORAGE (localStorage & sessionStorage)
  // ============================================================
  console.log('%c\n💾 STORAGE', 'color: magenta; font-size: 16px; font-weight: bold;');
  
  try {
    const localKeys = Object.keys(localStorage);
    results.localStorage.keys = localKeys;
    results.localStorage.count = localKeys.length;
    console.log(`📦 localStorage: ${localKeys.length} keys`);
    localKeys.forEach(key => {
      const value = localStorage.getItem(key);
      console.log(`  - ${key}: ${value?.substring(0, 50)}${value?.length > 50 ? '...' : ''}`);
    });
  } catch (e) {
    results.errors.push({ type: 'localStorage', message: e.message });
    console.error('❌ localStorage error:', e.message);
  }

  try {
    const sessionKeys = Object.keys(sessionStorage);
    results.sessionStorage.keys = sessionKeys;
    results.sessionStorage.count = sessionKeys.length;
    console.log(`📦 sessionStorage: ${sessionKeys.length} keys`);
    sessionKeys.forEach(key => {
      const value = sessionStorage.getItem(key);
      console.log(`  - ${key}: ${value?.substring(0, 50)}${value?.length > 50 ? '...' : ''}`);
    });
  } catch (e) {
    results.errors.push({ type: 'sessionStorage', message: e.message });
    console.error('❌ sessionStorage error:', e.message);
  }

  // ============================================================
  // 5. BUTTONS & CLICK HANDLERS
  // ============================================================
  console.log('%c\n🔘 BUTTONS & CLICK HANDLERS', 'color: lightblue; font-size: 16px; font-weight: bold;');
  
  const allButtons = document.querySelectorAll('button, .btn, [role="button"], [onclick]');
  console.log(`Found ${allButtons.length} buttons/clickable elements`);
  
  allButtons.forEach((btn, index) => {
    const buttonInfo = {
      index,
      tag: btn.tagName,
      id: btn.id,
      classes: Array.from(btn.classList).join(' '),
      text: btn.textContent?.trim().substring(0, 50),
      onclick: btn.onclick ? 'yes' : 'no',
      hasEventListener: btn.onclick !== null || btn.getAttribute('onclick') !== null,
      disabled: btn.disabled,
      visible: btn.offsetParent !== null
    };
    
    results.buttons.push(buttonInfo);
    
    if (!buttonInfo.hasEventListener && !buttonInfo.disabled) {
      results.warnings.push({
        type: 'button',
        message: `Button without click handler: ${buttonInfo.text || buttonInfo.id || buttonInfo.classes}`
      });
      console.warn(`⚠️  Button #${index} has no click handler:`, buttonInfo);
    }
  });

  // ============================================================
  // 6. GLOBAL FUNCTIONS & VARIABLES
  // ============================================================
  console.log('%c\n⚙️ GLOBAL FUNCTIONS & VARIABLES', 'color: orange; font-size: 16px; font-weight: bold;');
  
  const expectedFunctions = [
    // Student Manager
    'saveStudent', 'deleteStudent', 'editStudent', 'renderStudentCards', 'selectAmount', 'selectGroup',
    // Calendar
    'loadCalendar', 'saveEvent', 'deleteEvent', 'sendPaymentReminder', 'generatePaymentReminderEmailHTML',
    // Email System
    'sendEmail', 'loadEmailTemplates', 'loadSentEmails',
    // Payment Records
    'fetchPaymentsFromGmail', 'savePaymentRecord', 'deletePaymentRecord',
    // Notes Manager
    'uploadPDF', 'deleteNote', 'loadNotes',
    // Auth
    'login', 'logout', 'checkAuth', 'ensureSession'
  ];

  const expectedVariables = [
    'supabase', 'DEBUG_MODE', 'students', 'groups', 'events', 'payments'
  ];

  console.log('Checking expected functions:');
  expectedFunctions.forEach(funcName => {
    const exists = typeof window[funcName] === 'function';
    results.functions.push({
      name: funcName,
      exists,
      type: exists ? typeof window[funcName] : 'undefined'
    });
    
    if (exists) {
      console.log(`  ✅ ${funcName}`);
    } else {
      console.log(`  ⚠️  ${funcName} - NOT FOUND`);
      results.warnings.push({
        type: 'function',
        message: `Expected function not found: ${funcName}`
      });
    }
  });

  console.log('\nChecking expected variables:');
  expectedVariables.forEach(varName => {
    const exists = typeof window[varName] !== 'undefined';
    const type = typeof window[varName];
    
    if (exists) {
      console.log(`  ✅ ${varName} (${type})`);
      results.info.push({
        type: 'variable',
        name: varName,
        valueType: type,
        value: type === 'object' ? 'object' : window[varName]
      });
    } else {
      console.log(`  ⚠️  ${varName} - NOT FOUND`);
    }
  });

  // ============================================================
  // 7. DOM STRUCTURE & MISSING ELEMENTS
  // ============================================================
  console.log('%c\n🎨 DOM STRUCTURE', 'color: pink; font-size: 16px; font-weight: bold;');
  
  const criticalElements = [
    '#studentCards', '#studentGrid', '#calendarContainer', '#emailList',
    '#paymentTable', '#notesContainer', '#loginForm', '#editModal'
  ];

  criticalElements.forEach(selector => {
    const element = document.querySelector(selector);
    const exists = element !== null;
    
    results.dom[selector] = {
      exists,
      visible: exists ? element.offsetParent !== null : false,
      children: exists ? element.children.length : 0
    };
    
    if (exists) {
      console.log(`  ✅ ${selector} (${element.children.length} children)`);
    } else {
      console.log(`  ⚠️  ${selector} - NOT FOUND (might be OK depending on page)`);
    }
  });

  // ============================================================
  // 8. NETWORK REQUESTS (check for failed requests)
  // ============================================================
  console.log('%c\n🌐 NETWORK MONITORING', 'color: lightgreen; font-size: 16px; font-weight: bold;');
  console.log('Note: Network errors will appear as they occur');
  
  const originalFetch = window.fetch;
  window.fetch = async function(...args) {
    const startTime = Date.now();
    try {
      const response = await originalFetch.apply(this, args);
      const duration = Date.now() - startTime;
      
      results.network.push({
        url: args[0],
        method: args[1]?.method || 'GET',
        status: response.status,
        ok: response.ok,
        duration
      });
      
      if (!response.ok) {
        console.warn(`⚠️  Network request failed: ${args[0]} - Status: ${response.status}`);
      }
      
      return response;
    } catch (error) {
      const duration = Date.now() - startTime;
      results.network.push({
        url: args[0],
        method: args[1]?.method || 'GET',
        error: error.message,
        duration
      });
      console.error(`❌ Network error: ${args[0]}`, error);
      throw error;
    }
  };

  // ============================================================
  // 9. SHARED UTILITIES CHECK
  // ============================================================
  console.log('%c\n🛠️ SHARED UTILITIES', 'color: lightcoral; font-size: 16px; font-weight: bold;');
  
  // Check for shared-auth.js
  if (typeof ArnomaAuth !== 'undefined') {
    console.log('✅ shared-auth.js loaded');
    results.info.push({ type: 'utility', name: 'ArnomaAuth', loaded: true });
  } else {
    console.log('⚠️  shared-auth.js not loaded (might be OK depending on page)');
  }

  // Check for shared-dialogs.js
  if (typeof customAlert !== 'undefined') {
    console.log('✅ shared-dialogs.js loaded');
    results.info.push({ type: 'utility', name: 'shared-dialogs', loaded: true });
  } else {
    console.log('⚠️  shared-dialogs.js not loaded (might be OK depending on page)');
  }

  // ============================================================
  // 10. CONSOLE ERRORS & WARNINGS
  // ============================================================
  console.log('%c\n📋 CAPTURED CONSOLE ERRORS', 'color: red; font-size: 16px; font-weight: bold;');
  if (capturedErrors.length > 0) {
    console.log(`Found ${capturedErrors.length} errors:`);
    capturedErrors.forEach(err => console.error(err));
    results.errors = results.errors.concat(capturedErrors);
  } else {
    console.log('✅ No errors captured (so far)');
  }

  // ============================================================
  // 11. SUMMARY REPORT
  // ============================================================
  console.log('%c\n════════════════════════════════════════════════════════════', 'color: #00ff00;');
  console.log('%c📊 DIAGNOSTIC SUMMARY', 'color: #00ff00; font-size: 20px; font-weight: bold;');
  console.log('%c════════════════════════════════════════════════════════════', 'color: #00ff00;');
  
  const errorCount = results.errors.length;
  const warningCount = results.warnings.length;
  const buttonCount = results.buttons.length;
  const functionCount = results.functions.filter(f => f.exists).length;
  
  console.log(`\n🔴 Errors: ${errorCount}`);
  console.log(`🟡 Warnings: ${warningCount}`);
  console.log(`🔘 Buttons found: ${buttonCount}`);
  console.log(`⚙️  Functions available: ${functionCount}/${expectedFunctions.length}`);
  console.log(`🔐 Auth status: ${results.auth.loggedIn ? '✅ Logged in' : '❌ Not logged in'}`);
  console.log(`💾 Supabase: ${results.supabase.initialized ? '✅ Initialized' : '❌ Not initialized'}`);

  if (errorCount === 0) {
    console.log('%c\n✅ NO CRITICAL ERRORS FOUND!', 'color: lime; font-size: 16px; font-weight: bold;');
  } else {
    console.log('%c\n⚠️  ISSUES DETECTED - See details above', 'color: orange; font-size: 16px; font-weight: bold;');
  }

  // ============================================================
  // 12. EXPORT RESULTS
  // ============================================================
  console.log('%c\n📤 EXPORTING RESULTS...', 'color: cyan; font-size: 16px; font-weight: bold;');
  console.log('Copy the results below and send to the developer:\n');
  
  const exportData = JSON.stringify(results, null, 2);
  
  // Create downloadable JSON
  const blob = new Blob([exportData], { type: 'application/json' });
  const url = URL.createObjectURL(blob);
  const a = document.createElement('a');
  a.href = url;
  a.download = `arnoma-diagnostic-${new Date().getTime()}.json`;
  
  console.log('%c════════════════════════════════════════════════════════════', 'color: #00ff00;');
  console.log('%cRESULTS (copy everything below):', 'color: yellow; font-size: 14px; font-weight: bold;');
  console.log('%c════════════════════════════════════════════════════════════', 'color: #00ff00;');
  console.log(exportData);
  console.log('%c════════════════════════════════════════════════════════════', 'color: #00ff00;');
  
  console.log('\n%c💾 Click below to download full diagnostic report:', 'color: cyan; font-size: 14px;');
  console.log(a);
  console.log('Or run: document.querySelector("a[download*=arnoma-diagnostic]").click()');

  // Also make results available globally
  window.ARNOMA_DIAGNOSTIC_RESULTS = results;
  console.log('\n%cResults also available in: window.ARNOMA_DIAGNOSTIC_RESULTS', 'color: lightblue;');
  
  console.log('%c\n🔍 DIAGNOSTIC COMPLETE!', 'color: #00ff00; font-size: 20px; font-weight: bold;');
  console.log('%c════════════════════════════════════════════════════════════', 'color: #00ff00;');

  return results;
})();
