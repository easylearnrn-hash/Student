const fs = require('fs');

async function run() {
    const html = fs.readFileSync('Calendar-NEW.html', 'utf8');
    const urlMatch = html.match(/const SUPABASE_URL *= *['"](.*?)['"]/);
    const keyMatch = html.match(/const SUPABASE_ANON_KEY *= *['"](.*?)['"]/);

    const URL = urlMatch[1];
    const KEY = keyMatch[1];
    
    const headers = {
        'apikey': KEY,
        'Authorization': `Bearer ${KEY}`,
        'Content-Type': 'application/json'
    };
    
    const res = await fetch(`${URL}/rest/v1/students?select=*`, {headers});
    const students = await res.json();
    
    if (!Array.isArray(students)) {
        console.log("Students is not array:", students);
        return;
    }
    
    const target = students.find(s => (s.name || '').toLowerCase().includes('amiryan'));
    if (!target) {
        console.log("Amiryan not found. Here are all names:");
        students.forEach(s => console.log(s.name));
        return;
    }
    
    console.log("Current target:", target.id, target.name, "Balance:", target.balance);
    
    const pRes = await fetch(`${URL}/rest/v1/payment_records?student_id=eq.${target.id}`, {headers});
    const payments = await pRes.json();
    console.log("Unpaid Payments in records:");
    for (const p of payments) {
        if (p.status !== 'paid') {
           console.log(`  ${p.date}: ${p.status} - $${p.amount}`);
        }
    }
}
run();
