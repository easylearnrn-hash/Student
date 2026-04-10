const SUPABASE_URL = 'https://zlvnxvrzotamhpezqedr.supabase.co';
const SUPABASE_ANON_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inpsdm54dnJ6b3RhbWhwZXpxZWRyIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjI4MTEzMTcsImV4cCI6MjA3ODM4NzMxN30.-IoSqKhDrA9NuG4j3GufIbfmodWqCoppEklE1nTmw38';

async function run() {
  // Find Maternal Health notes
  const res = await fetch(`${SUPABASE_URL}/rest/v1/student_notes?select=*`, {
    headers: {
      'apikey': SUPABASE_ANON_KEY,
      'Authorization': `Bearer ${SUPABASE_ANON_KEY}`
    }
  });
  const allNotes = await res.json();
  const maternalNotes = allNotes.filter(n => 
    (n.title && n.title.includes('Maternal')) || 
    (n.system_category && n.system_category.includes('Maternal')) || 
    (n.category && n.category.includes('Maternal'))
  );
  
  console.log(`Found ${maternalNotes.length} Maternal Health notes in DB out of ${allNotes.length} total notes.`);
  if (maternalNotes.length > 0) {
    console.log("Sample:", {
      id: maternalNotes[0].id,
      title: maternalNotes[0].title,
      category: maternalNotes[0].category,
      system_category: maternalNotes[0].system_category,
      group_name: maternalNotes[0].group_name
    });
    
    // Check permissions for first note
    const res2 = await fetch(`${SUPABASE_URL}/rest/v1/student_note_permissions?note_id=eq.${maternalNotes[0].id}`, {
      headers: {
        'apikey': SUPABASE_ANON_KEY,
        'Authorization': `Bearer ${SUPABASE_ANON_KEY}`
      }
    });
    const perms = await res2.json();
    console.log(`Permissions for note ${maternalNotes[0].id}:`, perms);
  }
}
run();
