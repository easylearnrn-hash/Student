const fs = require('fs');
let content = fs.readFileSync('Student-Manager.html', 'utf8');

// 1. Add input to HTML
content = content.replace(
  /<button class="price-btn" onclick="selectAmount\('100 \$', this\)">\$100<\/button>/,
  `<button class="price-btn" onclick="selectAmount('100 $', this)">$100</button>
                    <input type="number" id="customPriceInput" class="profile-field-input" 
                           placeholder="Custom $" 
                           oninput="this.value = this.value.replace(/[^0-9]/g, '')"
                           onchange="selectCustomAmount(this.value)" 
                           style="width: 90px; height: 35px; padding: 0 12px; border-radius: 10px; background: rgba(255,252,240,0.04); font-size: 13px; font-weight: 600; color: var(--gold); border: 1px solid rgba(196,164,95,0.2); outline: none;">`
);

// 2. Modify selectAmount to clear custom input
const selectAmountRegex = /function selectAmount\(amount, btn\) \{[\s\S]*?document\.querySelectorAll\('#amountButtons \.price-btn'\)\.forEach\(b => b\.classList\.remove\('active'\)\);[\s\S]*?btn\.classList\.add\('active'\);/;
const selectAmountNew = `function selectAmount(amount, btn) {
          // Remove active from all amount buttons
          document.querySelectorAll('#amountButtons .price-btn').forEach(b => b.classList.remove('active'));
          btn.classList.add('active');
          const customInput = document.getElementById('customPriceInput');
          if (customInput) customInput.value = '';`;
content = content.replace(selectAmountRegex, selectAmountNew);

// 3. Add selectCustomAmount function
content = content.replace(
  /function selectAmount\(amount, btn\) \{/,
  `function selectCustomAmount(amount) {
          document.querySelectorAll('#amountButtons .price-btn').forEach(b => b.classList.remove('active'));
          if (currentStudent) {
            const numericAmount = parseInt(amount) || 0;
            currentStudent.price_per_class = numericAmount;
            document.getElementById('modalPrice').textContent = formatPrice(numericAmount);
            saveStudent(currentStudent);
            renderStudentCards();
          }
        }

        function selectAmount(amount, btn) {`
);

// 4. Populate custom input inside openEditModal
const editModalRegex = /\/\/ Price buttons\s*const currentPrice = s\.price_per_class \|\| 0;\s*document\.querySelectorAll\('#amountButtons \.price-btn'\)\.forEach\(btn => \{\s*const val = parseInt\(btn\.textContent\.replace\(\/\[\^0-9\]\/g, ''\)\) \|\| 0;\s*btn\.classList\.toggle\('active', val === currentPrice\);\s*\}\);/;
const editModalNew = `// Price buttons
          const currentPrice = s.price_per_class || 0;
          let foundPreset = false;
          document.querySelectorAll('#amountButtons .price-btn').forEach(btn => {
            const val = parseInt(btn.textContent.replace(/[^0-9]/g, '')) || 0;
            if (val === currentPrice) {
               btn.classList.toggle('active', true);
               foundPreset = true;
            } else {
               btn.classList.toggle('active', false);
            }
          });
          const customPriceInput = document.getElementById('customPriceInput');
          if (customPriceInput) {
            customPriceInput.value = foundPreset ? '' : (currentPrice > 0 ? currentPrice : '');
          }`;

content = content.replace(editModalRegex, editModalNew);

fs.writeFileSync('Student-Manager.html', content);
