import re

with open("student-portal.html", "r") as f:
    content = f.read()

# Replace the deduplication logic to ONLY key by DATE, and if it's already there but the new one is 'paid', override it.
pattern = r"const uniqueEntryMap = new Map\(\);\s*const toDateKey = \(dateObj\) => \{.*?\};\s*allEntries\.forEach\(entry => \{.*?\s*\}\);\s*const uniqueEntries = Array\.from\(uniqueEntryMap\.values\(\)\);"

replacement = """      const uniqueEntryMap = new Map();
      const toDateKey = (dateObj) => {
        if (!(dateObj instanceof Date) || isNaN(dateObj)) return 'invalid-date';
        return `${dateObj.getFullYear()}-${String(dateObj.getMonth() + 1).padStart(2, '0')}-${String(dateObj.getDate()).padStart(2, '0')}`;
      };
      
      allEntries.forEach(entry => {
        const dateKey = toDateKey(entry.date);
        
        // Ensure "Excused" strings are universally masked as "Paid"
        if (entry.statusText && entry.statusText.toUpperCase().includes('EXCUSED')) {
          entry.statusText = 'Paid';
          entry.statusClass = 'paid';
        }
        
        // Priority list: paid/credit > absent > unpaid/pending
        const getPriority = (statusClass) => {
          if (statusClass === 'paid' || statusClass === 'credit') return 3;
          if (statusClass === 'absent') return 2;
          return 1; // unpaid, pending, unknown
        };
        
        if (!uniqueEntryMap.has(dateKey)) {
          uniqueEntryMap.set(dateKey, entry);
        } else {
          // If we already have this date, only override if the new entry has higher priority (e.g. Paid overrides Unpaid)
          const existing = uniqueEntryMap.get(dateKey);
          if (getPriority(entry.statusClass) > getPriority(existing.statusClass)) {
            uniqueEntryMap.set(dateKey, entry);
          }
        }
      });
      const uniqueEntries = Array.from(uniqueEntryMap.values());"""

new_content = re.sub(pattern, replacement, content, count=1, flags=re.DOTALL)

with open("student-portal.html", "w") as f:
    f.write(new_content)

