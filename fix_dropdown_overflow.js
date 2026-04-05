const fs = require('fs');

let content = fs.readFileSync('Group-Notes.html', 'utf8');

const regex = /\/\/ Anti-overflow logic - ensure it doesn't drop below screen[\s\S]*?currentAccessDropdownDiv\.innerHTML = '<div style="text-align:center; color:#888; font-size:12px; padding:10px;">Loading access data...<\/div>';/g;

const newCode = `// Reset styling to downward default initially
  currentAccessDropdownDiv.style.top = '100%';
  currentAccessDropdownDiv.style.bottom = 'auto';
  currentAccessDropdownDiv.style.marginTop = '8px';
  currentAccessDropdownDiv.style.marginBottom = '0';
  currentAccessDropdownDiv.innerHTML = '<div style="text-align:center; color:#888; font-size:12px; padding:10px;">Loading access data...</div>';`;

content = content.replace(regex, newCode);

const regex2 = /currentAccessDropdownDiv\.innerHTML = html;\s*\} catch\(e\)/;
const newCode2 = `currentAccessDropdownDiv.innerHTML = html;
    
    // Anti-overflow logic - ensure it doesn't drop below screen NOW that content is rendered
    setTimeout(() => {
      const rect = currentAccessDropdownDiv.getBoundingClientRect();
      if (rect.bottom > (window.innerHeight || document.documentElement.clientHeight)) {
         currentAccessDropdownDiv.style.top = 'auto';
         currentAccessDropdownDiv.style.bottom = '100%';
         currentAccessDropdownDiv.style.marginBottom = '8px';
         currentAccessDropdownDiv.style.marginTop = '0';
      }
    }, 10); // Small delay to let browser reflow
  } catch(e)`;

content = content.replace(regex2, newCode2);

fs.writeFileSync('Group-Notes.html', content);
