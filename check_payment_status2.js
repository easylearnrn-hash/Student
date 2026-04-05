const { createClient } = require('@supabase/supabase-js');
const rawHtml = require('fs').readFileSync('student-portal.html', 'utf-8');
const urlMatch = rawHtml.match(/SUPABASE_URL\s*=\s*['"]([^'"]+)['"]/);
const keyMatch = rawHtml.match(/SUPABASE_ANON_KEY\s*=\s*['"]([^'"]+)['"]/);
const supabase = createClient(urlMatch[1], keyMatch[1]);

async function check() {
  const { data: students } = await supabase.from('students').select('*');
  const al = students.find(s => s.name.toLowerCase().includes('alek') || s.name.toLowerCase().includes('petros'));
  if (!al) return console.log('no student');
  console.log('Student:', al.name, al.id, al.group_name);
  
  const { data: pr } = await supabase.from('payment_records').select('*').eq('student_id', al.id).order('date', {ascending: false});
  console.log('payment_records:', pr);

  const { data: p } = await supabase.from('payments').select('*').or(`student_id.eq.${al.id},linked_student_id.eq.${al.id},payer_name.ilike.%alek%`).order('created_at', {ascending: false}).limit(5);
  console.log('payments:', p);
}
check();
