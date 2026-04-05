import pathlib, re

root = pathlib.Path('/Users/richyf/Library/Mobile Documents/com~apple~CloudDocs/COMPLETE NEW /modules')
actual = set(str(p.relative_to(root)) for p in root.glob('Notes/**/*.html'))

portal = (root / 'student-portal.html').read_text(encoding='utf-8', errors='ignore')
m = re.search(r'const HTML_NOTES_MAP = \{(.+?)\};', portal, re.DOTALL)
if not m:
    print('MAP NOT FOUND'); exit()

entries = re.findall(r"'[^']*'\s*:\s*'([^']*)'", m.group(1))
broken = [e for e in entries if e not in actual]
print(f'Entries: {len(entries)}, Broken: {len(broken)}')
for b in broken:
    print('MISSING:', b)
