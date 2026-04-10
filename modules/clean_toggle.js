const fs = require('fs');

let content = fs.readFileSync('Group-Notes.html', 'utf8');

const regex = /async function toggleNoteStudentOverride[\s\S]*?function renderNoteCard/;

const newCode = `async function toggleNoteStudentOverride(noteId, studentId, isChecked) {
   try {
      if (isChecked) {
         // Grant unconditional access using note_free_access for student (no group_letter allowed per schema check)
         const { data, error } = await supabaseClient.from('note_free_access').upsert({
            note_id: noteId,
            access_type: 'individual',
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
}

    // ===== RENDER NOTE CARD =====`;

content = content.replace(regex, newCode);
fs.writeFileSync('Group-Notes.html', content);
