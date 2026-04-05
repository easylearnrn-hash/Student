const { createClient } = require('@supabase/supabase-js');

const SUPABASE_URL = 'https://zlvnxvrzotamhpezqedr.supabase.co';
const SUPABASE_ANON_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inpsdm54dnJ6b3RhbWhwZXpxZWRyIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjI4MTEzMTcsImV4cCI6MjA3ODM4NzMxN30.-IoSqKhDrA9NuG4j3GufIbfmodWqCoppEklE1nTmw38';
const supabase = createClient(SUPABASE_URL, SUPABASE_ANON_KEY);

async function run() {
  const { data, error } = await supabase
    .from('students')
    .select('id, name, balance')
    .ilike('name', '%Aleksandr Petrosyan%');
    
  if (error) console.error(error);
  else console.log('Found:', data);
  
  if (data && data.length > 0) {
    const student = data[0];
    console.log(`Setting balance to -1 for ${student.name}`);
    const { data: updateData, error: updateError } = await supabase
      .from('students')
      .update({ balance: -1 })
      .eq('id', student.id)
      .select();
      
    if (updateError) console.error(updateError);
    else console.log('Updated:', updateData);
  }
}
run();
