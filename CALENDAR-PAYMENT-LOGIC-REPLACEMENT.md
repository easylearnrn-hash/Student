# Calendar Payment Logic Replacement

## Problem with Current Calendar.html
The current logic is over-engineered with:
- Complex "allocation" system that tries to match payments to multiple classes
- "Coverage maps" that create confusion
- Unicode normalization that breaks simple name matching
- Late payment logic matching future classes (daysDiff calculation bugs)

## Working Logic from index.html
Simple, proven approach:
1. For each student on each class date, check if payment exists
2. Payment matches if:
   - Exact date match (payment date = class date)
   - OR for PAST classes only: payment 1-7 days AFTER class
3. Never match future classes
4. Simple string matching: `.toLowerCase().trim()`
5. Check: studentName, payerName, payerNameRaw, aliases

## Key Function to Replace
Replace the entire `checkPaymentStatus()` or equivalent in Calendar.html with the working version from index.html (lines 22019-22296).

## Critical Rules from Working Code
1. **Future classes**: Show as "pending" or "future" - NEVER red dot
2. **Today/Past unpaid**: Show red dot
3. **Payment window**: Exact date OR 1-7 days AFTER (for past classes ONLY)
4. **Name matching**: Simple lowercase + trim, check 3 fields + aliases
5. **No automatic credits**: Overpayment detection only, manual credit application

## Next Steps
1. Find the equivalent payment checking function in Calendar.html
2. Replace it entirely with the working logic from index.html
3. Remove all "allocation", "coverage map", "payment indexing" complexity
4. Use simple per-date checking like the old code
