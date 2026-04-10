const fs = require('fs');
const path = require('path');
const { execSync } = require('child_process');

// Find all HTML files in Notes/
const files = execSync('find Notes -type f -name "*.html"').toString().split('\n').filter(f => f.trim() !== '');

let modernized = 0;
files.forEach(f => {
  let content = fs.readFileSync(f, 'utf8');
  if (!content.includes('<div class="container">') && content.includes('<body') && content.includes('</h1>')) {
    
    // Add CSS
    if (!content.includes('.container') && content.includes('</style>')) {
      content = content.replace('</style>', '  .container { max-width: 900px; margin: 0 auto; }\n</style>');
    }
    
    // Wrap body content
    const bodyStart = content.indexOf('<body>');
    if (bodyStart !== -1) {
      // Find the first element after body
      const afterBody = content.substring(bodyStart + 6);
      if (afterBody.trim().startsWith('<a')) {
         // It has a back button, put container after body
         content = content.replace('<body>', '<body>\n<div class="container">');
         content = content.replace('</body>', '</div>\n</body>');
         fs.writeFileSync(f, content);
         modernized++;
      } else if (afterBody.trim().startsWith('<h1')) {
         content = content.replace('<body>', '<body>\n<div class="container">');
         content = content.replace('</body>', '</div>\n</body>');
         fs.writeFileSync(f, content);
         modernized++;
      }
    }
  }
});
console.log(`Added container to ${modernized} notes.`);
