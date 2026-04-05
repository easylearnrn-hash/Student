const fs = require('fs');

let content = fs.readFileSync('Group-Notes.html', 'utf8');

const regex = /let currentAccessDropdownDiv = null;[\s\S]*?async function toggleNoteStudentOverride[^\}]*\}[^\}]*\}/;

const newCode = `let currentAccessDropdownDiv = null;

async function toggleNoteAccessDropdown(noteId, event, buttonEl) {
  event.stopPropagation();
  
  if (!currentAccessDropdownDiv) {
    currentAccessDropdownDiv = document.createElement('div');
    currentAccessDropdownDiv.id = 'floating-access-dropdown';
    currentAccessDropdownDiv.style.position = 'absolute';
    currentAccessDropdownDiv.style.zIndex = '10000';
    currentAccessDropdownDiv.style.background = 'rgba(15, 20, 35, 0.98)';
    currentAccessDropdownDiv.style.border = '1px solid rgba(196, 164, 95, 0.4)';
    currentAccessDropdownDiv.style.borderRadius = '8px';
    currentAccessDropdownDiv.style.padding = '12px';
    currentAccessDropdownDiv.style.width = '240px';
    currentAccessDropdownDiv.style.boxShadow = '0 12px 40px rgba(0,0,0,0.6)';
    currentAccessDropdownDiv.style.backdropFilter = 'blur(16px)';
    currentAccessDropdownDiv.style.maxHeight = '350px';
    currentAccessDropdownDiv.style.overflowY = 'auto';
    currentAccessDropdownDiv.style.right = '0'; 
    currentAccessDropdownDiv.style.top = '100%';
    currentAccessDropdownDiv.style.marginTop = '8px';
    
    document.addEventListener('click', (e) => {
      if (currentAccessDropdownDiv && !currentAccessDropdownDiv.contains(e.target) && !e.target.closest('.access-btn-trigger')) {
        currentAccessDropdownDiv.style.display = 'none';
      }
    });

    // Make window resize or scroll reposition it safely if we keep absolute to body, but we're moving it to parent
  }
  
  // If clicking the same button and it's already open, close it
  if (currentAccessDropdownDiv.style.display === 'block' && buttonEl.classList.contains('active-trigger')) {
    currentAccessDropdownDiv.style.display = 'none';
    buttonEl.classList.remove('active-trigger');
    return;
  }

  // Clean previous triggers
  document.querySelectorAll('.access-btn-trigger').forEach(b => b.classList.remove('active-trigger'));
  
  buttonEl.classList.add('access-btn-trigger');
  buttonEl.classList.add('active-trigger');
  
  // Attach to the note card button's container instead of document body
  const container = buttonEl.parentElement;
  container.style.position = 'relative';
  container.appendChild(currentAccessDropdownDiv);
  
  currentAccessDropdownDiv.style.display = 'block';
  
  // Anti-overflow logic - ensure it doesn't drop below screen
  setTimeout(() => {
    const rect = currentAccessDropdownDiv.getBoundingClientRect();
    if (rect.bottom > window.innerHeight) {
       currentAccessDropdownDiv.style.top = 'auto';
       currentAccessDropdownDiv.style.bottom = '100%';
       currentAccessDropdownDiv.style.marginBottom = '8px';
       currentAccessDropdownDiv.style.marginTop = '0';
    } else {
       currentAccessDropdownDiv.style.top = '100%';
       currentAccessDropdownDiv.style.bottom = 'auto';
       currentAccessDropdownDiv.style.marginTop = '8px';
       currentAccessDropdownDiv.style.marginBottom = '0';
    }
  }, 0);
  
  currentAccessDropdownDiv.innerHTML = '<div style="text-align:center; color:#888; font-size:12px; padding:10px;">Loading access data...</div>';
  
  try {
    const paymentData = await getPaymentDataForCurrentGroup();
    const note = allNotes.find(n => n.id === noteId);
    const groupLetter = currentGroup.replace(/Group\\s*/i, '').trim().toUpperCase();
    
    const groupStudents = allStudents.filter(s => {
       if (!s.group_name) return false;
       if (s.status !== 'active') return false; // MUST show only active students
       const sG = s.group_name.replace(/Group\\s*/i, '').trim().toUpperCase();
       return sG === groupLetter || s.group_name === currentGroup;
    }).sort((a,b) => (a.name || '').localeCompare(b.name || ''));
    
    const permission = permissions.find(p => p.note_id === noteId && p.group_name === currentGroup && !p.student_id);
    const freeAccessGrant = freeAccessGrants.find(g => g.note_id === noteId && g.access_type === 'group' && g.group_letter === groupLetter);
    
    const isAccessible = permission?.is_accessible || false;
    const hasFreeAccess = !!freeAccessGrant;
    
    let displayDate = null;
    if (hasFreeAccess && freeAccessGrant?.class_date) displayDate = freeAccessGrant.class_date;
    else if (isAccessible && permission?.class_date) displayDate = permission.class_date;
    else if (note.class_date) displayDate = note.class_date;
    
    const noteDate = displayDate ? displayDate.split('T')[0] : null;
    
    const studentsState = [];
    
    // Calculate access state for "Select All"
    let totalSpecificAccess = 0;
    
    for (const student of groupStudents) {
      const manualFree = freeAccessGrants.find(g => g.note_id === noteId && g.access_type === 'individual' && g.student_id === student.id);
      const manualPerm = permissions.find(p => p.note_id === noteId && p.student_id === student.id && p.is_accessible);
      
      let hasAccess = false;
      let isOverride = false;
      
      if (manualFree || manualPerm) {
        hasAccess = true;
        isOverride = true;
        totalSpecificAccess++;
      } else {
        if (!note.requires_payment || hasFreeAccess) {
          hasAccess = true;
        } else if (isAccessible) {
          const studentInfo = paymentData.data.get(student.id);
          const hasPaid = noteDate ? studentInfo.paidDates.has(noteDate) : (studentInfo.paidDates.size > 0);
          const wasAbsent = noteDate ? studentInfo.absentDates.has(noteDate) : false;
          
          if (hasPaid && !wasAbsent) {
            hasAccess = true;
          }
        }
      }
      studentsState.push({ student, hasAccess, isOverride });
    }
    
    const allChecked = totalSpecificAccess === groupStudents.length && groupStudents.length > 0;
    
    let html = \`<div style="font-size:12px; font-weight:600; color:var(--gold-light); margin-bottom:10px; border-bottom:1px solid rgba(196,164,95,0.2); padding-bottom:6px; display:flex; justify-content:space-between; align-items:center;">
       <span>Individual Access</span>
       <span style="font-size:10px; color:rgba(255,255,255,0.4);">\${noteDate || 'No Date'}</span>
    </div>\`;
    
    html += \`<div style="display:flex; justify-content:space-between; align-items:center; margin-bottom: 10px; padding: 4px; background: rgba(255,255,255,0.05); border-radius: 4px;">
       <label style="display:flex; align-items:center; gap:8px; cursor:pointer; font-size:11px; color:var(--text-muted); width:100%;">
          <input type="checkbox" id="note-access-select-all" 
                 \${allChecked ? 'checked' : ''} 
                 onchange="toggleNoteSelectAll(\${noteId}, this.checked)" 
                 style="width:13px;height:13px;accent-color:var(--emerald);">
          <span style="user-select:none;">Select All Active Students</span>
       </label>
    </div>\`;
    
    html += \`<div style="display:flex; flex-direction:column; gap:8px;">\`;
    
    for (const {student, hasAccess, isOverride} of studentsState) {
      html += \`
        <label style="display:flex; align-items:center; justify-content:space-between; cursor:pointer; font-size:12px; color:var(--text-body); padding:4px; border-radius:4px; transition:background 0.2s;" onmouseover="this.style.background='rgba(255,255,255,0.08)'" onmouseout="this.style.background='transparent'">
          <div style="display:flex; align-items:center; gap:8px;">
             <input type="checkbox" class="student-access-cb" data-student-id="\${student.id}" onchange="toggleNoteStudentOverride(\${noteId}, \${student.id}, this.checked)" \${hasAccess ? 'checked' : ''} style="width:14px;height:14px;accent-color:var(--gold);">
             <span style="\${isOverride ? 'color:var(--emerald); font-weight:600;' : ''}">\${student.name}</span>
          </div>
          <div style="font-size:10px; color:rgba(255,255,255,0.3);">\${hasAccess && !isOverride ? 'Auto' : (isOverride ? 'Manual' : 'Locked')}</div>
        </label>
      \`;
    }
    
    if (groupStudents.length === 0) {
       html += \`<div style="font-size:11px; color:#888; text-align:center; padding:10px;">No active students in \${currentGroup}.</div>\`;
    }
    html += \`</div>\`;
    
    currentAccessDropdownDiv.innerHTML = html;
  } catch(e) {
    console.error(e);
    currentAccessDropdownDiv.innerHTML = \`<div style="color:#ef4444; font-size:11px;">Error loading data</div>\`;
  }
}

async function toggleNoteSelectAll(noteId, isChecked) {
   try {
      const groupLetter = currentGroup.replace(/Group\\s*/i, '').trim().toUpperCase();
      const checkboxes = currentAccessDropdownDiv.querySelectorAll('.student-access-cb');
      const studentIds = Array.from(checkboxes).map(cb => parseInt(cb.getAttribute('data-student-id')));
      
      if (studentIds.length === 0) return;
      
      // Update UI immediately for responsiveness
      checkboxes.forEach(cb => { cb.checked = isChecked; });
      
      if (isChecked) {
         // Create individual free access grants for all filtered students
         const payloads = studentIds.map(id => ({
            note_id: noteId,
            access_type: 'individual',
            group_letter: groupLetter,
            student_id: id,
            created_by: 'admin'
         }));
         
         const { data, error } = await supabaseClient.from('note_free_access')
            .upsert(payloads, { onConflict: 'note_id,student_id', ignoreDuplicates:false })
            .select();
            
         if (error) throw error;
         data.forEach(d => {
            if (!freeAccessGrants.find(g => g.id === d.id)) freeAccessGrants.push(d);
         });
      } else {
         // Remove all individual free access grants for these students
         const existingFree = freeAccessGrants.filter(g => g.note_id === noteId && g.access_type === 'individual' && studentIds.includes(g.student_id));
         if (existingFree.length > 0) {
            const ids = existingFree.map(g => g.id);
            await supabaseClient.from('note_free_access').delete().in('id', ids);
            freeAccessGrants.splice(0, freeAccessGrants.length, ...freeAccessGrants.filter(g => !ids.includes(g.id)));
         }
      }
      
      // Keep UI styles updated (mark manual correctly after sync)
      // Best way is to re-render the dropdown content:
      const btn = document.querySelector('.access-btn-trigger');
      if (btn) toggleNoteAccessDropdown(noteId, {stopPropagation:()=>window.event?.stopPropagation?.()}, btn);
      
   } catch(e) {
      console.error('Failed to toggle Select All', e);
      alert('Failed: ' + e.message);
   }
}

async function toggleNoteStudentOverride(noteId, studentId, isChecked) {
   try {
      const groupLetter = currentGroup.replace(/Group\\s*/i, '').trim().toUpperCase();
      if (isChecked) {
         // Grant unconditional access using note_free_access for student
         const { data, error } = await supabaseClient.from('note_free_access').upsert({
            note_id: noteId,
            access_type: 'individual',
            group_letter: groupLetter,
            student_id: studentId,
            created_by: 'admin'
         }, { onConflict: 'note_id,student_id', ignoreDuplicates:false }).select().single();
         
         if (error) throw error;
         if (!freeAccessGrants.find(g => g.id === data.id)) freeAccessGrants.push(data);
      } else {
         const existingFree = freeAccessGrants.filter(g => g.note_id === noteId && g.access_type === 'individual' && g.student_id === studentId);
         if (existingFree.length > 0) {
            const ids = existingFree.map(g => g.id);
            await supabaseClient.from('note_free_access').delete().in('id', ids);
            freeAccessGrants.splice(0, freeAccessGrants.length, ...freeAccessGrants.filter(g => !ids.includes(g.id)));
         }
      }
   } catch(e) {
      console.error('Failed to toggle override', e);
      alert('Failed to update: ' + e.message);
   }
}`;

content = content.replace(regex, newCode);
fs.writeFileSync('Group-Notes.html', content);
