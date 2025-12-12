// ============================================================
// 🔍 GROUP NOTES CHECKBOX DEBUG SCRIPT
// ============================================================
// Paste this into browser console while on Group-Notes.html
// ============================================================

(function() {
  console.clear();
  console.log('%c🔍 CHECKBOX DEBUG SCRIPT STARTED', 'background: #667eea; color: white; padding: 8px; font-size: 16px; font-weight: bold;');
  console.log('');

  // ============================================================
  // 1️⃣ CHECK GLOBAL STATE
  // ============================================================
  console.log('%c1️⃣ GLOBAL STATE', 'background: #22c55e; color: white; padding: 4px; font-weight: bold;');
  
  if (typeof globalCheckedNoteIds !== 'undefined') {
    console.log('✅ globalCheckedNoteIds exists:', globalCheckedNoteIds);
    console.log('   Type:', typeof globalCheckedNoteIds);
    console.log('   Size:', globalCheckedNoteIds.size);
    console.log('   Contents:', Array.from(globalCheckedNoteIds));
  } else {
    console.error('❌ globalCheckedNoteIds is undefined!');
  }

  if (typeof selectedNoteIds !== 'undefined') {
    console.log('✅ selectedNoteIds exists:', selectedNoteIds);
    console.log('   Type:', typeof selectedNoteIds);
    console.log('   Size:', selectedNoteIds.size);
    console.log('   Contents:', Array.from(selectedNoteIds));
  } else {
    console.error('❌ selectedNoteIds is undefined!');
  }
  
  console.log('');

  // ============================================================
  // 2️⃣ CHECK DOM CHECKBOXES
  // ============================================================
  console.log('%c2️⃣ DOM CHECKBOXES', 'background: #3b82f6; color: white; padding: 4px; font-weight: bold;');
  
  const allCheckboxes = document.querySelectorAll('.note-checkbox');
  console.log('📦 Total checkboxes in DOM:', allCheckboxes.length);
  
  const checkedCheckboxes = document.querySelectorAll('.note-checkbox:checked');
  console.log('✅ Checked checkboxes:', checkedCheckboxes.length);
  
  console.log('\n📋 Checkbox Details:');
  allCheckboxes.forEach((cb, idx) => {
    const noteId = cb.getAttribute('data-note-id');
    const isChecked = cb.checked;
    const isInGlobal = globalCheckedNoteIds ? globalCheckedNoteIds.has(noteId) : false;
    const isInSelected = selectedNoteIds ? selectedNoteIds.has(parseInt(noteId)) : false;
    
    console.log(`  [${idx + 1}] Note ID: ${noteId}`);
    console.log(`      DOM checked: ${isChecked ? '✅' : '❌'}`);
    console.log(`      In globalCheckedNoteIds: ${isInGlobal ? '✅' : '❌'}`);
    console.log(`      In selectedNoteIds: ${isInSelected ? '✅' : '❌'}`);
    
    // Check visual state
    const computedStyle = window.getComputedStyle(cb);
    console.log(`      Display: ${computedStyle.display}, Visibility: ${computedStyle.visibility}, Opacity: ${computedStyle.opacity}`);
    console.log('');
  });
  
  console.log('');

  // ============================================================
  // 3️⃣ CHECK UI ELEMENTS
  // ============================================================
  console.log('%c3️⃣ UI ELEMENTS', 'background: #f59e0b; color: white; padding: 4px; font-weight: bold;');
  
  const batchBar = document.getElementById('batchActionBar');
  const countSpan = document.getElementById('selectedCount');
  const selectAllCheckbox = document.getElementById('selectAllCheckbox');
  
  console.log('📊 Batch Action Bar:');
  console.log('   Exists:', !!batchBar);
  if (batchBar) {
    console.log('   Display:', batchBar.style.display);
    console.log('   Computed Display:', window.getComputedStyle(batchBar).display);
  }
  
  console.log('\n📝 Selected Count Span:');
  console.log('   Exists:', !!countSpan);
  if (countSpan) {
    console.log('   Text:', countSpan.textContent);
  }
  
  console.log('\n☑️ Select All Checkbox:');
  console.log('   Exists:', !!selectAllCheckbox);
  if (selectAllCheckbox) {
    console.log('   Checked:', selectAllCheckbox.checked);
  }
  
  console.log('');

  // ============================================================
  // 4️⃣ CHECK NOTE CARDS
  // ============================================================
  console.log('%c4️⃣ NOTE CARDS', 'background: #8b5cf6; color: white; padding: 4px; font-weight: bold;');
  
  const noteCards = document.querySelectorAll('.note-card');
  console.log('📇 Total note cards:', noteCards.length);
  
  noteCards.forEach((card, idx) => {
    const noteId = card.getAttribute('data-note-id');
    const checkbox = card.querySelector('.note-checkbox');
    console.log(`  Card ${idx + 1}: Note ID ${noteId}`);
    console.log(`    Has checkbox: ${!!checkbox}`);
    if (checkbox) {
      console.log(`    Checkbox checked: ${checkbox.checked}`);
      console.log(`    Checkbox data-note-id: ${checkbox.getAttribute('data-note-id')}`);
    }
  });
  
  console.log('');

  // ============================================================
  // 5️⃣ SYNCHRONIZATION TEST
  // ============================================================
  console.log('%c5️⃣ SYNCHRONIZATION TEST', 'background: #ec4899; color: white; padding: 4px; font-weight: bold;');
  
  console.log('🔄 Checking if states are in sync...');
  
  let syncIssues = [];
  
  allCheckboxes.forEach((cb) => {
    const noteId = cb.getAttribute('data-note-id');
    const isChecked = cb.checked;
    const isInGlobal = globalCheckedNoteIds ? globalCheckedNoteIds.has(noteId) : false;
    
    if (isChecked && !isInGlobal) {
      syncIssues.push(`Note ${noteId}: DOM checked but NOT in globalCheckedNoteIds`);
    }
    if (!isChecked && isInGlobal) {
      syncIssues.push(`Note ${noteId}: NOT checked in DOM but IS in globalCheckedNoteIds`);
    }
  });
  
  if (syncIssues.length > 0) {
    console.error('❌ SYNC ISSUES FOUND:');
    syncIssues.forEach(issue => console.error('   • ' + issue));
  } else {
    console.log('✅ All checkboxes are in sync with globalCheckedNoteIds');
  }
  
  console.log('');

  // ============================================================
  // 6️⃣ RENDER FUNCTION CHECK
  // ============================================================
  console.log('%c6️⃣ RENDER FUNCTION CHECK', 'background: #14b8a6; color: white; padding: 4px; font-weight: bold;');
  
  if (typeof renderNoteCard !== 'undefined') {
    console.log('✅ renderNoteCard function exists');
    
    // Try to see the function source
    const funcStr = renderNoteCard.toString();
    const hasCheckedAttribute = funcStr.includes('checked');
    const hasGlobalCheck = funcStr.includes('globalCheckedNoteIds');
    
    console.log('   Checks globalCheckedNoteIds:', hasGlobalCheck ? '✅' : '❌');
    console.log('   Sets checked attribute:', hasCheckedAttribute ? '✅' : '❌');
  } else {
    console.error('❌ renderNoteCard function not found');
  }
  
  console.log('');

  // ============================================================
  // 7️⃣ SUGGESTED FIXES
  // ============================================================
  console.log('%c7️⃣ SUGGESTED FIXES', 'background: #ef4444; color: white; padding: 4px; font-weight: bold;');
  
  if (syncIssues.length > 0) {
    console.log('🔧 Try running this to force sync:');
    console.log('%cupdateSelectedCount();', 'background: #1e293b; color: #22c55e; padding: 4px; font-family: monospace;');
    console.log('');
    console.log('🔧 Or manually sync checkboxes with global state:');
    console.log('%cglobalCheckedNoteIds.forEach(noteId => {\n  const cb = document.querySelector(\`.note-checkbox[data-note-id="${noteId}"]\`);\n  if (cb) cb.checked = true;\n});\nupdateSelectedCount();', 'background: #1e293b; color: #22c55e; padding: 4px; font-family: monospace;');
  }
  
  console.log('');
  console.log('%c🔍 DEBUG COMPLETE', 'background: #667eea; color: white; padding: 8px; font-size: 16px; font-weight: bold;');
  console.log('');
  
  // ============================================================
  // 8️⃣ RETURN SUMMARY OBJECT
  // ============================================================
  return {
    globalCheckedCount: globalCheckedNoteIds ? globalCheckedNoteIds.size : 0,
    selectedCount: selectedNoteIds ? selectedNoteIds.size : 0,
    domCheckboxCount: allCheckboxes.length,
    domCheckedCount: checkedCheckboxes.length,
    syncIssues: syncIssues,
    hasIssues: syncIssues.length > 0,
    globalIds: globalCheckedNoteIds ? Array.from(globalCheckedNoteIds) : [],
    selectedIds: selectedNoteIds ? Array.from(selectedNoteIds) : []
  };
})();
