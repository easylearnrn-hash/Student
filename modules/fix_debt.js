const { createClient } = require('@supabase/supabase-js');
const rawHtml = require('fs').readFileSync('student-portal.html', 'utf-8');
const urlMatch = rawHtml.match(/SUPABASE_URL\s*=\s*['"]([^'"]+)['"]/);
const keyMatch = rawHtml.match(/SUPABASE_ANON_KEY\s*=\s*['"]([^'"]+)['"]/);
const supabase = createClient(urlMatch[1], keyMatch[1]);

async function check() {
  const { data: students } = await supabase.from('students').select('id, name');
  const al = students.find(s => s.name.toLowerCase().replace(/[^a-z]/g, '').includes('petrosyan') || s.name.toLowerCase().replace(/[^a-z]/g, '').includes('alek'));
  if (!al) {
    console.log("Still can't find him, printing all names:");
    console.log(students.map(s => s.name));
    return;
  }
  
  console.log('Found:', al.name, al.id);
  
  // Add an excused record for March 30 so his debt drops to 0
  const { error } = await supabase.from('payment_records').insert({
    student_id: al.id,
    date: '2026-03-30T00:00:00',
    amount: 0,
    status: 'excused',
    notes: 'Auto-excused for test'
  });
  
  if (error) console.error('Error inserting:', error);
  else console.log('Successfully excused March 30th!');
}
check();
