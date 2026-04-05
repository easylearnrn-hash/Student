import urllib.request
import json
url = "https://ekndrsvdyajpbaghhzol.supabase.co/rest/v1/student_note_permissions?select=group_name&limit=10"
req = urllib.request.Request(url, headers={
    "apikey": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImVrbmRyc3ZkeWFqcGJhZ2hoem9sIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzMyNjc4NTEsImV4cCI6MjA0ODg0Mzg1MX0.VCJxi5ECgy4gCzk6UbkAJSaWBpx7_y0kZSZRgD7HkVo",
    "Authorization": "Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImVrbmRyc3ZkeWFqcGJhZ2hoem9sIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzMyNjc4NTEsImV4cCI6MjA0ODg0Mzg1MX0.VCJxi5ECgy4gCzk6UbkAJSaWBpx7_y0kZSZRgD7HkVo"
})
with urllib.request.urlopen(req) as response:
    print(response.read().decode())
