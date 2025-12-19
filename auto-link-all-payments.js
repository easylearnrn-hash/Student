/**
 * AUTO-LINK ALL UNLINKED PAYMENTS
 * 
 * This script automatically links payments to students by matching payer names
 * with student names and aliases using fuzzy matching (first word is enough).
 * 
 * Usage:
 *   node auto-link-all-payments.js
 * 
 * Or run via curl to execute in Supabase:
 *   Just copy the matching logic and run manual queries
 */

const SUPABASE_URL = 'https://zlvnxvrzotamhpezqedr.supabase.co';
const SUPABASE_ANON_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inpsdm54dnJ6b3RhbWhwZXpxZWRyIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjI4MTEzMTcsImV4cCI6MjA3ODM4NzMxN30.-IoSqKhDrA9NuG4j3GufIbfmodWqCoppEklE1nTmw38';

/**
 * Normalize a name for fuzzy matching:
 * - Remove all punctuation (commas, periods, Inc, LLC, etc.)
 * - Convert to lowercase
 * - Extract first meaningful word
 */
function normalizeNameForMatching(name) {
  if (!name) return '';
  
  // Convert to lowercase and remove common business suffixes
  let normalized = name.toLowerCase()
    .replace(/\binc\.?\b/gi, '')
    .replace(/\bllc\.?\b/gi, '')
    .replace(/\bcorp\.?\b/gi, '')
    .replace(/\bconsulting\.?\b/gi, '')
    .replace(/\bmanagement\.?\b/gi, '')
    .replace(/\bservice\.?\b/gi, '')
    .replace(/\bcompany\.?\b/gi, '');
  
  // Remove all punctuation and extra spaces
  normalized = normalized
    .replace(/[,.\-&]/g, ' ')
    .replace(/\s+/g, ' ')
    .trim();
  
  // Get first meaningful word (at least 3 characters)
  const words = normalized.split(' ').filter(w => w.length >= 3);
  return words[0] || normalized;
}

/**
 * Check if two names match using fuzzy logic
 */
function namesMatch(payerName, studentNameOrAlias) {
  const normalizedPayer = normalizeNameForMatching(payerName);
  const normalizedStudent = normalizeNameForMatching(studentNameOrAlias);
  
  // Exact match after normalization
  if (normalizedPayer === normalizedStudent) return true;
  
  // First word match (most common case)
  if (normalizedPayer && normalizedStudent && normalizedPayer.startsWith(normalizedStudent)) return true;
  if (normalizedStudent && normalizedPayer && normalizedStudent.startsWith(normalizedPayer)) return true;
  
  return false;
}

/**
 * Find matching student for a payer name
 */
function findMatchingStudent(payerName, students) {
  for (const student of students) {
    // Check student name
    if (namesMatch(payerName, student.name)) {
      return student;
    }
    
    // Check aliases (can be string or array)
    if (student.aliases) {
      let aliases = [];
      
      if (typeof student.aliases === 'string') {
        // Parse if it's a JSON array string
        if (student.aliases.startsWith('[')) {
          try {
            aliases = JSON.parse(student.aliases);
          } catch {
            // Split by comma if not JSON
            aliases = student.aliases.split(',').map(a => a.trim());
          }
        } else {
          // Split by comma
          aliases = student.aliases.split(',').map(a => a.trim());
        }
      } else if (Array.isArray(student.aliases)) {
        aliases = student.aliases;
      }
      
      // Check each alias
      for (const alias of aliases) {
        if (alias && namesMatch(payerName, alias)) {
          return student;
        }
      }
    }
  }
  
  return null;
}

console.log('🔗 AUTO-LINK ALL UNLINKED PAYMENTS');
console.log('================================\n');

console.log('📋 MATCHING RULES:');
console.log('  • First word is enough (e.g., "Level" matches "Level Up Management, Inc")');
console.log('  • Ignores punctuation: , . - & etc.');
console.log('  • Ignores business words: Inc, LLC, Corp, Consulting, Management, Service');
console.log('  • Case-insensitive matching\n');

console.log('📝 MANUAL STEPS TO RUN:');
console.log('  1. Get all students: curl https://zlvnxvrzotamhpezqedr.supabase.co/rest/v1/students?select=*');
console.log('  2. Get unlinked payments: curl https://zlvnxvrzotamhpezqedr.supabase.co/rest/v1/payments?student_id=is.null');
console.log('  3. Match and update each payment\n');

console.log('🧪 TESTING MATCHING LOGIC:');
console.log('================================\n');

// Test cases
const testCases = [
  { payer: 'Level Up Management, Inc', student: 'Hasmik Antonova', alias: 'Level Up Management', expected: true },
  { payer: 'Level Up Management, Inc', student: 'Hasmik Antonova', alias: 'Level Up Management Inc', expected: true },
  { payer: 'Level Up Management, Inc', student: 'Hasmik Antonova', alias: 'Level', expected: true },
  { payer: 'N & D Marketing Service Inc', student: 'Hasmik Antonova', alias: 'N & D Marketing Service Inc', expected: true },
  { payer: 'Husikyan Consulting, Inc.', student: 'Sona Husikyan', alias: 'Husikyan Consulting', expected: true },
  { payer: 'Husikyan Consulting, Inc.', student: 'Sona Husikyan', alias: 'Husikyan', expected: true },
  { payer: 'Zhaneta Avetikyan', student: 'Janna Avetikyan', alias: 'Zhaneta Avetikyan', expected: true },
  { payer: 'Zhaneta Avetikyan', student: 'Janna Avetikyan', alias: 'Zhaneta', expected: true },
];

testCases.forEach(test => {
  const match = namesMatch(test.payer, test.alias);
  const status = match === test.expected ? '✅' : '❌';
  const normalizedPayer = normalizeNameForMatching(test.payer);
  const normalizedAlias = normalizeNameForMatching(test.alias);
  console.log(`${status} "${test.payer}" vs "${test.alias}"`);
  console.log(`   Normalized: "${normalizedPayer}" vs "${normalizedAlias}"`);
  console.log(`   Match: ${match} (Expected: ${test.expected})\n`);
});

console.log('\n✨ EXAMPLE CURL COMMANDS TO AUTO-LINK:');
console.log('================================\n');

console.log('# Example: Link "Level Up Management, Inc" to student 5 (Hasmik)');
console.log(`curl -X PATCH 'https://zlvnxvrzotamhpezqedr.supabase.co/rest/v1/payments?payer_name=eq.Level%20Up%20Management%2C%20Inc&student_id=is.null' \\
  -H "apikey: ${SUPABASE_ANON_KEY}" \\
  -H "Authorization: Bearer ${SUPABASE_ANON_KEY}" \\
  -H "Content-Type: application/json" \\
  -d '{"student_id": "5", "linked_student_id": "5", "resolved_student_name": "Hasmik Antonova"}'\n`);

console.log('\n🎯 To auto-link ALL payments, run the SQL script instead (safer and faster)');
console.log('   See: auto-link-payments.sql\n');
