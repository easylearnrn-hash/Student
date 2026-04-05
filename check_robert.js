const { createClient } = require('@supabase/supabase-js');
const SUPABASE_URL = 'https://zlvnxvrzotamhpezqedr.supabase.co';
const SUPABASE_ANON_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inpsdm54dnJ6b3RhbWhwZXpxZWRyIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjI4MTEzMTcsImV4cCI6MjA3ODM4NzMxN30.-IoSqKhDrA9NuG4j3GufIbfmodWqCoppEklE1nTmw38';
const supabase = createClient(SUPABASE_URL, SUPABASE_ANON_KEY);
async function check() {
  // Check payments table for stripe payments around Apr 4
  const { data, error } = await supabase.from('payments').select('*').gte('date', '2026-04-01').order('date', {ascending: false});
  console.log('Recent payments error:', error);
  console.dir(data, {depth:null});
}
check();
