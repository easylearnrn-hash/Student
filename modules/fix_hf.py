import re
with open('Test/INSERT-HEART-FAILURE-QUESTIONS.sql', 'r') as f:
    text = f.read()

# Replace VALUES (test_id, topic_id, 'stem...') with VALUES (test_id, topic_id, 'stem...', 'stem...'
def rep(m):
    # m.group(1) is "VALUES (test_id, topic_id, "
    # m.group(2) is the first quoted string up to the next unescaped quote followed by a comma
    return f"{m.group(1)}{m.group(2)}, {m.group(2)}"

fixed = re.sub(r"(VALUES\s*\(\s*test_id,\s*topic_id,\s*)('(?:[^']|'')*')", rep, text)

with open('Test/INSERT-HEART-FAILURE-QUESTIONS.sql', 'w') as f:
    f.write(fixed)
