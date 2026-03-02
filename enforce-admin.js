const fs = require('fs');
const glob = require('glob'); // Need to check if available, or just use fs.readdirSync
const files = fs.readdirSync('.').filter(f => f.endsWith('.html'));

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

for (const file of files) {
  if (STUDENT_ALLOWED_PAGES.includes(file)) continue;

  let content = fs.readFileSync(file, 'utf8');
  
  // Find where they do getSession()
  let modified = false;
  
  // Replace direct supabaseClient.auth.getSession check to include hrachfilm check
  const checkSessionRegex = /if\s*\(\s*sessionError\s*\|\|\s*!session\s*\)/g;
  if (checkSessionRegex.test(content)) {
    content = content.replace(checkSessionRegex, `if (sessionError || !session || session?.user?.email?.toLowerCase() !== 'hrachfilm@gmail.com')`);
    modified = true;
  }
  
  const checkSessionRegex2 = /if\s*\(\s*!session\s*\)/g;
  // Be careful with replacing this randomly. Let's instead inject a script block in HEAD of all admin pages.
  
  if (modified) {
    fs.writeFileSync(file, content);
    console.log('Modified', file);
  }
}
