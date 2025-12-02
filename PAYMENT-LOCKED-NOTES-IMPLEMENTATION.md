# Payment-Locked Group Notes - Implementation Guide

## Overview
This system allows admins to create notes for specific groups and class dates. Students can only access notes for classes they have paid for.

## Setup Steps

### 1. Database Setup
Run `setup-group-notes.sql` in your Supabase SQL editor to create:
- `group_notes` table with RLS policies
- Indexes for performance
- Auto-update triggers

### 2. Admin Portal (Student-Portal-Admin.html)
✅ **Completed Features:**
- New "📚 Group Notes" tab added
- Create notes with:
  - Group selection (A-F)
  - Class date picker
  - Note title and content
  - Optional PDF attachment
- Filter notes by group
- View and delete notes
- Notes are stored with payment-lock metadata

### 3. Student Portal (student-portal.html) - TO IMPLEMENT

#### Required Components:

**A. Payment Allocation Function**
```javascript
async function calculatePaidClasses(studentId) {
  // 1. Fetch student's price per class
  // 2. Fetch all payments (payment_records + payments tables)
  // 3. Fetch absences and credits
  // 4. Run reverse-chronological allocation
  // 5. Return array of paid class dates
}
```

**B. Group Notes Tab UI**
- Add tab: "📚 My Notes"
- Display notes for student's group
- Show lock icon 🔒 for unpaid classes
- Show unlock icon ✅ for paid classes
- Disable click on locked notes
- Show tooltip: "Pay for this class to unlock"

**C. Note Display Logic**
```javascript
async function loadMyGroupNotes() {
  // 1. Get current student's group
  // 2. Fetch all notes for that group
  // 3. Calculate which classes are paid
  // 4. Render notes with lock/unlock status
}
```

**D. Note Viewing**
- Locked notes: Show payment prompt
- Unlocked notes: Display content + PDF link

## Payment Allocation Logic

### Existing System
Your current payment system already has:
- `payment_records` table (manual payments)
- `payments` table (Zelle imports)
- `student_absences` table (missed classes)
- Price per class in `students` table

### Integration Points

**1. Calendar Integration**
The calendar already shows red/green dots based on payment status. The group notes system should use THE SAME logic:
- Red dot = class unpaid = note locked 🔒
- Green dot = class paid = note unlocked ✅

**2. Payment Detection**
When a new payment is added (Zelle or manual):
- Student portal auto-refreshes payment status
- Locked notes become unlocked instantly
- No manual refresh needed (use Supabase realtime or polling)

## Student Portal Changes Needed

### 1. Add Notes Tab to student-portal.html

```html
<!-- In navigation -->
<div class="tab" onclick="switchTab('notes')">
  <span>📚</span> My Notes
</div>

<!-- Tab content -->
<div id="notesTab" class="tab-content">
  <div class="notes-grid" id="notesGrid">
    <!-- Notes cards will be inserted here -->
  </div>
</div>
```

### 2. Note Card Template

```html
<!-- Unlocked note -->
<div class="note-card unlocked" onclick="openNote(noteId)">
  <div class="note-header">
    <span class="note-date">Dec 1, 2025</span>
    <span class="note-status unlocked">✅ Unlocked</span>
  </div>
  <h3>Cardiovascular System Notes</h3>
  <p>Click to view content</p>
</div>

<!-- Locked note -->
<div class="note-card locked">
  <div class="note-header">
    <span class="note-date">Dec 5, 2025</span>
    <span class="note-status locked">🔒 Locked</span>
  </div>
  <h3>Respiratory System Notes</h3>
  <p class="lock-message">Pay for this class to unlock</p>
</div>
```

### 3. CSS Styling

```css
.note-card {
  background: rgba(255,255,255,0.05);
  border-radius: 16px;
  padding: 20px;
  cursor: pointer;
  transition: all 0.3s;
}

.note-card.unlocked:hover {
  transform: translateY(-4px);
  box-shadow: 0 8px 20px rgba(102,126,234,0.3);
}

.note-card.locked {
  opacity: 0.6;
  cursor: not-allowed;
  filter: grayscale(0.5);
}

.note-status.locked {
  color: #ef4444;
  background: rgba(239,68,68,0.1);
  padding: 4px 12px;
  border-radius: 12px;
}

.note-status.unlocked {
  color: #10b981;
  background: rgba(16,185,129,0.1);
  padding: 4px 12px;
  border-radius: 12px;
}
```

## Testing Checklist

### Admin Side
- [ ] Create note for Group A, today's date
- [ ] Create note with PDF attachment
- [ ] Create note with text content only
- [ ] Filter notes by group
- [ ] Delete a note

### Student Side
- [ ] Student sees notes for their group only
- [ ] Unpaid class shows locked note
- [ ] Paid class shows unlocked note
- [ ] Clicking locked note shows payment prompt
- [ ] Clicking unlocked note opens content
- [ ] PDF opens in new tab when unlocked
- [ ] After payment, note unlocks automatically

### Payment Integration
- [ ] Zelle payment detected → notes unlock
- [ ] Manual payment added → notes unlock
- [ ] Calendar dot color matches note lock status
- [ ] Payment allocation runs correctly

## Performance Optimization

1. **Cache student payment status** (5-minute TTL)
2. **Batch fetch** notes + payments in single query where possible
3. **Use RLS policies** to filter at database level
4. **Index on** `(group_id, class_date)` for fast lookups

## Security Considerations

- ✅ RLS policies prevent students from seeing other groups' notes
- ✅ Payment check enforced at both UI and API level
- ✅ File URLs use signed URLs with expiration
- ✅ No student can access note.file_url directly without payment check

## Future Enhancements

- Push notifications when notes unlock after payment
- Download PDF for offline access (paid notes only)
- Mark notes as "read"
- Search notes by title or content
- Note comments/questions from students
