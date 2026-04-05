const { createClient } = require('@supabase/supabase-js');
const SUPABASE_URL = 'https://ekndrsvdyajpbaghhzol.supabase.co';
const SUPABASE_SERVICE_KEY = process.env.SUPABASE_ANON_KEY; 

const supabase = createClient(SUPABASE_URL, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImVrbmRyc3ZkeWFqcGJhZ2hoem9sIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzMyNjc4NTEsImV4cCI6MjA0ODg0Mzg1MX0.VCJxi5ECgy4gCzk6UbkAJSaWBpx7_y0kZSZRgD7HkVo');

async function testFetch() {
  const { data: studentResult } = await supabase
    .from('students')
    .select('*')
    .ilike('name', '%Beatris%')
    .single();

  console.log("Student:", studentResult.name, studentResult.id);

  // Instead of querying payments (which RLS blocks for anon), let's query payment_records
  const { data: pr } = await supabase
    .from('payment_records')
    .select('*')
    .eq('student_id', studentResult.id);
  
  console.log("payment_records counts for beatris:", pr.length);

  const { data: absences } = await supabase
    .from('student_absences')
    .select('*')
    .eq('student_id', studentResult.id);
  console.log("absences for beatris:", absences.length);
}
testFetch().catch(console.error);
