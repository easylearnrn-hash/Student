const fs = require('fs');

let content = fs.readFileSync('Student-Manager.html', 'utf8');

content = content.replace(/const currentPrice = s\.price_per_class \|\| 0;\s*document\.querySelectorAll\('#amountButtons \.price-btn'\)\.forEach\(btn => \{\s*const val = parseInt\(btn\.textContent\.replace\(\/[^0-9]\/g, ''\)\) \|\| 0;\s*btn\.classList\.toggle\('active', val === currentPrice\);\s*\}\);/sm, \`const currentPrice = s.price_per_class || 0;
        let foundPreset = false;
        document.querySelectorAll('#amountButtons .price-btn').forEach(btn => {
          const val = parseInt(btn.textContent.replace(/[^0-9]/g, '')) || 0;
          const isActive = val === currentPrice;
          btn.classList.toggle('active', isActive);
          if (isActive) foundPreset = true;
        });
        document.getElementById('customPriceInput').value = !foundPreset && currentPrice > 0 ? currentPrice : '';\`);

fs.writeFileSync('Student-Manager.html', content);
