const fs = require('fs');

const STUDENT_ALLOWED_PAGES = [
  'student-portal.html',
  'Tests-Library.html',
  'Student-Test.html',
  'Protected-PDF-Viewer.html',
  'PharmaQuest.html',
  'index.html',
  'email-confirmed.html',
  'armenian-nurses-association.html',
  'Student-Chat.html'
];

const files = fs.readdirSync('.').filter(f => f.endsWith('.html'));

let injectedCount = 0;

for (const file of files) {
  if (STUDENT_ALLOWED_PAGES.includes(file)) continue;
  
  let content = fs.readFileSync(file, 'utf8');
  
  // If it doesn't have shared-auth.js anywhere, we inject it right after <head>
  if (!content.includes('shared-auth.js')) {
    content = content.replace(/<head>/i, '<head>\n    <script src="shared-auth.js"></script>');
    fs.writeFileSync(file, content);
    console.log('Injected shared-auth in', file);
    injectedCount++;
  }
}
console.log('Total injected:', injectedCount);
