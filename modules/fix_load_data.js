const fs = require('fs');
let content = fs.readFileSync('Group-Notes.html', 'utf8');

// Use regex because formatting might vary slightly
content = content.replace(/supabaseClient\s*\.from\('student_notes'\)\s*\.select\([^\)]+\)\s*\.order\([^\)]+\)\s*\.limit\(3000\)/, "fetchAll('student_notes', 'id, title, system_category, category, group_name, class_date, description, pdf_url, requires_payment, video_url, created_at, file_size, file_name', { col: 'class_date', asc: false }).then(d => ({data: d, error: null}))");

content = content.replace(/supabaseClient\s*\.from\('student_note_permissions'\)\s*\.select\([^\)]+\)\s*\.limit\(10000\)/, "fetchAll('student_note_permissions', 'note_id, group_name, is_accessible, class_date, granted_at, student_id').then(d => ({data: d, error: null}))");

content = content.replace(/supabaseClient\s*\.from\('note_free_access'\)\s*\.select\([^\)]+\)\s*/, "fetchAll('note_free_access', 'note_id, access_type, group_letter, student_id, class_date, created_at').then(d => ({data: d, error: null}))");

fs.writeFileSync('Group-Notes.html', content);
