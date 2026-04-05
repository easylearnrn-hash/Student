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
  
  const { data: pr } = await supabase.from('payment_records').select('*').eq('student_id', al.id).order('date', {ascending: false});
  console.log('payment_records:', pr);

  const { data: p } = await supabase.from('payments').select('*').or(`student_id.eq.${al.id},linked_student_id.eq.${al.id},payer_name.ilike.%aleksandr%`).order('created_at', {ascending: false}).limit(5);
  console.log('payments:', p);
  
  // also check their schedule
  console.log('Group:', al.group_name);
}
check();
