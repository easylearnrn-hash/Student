const fs = require('fs');
let html = fs.readFileSync('student-portal.html', 'utf-8');

html = html.replace('const cacheKey = `payments-v10-${student.id}`;', 'const cacheKey = `payments-v11-${student.id}`;');

fs.writeFileSync('student-portal.html', html);
console.log('CACHE KEY BUMPED');
