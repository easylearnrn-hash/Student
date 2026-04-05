const fs = require('fs');
let html = fs.readFileSync('Student-Manager.html', 'utf-8');

const oldLogic = `        // Price buttons
        const currentPrice = s.price_per_class || 0;
        document.querySelectorAll('#amountButtons .price-btn').forEach(btn => {
          const val = parseInt(btn.textContent.replace(/[^0-9]/g, '')) || 0;
          btn.classList.toggle('active', val === currentPrice);
        });`;

const newLogic = `        // Price buttons
        const currentPrice = s.price_per_class || 0;
        let presetFound = false;
        document.querySelectorAll('#amountButtons .price-btn').forEach(btn => {
          const val = parseInt(btn.textContent.replace(/[^0-9]/g, '')) || 0;
          if (val === currentPrice) {
            btn.classList.add('active');
            presetFound = true;
          } else {
            btn.classList.remove('active');
          }
        });
        
        const customInput = document.getElementById('customPriceInput');
        if (customInput) {
          if (!presetFound && currentPrice > 0) {
            customInput.value = currentPrice;
            customInput.classList.add('active');
          } else {
            customInput.value = '';
            customInput.classList.remove('active');
          }
        }`;

if (html.includes(oldLogic)) {
    html = html.replace(oldLogic, newLogic);
    fs.writeFileSync('Student-Manager.html', html);
    console.log('REPLACED');
} else {
    console.log('NOT FOUND');
}
