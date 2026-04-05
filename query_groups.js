const { createClient } = require('@supabase/supabase-js');
const SUPABASE_URL = 'https://zlvnxvrzotamhpezqedr.supabase.co';
const SUPABASE_ANON_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inpsdm54dnJ6b3RhbWhwZXpxZWRyIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjI4MTEzMTcsImV4cCI6MjA3ODM4NzMxN30.-IoSqKhDrA9NuG4j3GufIbfmodWqCoppEklE1nTmw38';
const supabaseClient = createClient(SUPABASE_URL, SUPABASE_ANON_KEY);

async function run() {
  const { count } = await supabaseClient.from('student_note_permissions').select('*', { count: 'exact', head: true });
  console.log('Count:', count);
  const { data } = await supabaseClient.from('student_notes').select('id').limit(1);
  console.log('Notes:', data);
}
run();
