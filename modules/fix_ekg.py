import json
import re

with open('generate_ekg.py', 'r') as f:
    text = f.read()

# Replace options dict creation
text = text.replace('"options": {letters[i]: opts[i] for i in range(4)},', '"options": [{"id": letters[i].lower(), "text": opts[i]} for i in range(4)],')

# Replace letters for single choice correct answer
text = text.replace('letters = ["A", "B", "C", "D"]', 'letters = ["a", "b", "c", "d"]')
text = text.replace('letters = ["A", "B", "C", "D", "E"]', 'letters = ["a", "b", "c", "d", "e"]')

# For SATA options list:
text = text.replace('''    options_dict = {}
    corr_ltrs = []
    for j in range(5):
        options_dict[letters[j]] = opts[j]["text"]
        if opts[j]["is_corr"]:
            corr_ltrs.append(letters[j])''', '''    options_list = []
    corr_ltrs = []
    for j in range(5):
        options_list.append({"id": letters[j], "text": opts[j]["text"]})
        if opts[j]["is_corr"]:
            corr_ltrs.append(letters[j])''')

text = text.replace('"options": options_dict,', '"options": options_list,')

with open('generate_ekg.py', 'w') as f:
    f.write(text)
