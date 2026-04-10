import re
import json
import urllib.request

with open('index.html', 'r') as f:
    html = f.read()

url = re.search(r"const SUPABASE_URL *= *['\"](.*?)['\"]", html).group(1)
key = re.search(r"const SUPABASE_ANON_KEY *= *['\"](.*?)['\"]", html).group(1)

print("Fetching from URL:", url)
req = urllib.request.Request(f"{url}/rest/v1/students?select=*", headers={
    'apikey': key,
    'Authorization': f'Bearer {key}',
    'Content-Type': 'application/json'
})
try:
    res = urllib.request.urlopen(req)
    students = json.loads(res.read())
    print("Found total students:", len(students))
    for s in students:
        if 'seda' in s['name'].lower() or 'amiryan' in s['name'].lower():
            print(f"ID: {s['id']}, Name: {s['name']}, Group: {s['group_name']}, Status: {s['status']}, Balance: {s['balance']}")
except Exception as e:
    print("Error:", e)
