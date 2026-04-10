const fs = require('fs');
const path = require('path');

const HARDCODED_FALLBACK = `
          // Hardcoded fallback — RLS can block admin_accounts reads even for valid admins
          const HARDCODED_ADMINS = ['hrachfilm@gmail.com', 'narine@arnoma.com'];
          const isHardcodedAdmin = HARDCODED_ADMINS.includes((session.user.email || '').toLowerCase());
          if (adminError) console.warn('⚠️ admin_accounts query failed (RLS?), using hardcoded fallback:', adminError.message);
          if (!adminAccount && !isHardcodedAdmin) {`;

const files = [
  'Calendar-NEW.html',
];

const dir = '/Users/richyf/Library/Mobile Documents/com~apple~CloudDocs/COMPLETE NEW /modules';

files.forEach(filename => {
  const filepath = path.join(dir, filename);
  let content = fs.readFileSync(filepath, 'utf8');

  // Pattern: if (adminError || !adminAccount) {
  const oldPattern = `          if (adminError || !adminAccount) {`;
  if (content.includes(oldPattern)) {
    // Insert the hardcoded check BEFORE the if block
    content = content.replace(
      `          const { data: adminAccount, error: adminError } = await supabaseClient
            .from('admin_accounts')
            .select('*')
            .eq('auth_user_id', session.user.id)
            .single();

          if (adminError || !adminAccount) {`,
      `          const { data: adminAccount, error: adminError } = await supabaseClient
            .from('admin_accounts')
            .select('*')
            .eq('auth_user_id', session.user.id)
            .single();
${HARDCODED_FALLBACK}`
    );
    fs.writeFileSync(filepath, content);
    console.log('✅ Patched:', filename);
  } else {
    console.log('⚠️ Pattern not found in:', filename);
  }
});
