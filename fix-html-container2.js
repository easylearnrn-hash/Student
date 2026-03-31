const fs = require('fs');
const { execSync } = require('child_process');

const files = execSync('find Notes -type f -name "*.html"').toString().split('\n').filter(f => f.trim());

let changed = 0;
for (const f of files) {
  let content = fs.readFileSync(f, 'utf8');
  if (!content.includes('<body')) continue;
  
  if (!content.includes('class="container"')) {
    // Add CSS rule if missing
    if (!content.includes('.container') && content.includes('</style>')) {
      content = content.replace('</style>', '  .container { max-width: 900px; margin: 0 auto; }\n</style>');
    }
    
    // Replace <body>
    const bodyMatch = content.match(/<body[^>]*>/);
    if (bodyMatch) {
      content = content.replace(bodyMatch[0], bodyMatch[0] + '\n<div class="container">');
      
      // Replace </body> - carefully match the LAST </body>
      const lastBodyIndex = content.lastIndexOf('</body>');
      if (lastBodyIndex !== -1) {
        content = content.substring(0, lastBodyIndex) + '</div>\n' + content.substring(lastBodyIndex);
        fs.writeFileSync(f, content);
        changed++;
        console.log(`Updated ${f}`);
      }
    }
  }
}
console.log(`Total changed: ${changed}`);
