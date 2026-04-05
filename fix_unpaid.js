const fs = require('fs');
let html = fs.readFileSync('student-portal.html', 'utf-8');

// Under calculateUnpaidFromSchedule
const oldLogic1 = `      payments.forEach(p => {
        if (p.status === 'paid' || p.status === 'credit') {
          const d = p.dateString || (p.date instanceof Date ? p.date.toISOString().split('T')[0] : (p.date||'').substring(0,10));
          if (d) paidDates.add(d);
        }
      });`;
const newLogic1 = `      payments.forEach(p => {
        if (p.status === 'paid' || p.status.startsWith('paid') || p.status === 'credit') {
          const d = p.dateString || (p.date instanceof Date ? p.date.toISOString().split('T')[0] : (p.date||'').substring(0,10));
          if (d) paidDates.add(d);
        }
      });`;
html = html.replace(oldLogic1, newLogic1);

// Under "Calculate last paid"
const oldLogic2 = `      // Calculate last paid
      payments.forEach(payment => {
        const amount = parseFloat(payment.amount) || 0;
        // 🔥 CRITICAL FIX: Include BOTH paid and credit payments
        if (payment.status === 'paid' || payment.status === 'credit') {
          if (!lastPaidDate || payment.date > lastPaidDate) {
            lastPaidDate = payment.date;
            lastPaidAmount = amount;
          }
        }
      });`;
const newLogic2 = `      // Calculate last paid
      payments.forEach(payment => {
        const amount = parseFloat(payment.amount) || 0;
        // 🔥 CRITICAL FIX: Include BOTH paid and credit payments
        if (payment.status === 'paid' || payment.status.startsWith('paid') || payment.status === 'credit') {
          if (!lastPaidDate || payment.date > lastPaidDate) {
            lastPaidDate = payment.date;
            lastPaidAmount = amount;
          }
        }
      });`;
html = html.replace(oldLogic2, newLogic2);

// Check renderPaymentList too for status detection
const oldLogic3 = `          if (isCreditPayment) {
            statusText = 'Paid from Credit';
            statusClass = 'credit';
          } else {
            switch (payment.status) {
              case 'paid':
                statusText = 'Paid';
                break;`;
const newLogic3 = `          if (isCreditPayment) {
            statusText = 'Paid from Credit';
            statusClass = 'credit';
          } else {
            // Support "paid (stripe)" statuses
            const baseStatus = payment.status.startsWith('paid') ? 'paid' : payment.status;
            switch (baseStatus) {
              case 'paid':
                statusText = 'Paid';
                break;`;
html = html.replace(oldLogic3, newLogic3);

fs.writeFileSync('student-portal.html', html);
console.log('UNPAID LOGIC FIXED');
