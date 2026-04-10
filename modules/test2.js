const { createClient } = require('@supabase/supabase-js');
const SUPABASE_URL = 'https://ekndrsvdyajpbaghhzol.supabase.co';
const SUPABASE_ANON_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImVrbmRyc3ZkeWFqcGJhZ2hoem9sIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzMyNjc4NTEsImV4cCI6MjA0ODg0Mzg1MX0.VCJxi5ECgy4gCzk6UbkAJSaWBpx7_y0kZSZRgD7HkVo';
const supabase = createClient(SUPABASE_URL, SUPABASE_ANON_KEY);

supabase.from('students').select('id, name, group_name').limit(5).then(({data, error}) => {
  console.log("data:", data, "error:", error);
  process.exit(0);
});
