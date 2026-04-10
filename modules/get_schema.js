const SUPABASE_ANON_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZ' + 'SIsInJlZiI6Inpsdm54dnJ6b3RhbWhwZXpxZWRyIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjI4MTEzMTcsImV4cCI6MjA3ODM4NzMxN30.-IoSqKhDrA9NuG4j3GufIbfmodWqCoppEklE1nTmw38';

async function run() {
  const res = await fetch('https://zlvnxvrzotamhpezqedr.supabase.co/rest/v1/', {
    headers: { apikey: SUPABASE_ANON_KEY }
  });
  const data = await res.json();
  console.log(Object.keys(data.definitions.test_questions.properties));
}
run();
