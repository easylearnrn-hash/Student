const SUPABASE_URL = 'https://zlvnxvrzotamhpezqedr.supabase.co';
const SUPABASE_ANON_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inpsdm54dnJ6b3RhbWhwZXpxZWRyIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjI4MTEzMTcsImV4cCI6MjA3ODM4NzMxN30.-IoSqKhDrA9NuG4j3GufIbfmodWqCoppEklE1nTmw38';

async function run() {
  const res = await fetch(`${SUPABASE_URL}/rest/v1/student_note_permissions?select=*&group_name=eq.E`, {
    headers: {
      'apikey': SUPABASE_ANON_KEY,
      'Authorization': `Bearer ${SUPABASE_ANON_KEY}`
    }
  });
  const data = await res.json();
  console.log("Permissions for group E:", data.length);
  
  const res2 = await fetch(`${SUPABASE_URL}/rest/v1/student_note_permissions?select=*&group_name=eq.Group%20E`, {
    headers: {
      'apikey': SUPABASE_ANON_KEY,
      'Authorization': `Bearer ${SUPABASE_ANON_KEY}`
    }
  });
  const data2 = await res2.json();
  console.log("Permissions for Group E:", data2.length);

  const res3 = await fetch(`${SUPABASE_URL}/rest/v1/student_notes?select=*&system_category=eq.Maternal%20Health`, {
    headers: {
      'apikey': SUPABASE_ANON_KEY,
      'Authorization': `Bearer ${SUPABASE_ANON_KEY}`
    }
  });
  const data3 = await res3.json();
  console.log("Maternal Health notes:", data3.length);
}

run();
