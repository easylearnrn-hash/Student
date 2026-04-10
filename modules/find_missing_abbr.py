import glob
import re
from collections import Counter

with open('./Notes/js/med-abbr-tooltip.js', 'r') as f:
    js_code = f.read()

start_idx = js_code.find('var ABBR = {')
end_idx = js_code.find('};', start_idx) + 2
abbr_text = js_code[start_idx:end_idx]

existing_abbrs = set()
for m in re.finditer(r"^\s*'([A-Za-z0-9\.\-\½\&]+)'\s*:", abbr_text, re.MULTILINE):
    existing_abbrs.add(m.group(1))

ignore_words = {'AND', 'OR', 'THE', 'TO', 'OF', 'IN', 'FOR', 'WITH', 'ON', 'AT', 'BY', 'AN', 'IS', 'AS', 'NO', 'NOT', 'DO', 'IF', 'IT', 'BE', 'ARE', 'HE', 'SHE', 'WE', 'THEY', 'THIS', 'THAT', 'BUT', 'ALL', 'ANY', 'OUT', 'UP', 'SO', 'MAY', 'CAN', 'HAS', 'HAD', 'WAS', 'WERE', 'FROM', 'VERY', 'MANY', 'ALSO', 'ONLY', 'SOME', 'SUCH', 'THAN', 'THEN', 'WHEN', 'THEN', 'HAVE', 'WHICH', 'WHAT', 'WHO', 'WHOM', 'HOW', 'WHY', 'WHERE', 'TRUE', 'FALSE', 'YES', 'RN', 'PN', 'MD', 'DO', 'HTML', 'CSS', 'JS', 'URL', 'PDF', 'NA', 'KEY', 'SEE', 'HIGH', 'LOW', 'NEW', 'OLD', 'RED', 'BLUE'}

html_files = glob.glob('Notes/**/*.html', recursive=True)
abbr_counter = Counter()
pattern = re.compile(r'\b[A-Z][A-Z0-9-]{1,5}\b')

for file in html_files:
    if "Notes/EKG HTML" in file:
        continue # Ignore EKG HTML interactive tools if many, let's keep it though. Just text extraction.
    with open(file, 'r', encoding='utf-8', errors='ignore') as f:
        content = f.read()
    text = re.sub(r'<[^>]+>', ' ', content)
    text = re.sub(r'\{(.*?)\}', ' ', text)
    for m in pattern.findall(text):
        if m not in existing_abbrs and m not in ignore_words and not m.isdigit():
            abbr_counter[m] += 1

print(f"Loaded {len(existing_abbrs)} existing abbreviations.")
print("Top missing abbreviations:")
for word, count in abbr_counter.most_common(50):
    if count >= 3:
        print(f"{word}: {count}")
