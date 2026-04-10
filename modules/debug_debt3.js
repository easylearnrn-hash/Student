const { createClient } = require('@supabase/supabase-js');

const SUPABASE_URL = 'https://zlvnxvrzotamhpezqedr.supabase.co';
const SUPABASE_ANON_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inpsdm54dnJ6b3RhbWhwZXpxZWRyIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjI4MTEzMTcsImV4cCI6MjA3ODM4NzMxN30.-IoSqKhDrA9NuG4j3GufIbfmodWqCoppEklE1nTmw38';
const supabase = createClient(SUPABASE_URL, SUPABASE_ANON_KEY);

async function run() {
  const { data: updateData, error: updateError } = await supabase
    .from('students')
    .update({ balance: 0, price_per_class: 1 })
    .ilike('name', '%Aleksandr Petrosyan%')
    .select();
  console.log('Updated:', updateData);
}
run();
