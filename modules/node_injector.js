const fs = require('fs');
const js = fs.readFileSync('./Notes/js/med-abbr-tooltip.js', 'utf8');
const updates = {
    'CN': 'Cranial Nerve',
    'UI': 'Urinary Incontinence / User Interface',
    'MG': 'Myasthenia Gravis / Milligram',
    'UV': 'Ultraviolet',
    'ART': 'Antiretroviral Therapy',
    'ASAP': 'As Soon As Possible',
    'COVID': 'Coronavirus Disease',
    'VAP': 'Ventilator-Associated Pneumonia',
    'HAP': 'Hospital-Acquired Pneumonia',
    'CAP': 'Community-Acquired Pneumonia'
};

const startStr = "var ABBR = {";
const endStr = "};";

const startIdx = js.indexOf(startStr);
const endIdx = js.indexOf(endStr, startIdx);

if (startIdx !== -1 && endIdx !== -1) {
    let dictText = js.substring(startIdx + startStr.length, endIdx);
    let toAdd = [];
    for (const [k, v] of Object.entries(updates)) {
        // match 'KEY': or 'KEY' :
        const regex = new RegExp(`'${k}'\\s*:`);
        if (!regex.test(dictText)) {
            toAdd.push(`    '${k}':${' '.repeat(10-k.length)} '${v}',`);
        }
    }
    if (toAdd.length > 0) {
        let newDict = dictText.replace(/\s*$/, '') + "\n\n    /* ── Found via General Audit ── */\n" + toAdd.join('\n') + "\n  ";
        let newJs = js.substring(0, startIdx + startStr.length) + newDict + js.substring(endIdx);
        fs.writeFileSync('./Notes/js/med-abbr-tooltip.js', newJs);
        console.log('Added ' + toAdd.length + ' terms.');
    } else {
        console.log('Nothing to add');
    }
}
