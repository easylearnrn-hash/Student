import re

with open('./Notes/js/med-abbr-tooltip.js', 'r') as f:
    text = f.read()

# We need to insert these lines into the if/else block inside the fullTerm logic
new_logic = """
        } else if (matched === 'UI') {
          fullTerm = (path.indexOf('renal') !== -1 || path.indexOf('urin') !== -1) ? 'Urinary Incontinence' : 'User Interface';
        } else if (matched === 'MG') {
          fullTerm = path.indexOf('neuro') !== -1 ? 'Myasthenia Gravis' : 'Milligram';
        } else if (matched === 'PEP') {
          fullTerm = path.indexOf('respir') !== -1 ? 'Positive Expiratory Pressure' : 'Post-Exposure Prophylaxis';
        } else if (matched === 'C3') {
          fullTerm = (path.indexOf('immuno') !== -1 || path.indexOf('renal') !== -1) ? 'Complement Component 3' : 'Cervical Spine 3';
        } else if (matched === 'C4') {
          fullTerm = (path.indexOf('immuno') !== -1 || path.indexOf('renal') !== -1) ? 'Complement Component 4' : 'Cervical Spine 4';
        } else if (matched === 'CO') {"""

text = text.replace("} else if (matched === 'CO') {", new_logic.strip())

with open('./Notes/js/med-abbr-tooltip.js', 'w') as f:
    f.write(text)

print("Updated slash logic.")
