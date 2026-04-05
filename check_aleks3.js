const { createClient } = require('@supabase/supabase-js');
const rawHtml = require('fs').readFileSync('student-portal.html', 'utf-8');
const urlMatch = rawHtml.match(/SUPABASE_URL\s*=\s*['"]([^'"]+)['"]/);
const keyMatch = rawHtml.match(/SUPABASE_ANON_KEY\s*=\s*['"]([^'"]+)['"]/);
const supabase = createClient(urlMatch[1], keyMatch[1]);

async function check() {
  const { data: students } = await supabase.from('students').select('*').eq('price_per_class', 1);
  console.log('Students with price=1:');
  console.log(students.map(s => s.name + ' (' + s.id + ')'));
  if(students[0]) {
    const { data: pr } = await supabase.from('payment_records').select('*').eq('student_id', students[0].id).order('date', {ascending: false});
    console.log(pr);
  }
}
check();
