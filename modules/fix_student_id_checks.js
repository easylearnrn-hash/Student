const fs = require('fs');

let content = fs.readFileSync('Group-Notes.html', 'utf8');

// Replace permissions.some
content = content.replace(/p => p\.note_id === noteId && p\.group_name === currentGroup(\b| \))/g, 'p => p.note_id === noteId && p.group_name === currentGroup && !p.student_id$1');
content = content.replace(/perm => \s*perm\.note_id === note\.id && \s*perm\.group_name === currentGroup/g, "perm => \n            perm.note_id === note.id && \n            perm.group_name === currentGroup &&\n            !perm.student_id");

// Replace permissions.find
content = content.replace(/permissions\.find\(p => p\.note_id === note\.id && p\.group_name === currentGroup\)/g, 'permissions.find(p => p.note_id === note.id && p.group_name === currentGroup && !p.student_id)');
content = content.replace(/permissions\.find\(p => \s*p\.note_id === noteId && p\.group_name === currentGroup\s*\)/g, "permissions.find(p => \n          p.note_id === noteId && p.group_name === currentGroup && !p.student_id\n        )");

// Also check permissionsMap where the key is composed
content = content.replace('const key = `${perm.note_id}_${perm.group_name}`;', "if (perm.student_id) return;\n        const key = `${perm.note_id}_${perm.group_name}`;");

// And replace anywhere `filter(p => !(noteIds` or similar deletes occur to ensure we don't accidentally remove student_ids from local array when doing group deletions
content = content.replace(/permissions\.filter\(p => \s*!\(noteIds\.includes\(p\.note_id\) && p\.group_name === currentGroup\)\s*\);/g, "permissions.filter(p => \n          !(noteIds.includes(p.note_id) && p.group_name === currentGroup && !p.student_id)\n        );");
content = content.replace(/permissions\.filter\(p =>\s*!\(noteIdsArray\.includes\(p\.note_id\) && p\.group_name === currentGroup\)\s*\);/g, "permissions.filter(p =>\n            !(noteIdsArray.includes(p.note_id) && p.group_name === currentGroup && !p.student_id)\n          );");
content = content.replace(/permissions\.filter\(p => \s*!\(selectedNoteIds\.has\(p\.note_id\) && p\.group_name === currentGroup\)\s*\);/g, "permissions.filter(p => \n            !(selectedNoteIds.has(p.note_id) && p.group_name === currentGroup && !p.student_id)\n          );");

fs.writeFileSync('Group-Notes.html', content);
console.log('Fixed student_id checks in Group-Notes.html');
