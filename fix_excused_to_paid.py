import re

def process_file(filename):
    with open(filename, 'r') as f:
        content = f.read()

    # In Calendar-NEW.html:
    # 1. When inserting a bulk excuse or single excuse, insert status: 'paid'
    content = re.sub(r"status:\s*'excused'(.*?)payment_method:\s*'excused'", r"status: 'paid'\g<1>payment_method: 'manual'\n\g<1>notes: 'Excused - marked as Paid'", content)
    
    # 2. Treat existing 'excused' strings in UI as PAID
    content = re.sub(r"statusText = 'Excused';", "statusText = 'Paid';", content)
    content = re.sub(r"statusBadge = 'EXCUSED';", "statusBadge = 'PAID';", content)
    content = re.sub(r"dotType = 'excused';", "dotType = 'paid';", content)
    content = re.sub(r"dotLabel \+= ' \(Excused\)';", "dotLabel += ' (Paid)';", content)
    content = re.sub(r"status = 'excused';", "status = 'paid';", content)
    
    # In student-portal.html:
    content = re.sub(r"status: 'excused'", "status: 'paid'", content)
    content = re.sub(r"status === 'excused'\s*\?\s*'<span.*?<\/span>'\s*:|case 'excused':\s*statusText = 'Excused';\s*break;", "", content)
    
    # 3. Strip out old payment history logic in student-portal if it exists
    # Just replacing the labels for now

    with open(filename, 'w') as f:
        f.write(content)

process_file('Calendar-NEW.html')
process_file('student-portal.html')
