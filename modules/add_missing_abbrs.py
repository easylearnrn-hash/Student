import re

updates = {
    'CN': 'Cranial Nerve',
    'UI': 'Urinary Incontinence / User Interface',
    'MG': 'Myasthenia Gravis / Milligram',
    'UV': 'Ultraviolet',
    'ART': 'Antiretroviral Therapy',
    'ASAP': 'As Soon As Possible',
    'COVID': 'Coronavirus Disease',
    'VAP': 'Ventilator-Associated Pneumonia',
    'HAP': 'Hospital-Acquired Pneumonia',
    'CAP': 'Community-Acquired Pneumonia',
    'BUN': 'Blood Urea Nitrogen', 
    'FHR': 'Fetal Heart Rate',
    'WBC': 'White Blood Cell',
    'RBC': 'Red Blood Cell'
}

with open('./Notes/js/med-abbr-tooltip.js', 'r') as f:
    text = f.read()

start_idx = text.find('var ABBR = {')
end_idx = text.find('};', start_idx)
abbr_text = text[start_idx:end_idx]

# Check existing keys to avoid duplicates
existing_keys = set()
lines = abbr_text.split('\n')
for line in lines:
    m = re.match(r"^\s*'([A-Za-z0-9\.\-\½\&]+)'\s*:", line)
    if m:
        existing_keys.add(m.group(1))

new_lines = []
for k, v in updates.items():
    if k not in existing_keys:
        new_lines.append(f"    '{k}':{ ' '*(10-len(k))} '{v}',")

if new_lines:
    # Insert before the last closing brace
    new_abbr_text = abbr_text + "\n    /* ── Found via General Audit ── */\n" + "\n".join(new_lines) + "\n  "
    new_text = text[:start_idx] + new_abbr_text + text[end_idx:]
    with open('./Notes/js/med-abbr-tooltip.js', 'w') as f:
        f.write(new_text)
    print(f"Added {len(new_lines)} terms: {', '.join([k for k in updates if k not in existing_keys])}")
else:
    print("No new terms to add.")
