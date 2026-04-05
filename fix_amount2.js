const fs = require('fs');

let content = fs.readFileSync('Student-Manager.html', 'utf8');

content = content.replace(/function selectCustomAmount.*?function selectCustomAmount/s, 'function selectCustomAmount');
fs.writeFileSync('Student-Manager.html', content);
