const fs = require('fs');

let content = fs.readFileSync('Student-Manager.html', 'utf8');

const regex = /function selectAmount\(amount, btn\) \{[\s\S]*?renderStudentCards\(\);\s*\}\s*\}/;

const newCode = `function selectAmount(amount, btn) {
          // Remove active from all amount buttons
          document.querySelectorAll('#amountButtons .price-btn').forEach(b => b.classList.remove('active'));
          btn.classList.add('active');
          document.getElementById('customPriceInput').value = '';

          if (currentStudent) {
            // Parse amount if it's a string like "100 $"
            const numericAmount = typeof amount === 'string'
              ? parseInt(amount.replace(/[^0-9]/g, '')) || 0
              : amount;
            
            currentStudent.price_per_class = numericAmount;
            document.getElementById('modalPrice').textContent = formatPrice(numericAmount);
            debugLog(\`Price per class changed to: \${numericAmount}\`);
            saveStudent(currentStudent);
            renderStudentCards();
          }
        }

        function selectCustomAmount(amount) {
          const numericAmount = parseInt(amount) || 0;
          document.querySelectorAll('#amountButtons .price-btn').forEach(b => b.classList.remove('active'));
          document.getElementById('customPriceInput').value = amount ? numericAmount : '';

          if (currentStudent) {
            currentStudent.price_per_class = numericAmount;
            document.getElementById('modalPrice').textContent = formatPrice(numericAmount);
            debugLog(\`Price per class changed to custom: \${numericAmount}\`);
            saveStudent(currentStudent);
            renderStudentCards();
          }
        }`;

content = content.replace(regex, newCode);
fs.writeFileSync('Student-Manager.html', content);
