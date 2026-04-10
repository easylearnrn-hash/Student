const fs = require('fs');
let code = fs.readFileSync('Calendar-NEW.html', 'utf8');

// Also exclude graduated
code = code.replace(
    /s\.status !== 'paused'/g,
    "s.status !== 'paused' && s.status !== 'graduated'"
);

code = code.replace(
    /student\.status !== 'paused'/g,
    "student.status !== 'paused' && student.status !== 'graduated'"
);

code = code.replace(
    /student\.status === 'paused'/g,
    "(student.status === 'paused' || student.status === 'graduated')"
);

fs.writeFileSync('Calendar-NEW.html', code);
console.log('Fixed calendar dots for graduated too');
