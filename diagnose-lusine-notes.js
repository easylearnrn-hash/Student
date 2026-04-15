/**
 * Diagnose why notes are not showing for a specific student.
 * Run with: node diagnose-lusine-notes.js
 * 
 * Checks:
 *  1. Student record + group
 *  2. student_note_permissions rows for the group
 *  3. note_free_access rows for the group
 *  4. student_notes rows accessible
 *  5. Which RLS policies are active
 */

const { createClient } = require('@supabase/supabase-js');

const SUPABASE_URL = 'https://zlvnxvrzotamhpezqedr.supabase.co';
// Use service_role key to bypass RLS for diagnosis
const SERVICE_ROLE_KEY = process.env.SUPABASE_SERVICE_ROLE_KEY;

if (!SERVICE_ROLE_KEY) {
  console.error('ERROR: Set SUPABASE_SERVICE_ROLE_KEY env var first:');
  console.error('  export SUPABASE_SERVICE_ROLE_KEY="your-service-role-key"');
  console.error('  node diagnose-lusine-notes.js "Lusine Julhakyan"');
  process.exit(1);
}

const supabase = createClient(SUPABASE_URL, SERVICE_ROLE_KEY);

const STUDENT_NAME = process.argv[2] || 'Lusine Julhakyan';

async function run() {
  console.log(`\n=== Diagnosing notes for: ${STUDENT_NAME} ===\n`);

  // 1. Student record
  const { data: students, error: sErr } = await supabase
    .from('students')
    .select('id, name, group_name, email, start_date, created_at, auth_user_id')
    .ilike('name', `%${STUDENT_NAME.split(' ')[1] || STUDENT_NAME}%`);

  if (sErr || !students?.length) {
    console.error('Student not found:', sErr?.message || 'no match');
    return;
  }

  const student = students[0];
  console.log('✅ Student found:');
  console.log('   ID:', student.id, '| Name:', student.name);
  console.log('   Group:', student.group_name, '| Email:', student.email);
  console.log('   Start date:', student.start_date, '| Created:', student.created_at?.split('T')[0]);
  console.log('   Has auth_user_id:', !!student.auth_user_id);

  const groupLetter = student.group_name?.replace(/Group\s*/i, '').trim().toUpperCase();
  const groupCandidates = [groupLetter, `Group ${groupLetter}`].filter(Boolean);
  console.log('\n   Querying with group candidates:', groupCandidates);

  // 2. student_note_permissions (bypassing RLS with service role)
  const { data: groupPerms, error: gpErr } = await supabase
    .from('student_note_permissions')
    .select('id, note_id, group_name, is_accessible, class_date, student_id')
    .is('student_id', null)
    .eq('is_accessible', true)
    .in('group_name', groupCandidates);

  console.log('\n📋 student_note_permissions (group rows, no RLS):');
  if (gpErr) {
    console.error('   ERROR:', gpErr.message);
    console.error('   Code:', gpErr.code, '| Hint:', gpErr.hint);
  } else {
    console.log('   Count:', groupPerms?.length || 0);
    if (groupPerms?.length) {
      console.log('   Sample (first 3):', groupPerms.slice(0, 3).map(p => ({
        note_id: p.note_id, group_name: p.group_name, class_date: p.class_date
      })));
    } else {
      console.log('   ⚠️  NO GROUP PERMISSIONS FOUND — notes will never appear!');
      console.log('   Admin needs to post notes to Group', groupLetter, 'in Group-Notes.html');
    }
  }

  // Check if class_date column exists on student_note_permissions (error will say 42703 if missing)
  const { error: cdErr } = await supabase
    .from('student_note_permissions')
    .select('class_date')
    .limit(1);
  console.log('\n   student_note_permissions.class_date column exists:', !cdErr);
  if (cdErr) console.log('   Error:', cdErr.message, '| Code:', cdErr.code);

  // 3. note_free_access
  const { data: freeGroup, error: fgErr } = await supabase
    .from('note_free_access')
    .select('id, note_id, group_letter, access_type, class_date, created_at')
    .eq('access_type', 'group')
    .eq('group_letter', groupLetter);

  console.log('\n🔓 note_free_access (group rows, no RLS):');
  if (fgErr) {
    console.error('   ERROR:', fgErr.message, '| Code:', fgErr.code);
    if (fgErr.code === '42703') {
      console.error('   ⚠️  class_date COLUMN DOES NOT EXIST in note_free_access!');
      console.error('   Run: ALTER TABLE note_free_access ADD COLUMN IF NOT EXISTS class_date DATE;');
    }
  } else {
    console.log('   Count:', freeGroup?.length || 0);
    if (freeGroup?.length) {
      console.log('   Sample (first 3):', freeGroup.slice(0, 3).map(f => ({
        note_id: f.note_id, group_letter: f.group_letter, class_date: f.class_date
      })));
    }
  }

  // 4. student_notes accessible via permissions
  const permNoteIds = (groupPerms || []).map(p => p.note_id);
  const freeNoteIds = (freeGroup || []).map(f => f.note_id);
  const allNoteIds = [...new Set([...permNoteIds, ...freeNoteIds])];

  console.log('\n📚 student_notes accessible:');
  console.log('   From permissions:', permNoteIds.length, 'IDs');
  console.log('   From free access:', freeNoteIds.length, 'IDs');
  console.log('   Total unique:', allNoteIds.length);

  if (allNoteIds.length > 0) {
    const { data: notes, error: nErr } = await supabase
      .from('student_notes')
      .select('id, title, group_name, class_date, requires_payment, deleted')
      .in('id', allNoteIds)
      .eq('deleted', false);
    console.log('   Actual notes found:', notes?.length || 0, nErr ? '(error: ' + nErr.message + ')' : '');
    if (notes?.length) {
      console.log('   Sample (first 3):', notes.slice(0, 3).map(n => ({
        id: n.id, title: n.title, class_date: n.class_date
      })));
    }
  }

  // 5. RLS policies active
  const { data: policies, error: pErr } = await supabase
    .rpc('pg_catalog.pg_policies', {})
    .or(`tablename.eq.student_note_permissions,tablename.eq.note_free_access,tablename.eq.student_notes`)
    .select('tablename,policyname,cmd')
    .limit(30);

  if (!pErr && policies) {
    console.log('\n🔐 Active RLS policies:');
    policies.forEach(p => console.log(`   [${p.tablename}] ${p.cmd} — ${p.policyname}`));
  }

  // Check RLS via information_schema
  const { data: rlsCheck } = await supabase
    .from('student_note_permissions')
    .select('id')
    .is('student_id', null)
    .limit(1);

  console.log('\n✨ Summary:');
  if (!groupPerms?.length) {
    console.log('❌ NO group permissions exist — admin must post notes to Group', groupLetter);
  } else if (fgErr?.code === '42703') {
    console.log('❌ class_date column missing in note_free_access — run ALTER TABLE fix');
  } else {
    console.log('✅ Data exists. If notes still not showing for real student (not admin), RLS policy may be blocking group rows.');
    console.log('   → Run FIX-RLS-GROUP-NAME-MATCH.sql in Supabase SQL Editor');
  }
}

run().catch(console.error);
