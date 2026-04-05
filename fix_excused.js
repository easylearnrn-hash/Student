const fs = require('fs');

let content = fs.readFileSync('Calendar-NEW.html', 'utf8');

// I will add a new status logic for "excused".
// The user wants to:
// 1. "excuse the debt of 5 students on March 5th" (individual student level)
// 2. "or all march 5th students are excused and dont need payment done" (day level)
