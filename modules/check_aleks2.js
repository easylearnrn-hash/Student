const { createClient } = require('@supabase/supabase-js');
const rawHtml = require('fs').readFileSync('student-portal.html', 'utf-8');
const urlMatch = rawHtml.match(/SUPABASE_URL\s*=\s*['"]([^'"]+)['"]/);
const keyMatch = rawHtml.match(/SUPABASE_ANON_KEY\s*=\s*['"]([^'"]+)['"]/);
const supabase = createClient(urlMatch[1], keyMatch[1]);

async function check() {
  const { data: students } = await supabase.from('students').select('id, name');
  const al = students.find(s => s.name.toLowerCase().includes('aleksandr') || s.name.toLowerCase().includes('petrosyan'));
  if (!al) return console.log('no student');
  console.log('Student:', al.name, al.id);
  const { data: payments } = await supabase.from('payment_records').select('*').eq('student_id', al.id).order('date', {ascending: false});
  console.log('Payments:');
  console.dir(payments, {depth: null});
}
check();
