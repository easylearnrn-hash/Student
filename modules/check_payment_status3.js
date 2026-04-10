const { createClient } = require('@supabase/supabase-js');
const rawHtml = require('fs').readFileSync('student-portal.html', 'utf-8');
const urlMatch = rawHtml.match(/SUPABASE_URL\s*=\s*['"]([^'"]+)['"]/);
const keyMatch = rawHtml.match(/SUPABASE_ANON_KEY\s*=\s*['"]([^'"]+)['"]/);
const supabase = createClient(urlMatch[1], keyMatch[1]);

async function check() {
  const { data: students } = await supabase.from('students').select('*');
  const al = students.find(s => s.name.includes('Aleks') || s.name.includes('an'));
  console.log('Total students:', students.length);
  students.filter(s => s.group_name === 'C').forEach(s => console.log(s.name, s.group_name, s.id));
}
check();
