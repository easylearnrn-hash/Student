const fs = require('fs');

let content = fs.readFileSync('Group-Notes.html', 'utf8');

const regex = /if \(orderByObj\) query = query\.order\(orderByObj\.col, \{ ascending: orderByObj\.asc \}\);/;
const replacement = `if (orderByObj) {
          query = query.order(orderByObj.col, { ascending: orderByObj.asc });
        } else {
          // CRITICAL: Without an explicit order, Postgres/Supabase pagination can randomly skip records!
          query = query.order('id', { ascending: true });
        }`;

content = content.replace(regex, replacement);

fs.writeFileSync('Group-Notes.html', content);
console.log('Fixed fetchAll ordering bug in Group-Notes.html');
