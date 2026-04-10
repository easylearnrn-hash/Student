const fs = require('fs');

let content = fs.readFileSync('Group-Notes.html', 'utf8');

// We'll inject a helper fetchAll function before loadData
const fetchAllFunc = `
    async function fetchAll(table, selectStr, orderByObj = null) {
      let allData = [];
      let offset = 0;
      const batchSize = 1000;
      while (true) {
        let query = supabaseClient.from(table).select(selectStr).range(offset, offset + batchSize - 1);
        if (orderByObj) query = query.order(orderByObj.col, { ascending: orderByObj.asc });
        const { data, error } = await query;
        if (error) throw error;
        if (!data || data.length === 0) break;
        allData.push(...data);
        if (data.length < batchSize) break;
        offset += batchSize;
      }
      return allData;
    }
`;

content = content.replace('// ===== LOAD DATA =====', fetchAllFunc + '\n    // ===== LOAD DATA =====');

// Replace the Promise.all array with fetchAll calls inside loadData
const searchString = `            const [notesResult, permsResult, freeAccessResult] = await Promise.all([
              // Fetch notes (if not cached)
              notesCache ? Promise.resolve({ data: notesCache, error: null }) : 
                supabaseClient
                  .from('student_notes')
                  .select('id, title, system_category, category, group_name, class_date, description, pdf_url, requires_payment, video_url, created_at, file_size, file_name')
                  .order('class_date', { ascending: false })
                  .limit(3000),
              
              // Fetch permissions (if not cached)
              permsCache ? Promise.resolve({ data: permsCache, error: null }) :
                supabaseClient
                  .from('student_note_permissions')
                  .select('note_id, group_name, is_accessible, class_date, granted_at, student_id')
                  .limit(10000),
              
              // Fetch free access (if not cached)
              freeAccessCache ? Promise.resolve({ data: freeAccessCache, error: null }) :
                supabaseClient
                  .from('note_free_access')
                  .select('note_id, access_type, group_letter, student_id, class_date, created_at')
            ]);`;

const replacementString = `            const [notesResult, permsResult, freeAccessResult] = await Promise.all([
              notesCache ? Promise.resolve({ data: notesCache, error: null }) : 
                fetchAll('student_notes', 'id, title, system_category, category, group_name, class_date, description, pdf_url, requires_payment, video_url, created_at, file_size, file_name', { col: 'class_date', asc: false }).then(d => ({data: d, error: null})),
              permsCache ? Promise.resolve({ data: permsCache, error: null }) :
                fetchAll('student_note_permissions', 'note_id, group_name, is_accessible, class_date, granted_at, student_id').then(d => ({data: d, error: null})),
              freeAccessCache ? Promise.resolve({ data: freeAccessCache, error: null }) :
                fetchAll('note_free_access', 'note_id, access_type, group_letter, student_id, class_date, created_at').then(d => ({data: d, error: null}))
            ]);`;

if (content.includes('limit(3000)')) {
    content = content.replace(searchString, replacementString);
    fs.writeFileSync('Group-Notes.html', content);
    console.log('Fixed pagination in Group-Notes.html');
} else {
    console.log('Could not find the target string!');
}
