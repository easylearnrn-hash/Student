const fs = require('fs');
const path = require('path');

const dir = '/Users/richyf/Library/Mobile Documents/com~apple~CloudDocs/COMPLETE NEW /modules';

// Files and the exact old/new strings for each
const patches = [
  {
    file: 'Calendar.html',
    old: `          if (adminError || !adminAccount) {`,
    new: `          const HARDCODED_ADMINS_CAL = ['hrachfilm@gmail.com', 'narine@arnoma.com'];
          const isHardcodedAdminCal = HARDCODED_ADMINS_CAL.includes((session.user.email || '').toLowerCase());
          if (adminError) console.warn('⚠️ admin_accounts query failed (RLS?), using hardcoded fallback');
          if (!adminAccount && !isHardcodedAdminCal) {`
  },
  {
    file: 'Email-System.html',
    old: `          if (adminError || !adminAccount) {`,
    new: `          const HARDCODED_ADMINS_ES = ['hrachfilm@gmail.com', 'narine@arnoma.com'];
          const isHardcodedAdminES = HARDCODED_ADMINS_ES.includes((session.user.email || '').toLowerCase());
          if (adminError) console.warn('⚠️ admin_accounts query failed (RLS?), using hardcoded fallback');
          if (!adminAccount && !isHardcodedAdminES) {`
  },
  {
    file: 'Group-Notes.html',
    old: `        if (adminError || !adminAccount) {`,
    new: `        const HARDCODED_ADMINS_GN = ['hrachfilm@gmail.com', 'narine@arnoma.com'];
        const isHardcodedAdminGN = HARDCODED_ADMINS_GN.includes((session.user.email || '').toLowerCase());
        if (adminError) console.warn('⚠️ admin_accounts query failed (RLS?), using hardcoded fallback');
        if (!adminAccount && !isHardcodedAdminGN) {`
  },
  {
    file: 'Notes-Manager-NEW.html',
    old: `        if (adminError || !adminAccount) {`,
    new: `        const HARDCODED_ADMINS_NM = ['hrachfilm@gmail.com', 'narine@arnoma.com'];
        const isHardcodedAdminNM = HARDCODED_ADMINS_NM.includes((session.user.email || '').toLowerCase());
        if (adminError) console.warn('⚠️ admin_accounts query failed (RLS?), using hardcoded fallback');
        if (!adminAccount && !isHardcodedAdminNM) {`
  },
  {
    file: 'Test-Manager.html',
    old: `    if (adminError || !adminAccount) {`,
    new: `    const HARDCODED_ADMINS_TM = ['hrachfilm@gmail.com', 'narine@arnoma.com'];
    const isHardcodedAdminTM = HARDCODED_ADMINS_TM.includes((session.user.email || '').toLowerCase());
    if (adminError) console.warn('⚠️ admin_accounts query failed (RLS?), using hardcoded fallback');
    if (!adminAccount && !isHardcodedAdminTM) {`
  }
];

patches.forEach(({ file, old: oldStr, new: newStr }) => {
  const filepath = path.join(dir, file);
  let content = fs.readFileSync(filepath, 'utf8');
  if (content.includes(oldStr)) {
    content = content.replace(oldStr, newStr);
    fs.writeFileSync(filepath, content);
    console.log('✅ Patched:', file);
  } else {
    console.log('⚠️ Pattern not found in:', file);
  }
});
