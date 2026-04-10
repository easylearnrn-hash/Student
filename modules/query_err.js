const { createClient } = require('@supabase/supabase-js');
const SUPABASE_URL = 'https://ekndrsvdyajpbaghhzol.supabase.co';
const SUPABASE_ANON_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImVrbmRyc3ZkeWFqcGJhZ2hoem9sIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzMyNjc4NTEsImV4cCI6MjA0ODg0Mzg1MX0.VCJxi5ECgy4gCzk6UbkAJSaWBpx7_y0kZSZRgD7HkVo';
const sb = createClient(SUPABASE_URL, SUPABASE_ANON_KEY);
async function run() {
  const stRes = await sb.from('students').select('id, name, group_name');
  console.log(stRes.error);
}
run();
