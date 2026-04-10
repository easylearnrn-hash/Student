const fs = require('fs');

const path = '/Users/richyf/Library/Mobile Documents/com~apple~CloudDocs/COMPLETE NEW /modules/Student-Portal-Admin.html';
let content = fs.readFileSync(path, 'utf8');

if (!content.includes("if (new URLSearchParams(window.location.search).get('select_student') === 'true') {")) {
  content = content.replace("document.addEventListener('DOMContentLoaded', async () => {", 
    "document.addEventListener('DOMContentLoaded', async () => {\n      // Check if we just exited impersonation mode\n      if (new URLSearchParams(window.location.search).get('select_student') === 'true') {\n        // Give auth a moment to settle, then show selector\n        setTimeout(() => {\n          if (typeof showStudentSelectorModal === 'function') {\n            showStudentSelectorModal();\n          }\n        }, 800);\n      }\n"
  );
  fs.writeFileSync(path, content);
  console.log("Updated Student-Portal-Admin.html successfully!");
} else {
  console.log("Student-Portal-Admin.html already has the auto-open logic.");
}
