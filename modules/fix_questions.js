const { createClient } = require('@supabase/supabase-js');
const SUPABASE_URL = 'https://zlvnxvrzotamhpezqedr.supabase.co';
const SUPABASE_ANON_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZ' + 'SIsInJlZiI6Inpsdm54dnJ6b3RhbWhwZXpxZWRyIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjI4MTEzMTcsImV4cCI6MjA3ODM4NzMxN30.-IoSqKhDrA9NuG4j3GufIbfmodWqCoppEklE1nTmw38';

const supabase = createClient(SUPABASE_URL, SUPABASE_ANON_KEY);
async function run() {
  const { data, error } = await supabase.from('test_questions').insert([{
    question: 'Test',
    question_stem: 'Test',
    options: {"A": "1"},
    correct_answer: '["A"]',
    category: 'EKG',
    test_id: 1,
    topic_id: 'a0000000-0000-0000-0000-000000000000',
    display_order: 1
  }]);
  console.log('Result:', error || data);
}
run();
