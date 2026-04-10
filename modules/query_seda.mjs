const URL_BASE = 'https://zlvnxvrzotamhpezqedr.supabase.co';
const KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inpsdm54dnJ6b3RhbWhwZXpxZWRyIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjI4MTEzMTcsImV4cCI6MjA3ODM4NzMxN30.-IoSqKhDrA9NuG4j3GufIbfmodWqCoppEklE1nTmw38';

// Sign in as admin first to get JWT that passes RLS
const loginRes = await fetch(`${URL_BASE}/auth/v1/token?grant_type=password`, {
  method: 'POST',
  headers: { 'apikey': KEY, 'Content-Type': 'application/json' },
  body: JSON.stringify({ email: 'hrachfilm@gmail.com', password: process.env.ADMIN_PASS || '' })
});
const loginData = await loginRes.json();
const jwt = loginData.access_token;
if (!jwt) {
  console.log('Login failed:', JSON.stringify(loginData));
  console.log('\nUsage: ADMIN_PASS=yourpassword node --input-type=module < query_seda.mjs');
  process.exit(1);
}
console.log('Logged in OK');

const headers = { 'apikey': KEY, 'Authorization': 'Bearer ' + jwt, 'Content-Type': 'application/json' };

const r = await fetch(`${URL_BASE}/rest/v1/students?select=id,name,balance,price_per_class,status,show_in_grid`, { headers });
const all = await r.json();

console.log('Total students:', all.length);

const matches = all.filter(s =>
  s.name && (s.name.toLowerCase().includes('seda') || s.name.toLowerCase().includes('amiryan'))
);

if (matches.length === 0) {
  console.log('No seda/amiryan found. Students with non-zero balance:');
  all.filter(s => s.balance && parseFloat(s.balance) !== 0)
     .forEach(s => console.log('  ' + s.name + ' | balance: ' + s.balance + ' | price: ' + s.price_per_class + ' | status: ' + s.status));
} else {
  console.log('Found:');
  matches.forEach(s => console.log('  id:' + s.id + ' name:"' + s.name + '" balance:' + s.balance + ' price:' + s.price_per_class + ' status:' + s.status + ' show_in_grid:' + s.show_in_grid));
}
