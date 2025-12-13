# CRITICAL: Notes are locked for paid students

## Root Cause
Student portal downloaded from GitHub does NOT have the payment query fixes.
It only checks payment_records table (manual payments).
It IGNORES:
- payments table (Zelle/Venmo automated imports) 
- credit_payments table (balance credits from Calendar)

## Students Affected
- Gayane Zadourian (paid $50 on Dec 12 via Zelle)
- Vergine Mkrtchyan (paid $50 on Dec 12 via Zelle)
- Narine Jamalyan (paid $50 on Dec 12 via Zelle)
- ANY student who paid via Zelle/Venmo
- ANY student with credit balance applied in Calendar

## IMMEDIATE TEMPORARY FIX
Add anonymous RLS policies (ALREADY DONE in Supabase):
✅ anon_read_payment_records
✅ anon_read_payments  
✅ anon_read_credit_payments

## PERMANENT FIX NEEDED
Upload corrected student-portal.html to GitHub with:
1. Query all 3 payment tables (payment_records, payments, credit_payments)
2. Accept both status='paid' AND status='credit' for unlocking notes
3. Filter automated payments by student_id OR student name matching

Current status: LOCAL file has fixes, GITHUB does not.
