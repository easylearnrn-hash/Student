const { createClient } = require('@supabase/supabase-js');
const { readFileSync } = require('fs');

const indexHtml = readFileSync('index.html', 'utf8');
const urlMatch = indexHtml.match(/const SUPABASE_URL = '(.*?)'/);
const keyMatch = indexHtml.match(/const SUPABASE_ANON_KEY = '(.*?)'/);

const supabase = createClient(urlMatch[1], keyMatch[1]);

async function run() {
  const { data: students } = await supabase.from('students').select('*').ilike('name', '%Seda%');
  console.log("Students:", students);
  if (!students.length) return;
  const seda = students[0];
  const { data: payments } = await supabase.from('payment_records').select('*').eq('student_id', seda.id);
  const { data: auto_payments } = await supabase.from('payments').select('*').eq('student_id', seda.id);
  
  console.log("Payment Records:", payments);
  console.log("Auto Payments:", auto_payments);
}
run();
