const fs = require('fs');

let content = fs.readFileSync('Group-Notes.html', 'utf8');

content = content.replace(
"// ===== RENDER NOTE CARD =====(note, permissionsMap, freeAccessMap) {",
"// ===== RENDER NOTE CARD =====\nfunction renderNoteCard(note, permissionsMap, freeAccessMap) {"
);

fs.writeFileSync('Group-Notes.html', content);
