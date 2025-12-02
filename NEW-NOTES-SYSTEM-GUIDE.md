# 📚 NEW Notes Management System - Complete Guide

## 🎯 Overview

The new system separates **uploading** from **group assignment** for better organization and flexibility:

1. **Notes Manager** (`Notes-Manager-NEW.html`) - Upload and organize PDFs by NCLEX system
2. **Group Notes** (`Group-Notes.html`) - Assign uploaded notes to specific groups (A-F)
3. **Student Portal** - Students see notes assigned to their group (if paid)

---

## 🚀 Quick Start

### For Admins:

1. **Upload Notes**:
   - Go to `Notes-Manager-NEW.html`
   - Choose single or bulk upload
   - Select NCLEX system (e.g., "Cardiovascular System")
   - Upload PDFs (all go to same system folder)
   - No group selection needed at upload time

2. **Assign to Groups**:
   - Go to `Group-Notes.html`
   - Select group tab (A, B, C, D, E, or F)
   - Expand system sections
   - Click "✓ Show to Group X" to make visible
   - Click "🚫 Hide from Group X" to revoke access

3. **Students See**:
   - Only notes assigned to their group
   - Only if they have paid (`requires_payment` check)
   - In Student Portal under their group's section

---

## 📋 Notes Manager Features

### Tab 1: Single Upload
Upload one PDF at a time with full control:

**Fields:**
- **System/Topic** - Select from 24 NCLEX systems
- **Title** - Custom title for the note
- **Description** - Optional details
- **Class Date** - When material was taught
- **Requires Payment** - Toggle (default: ON)
- **PDF File** - Drag & drop or click to browse

**File Validation:**
- Max size: 50MB per file
- Type: PDF only
- Auto-detects file size

**Upload Flow:**
```
Select System → Fill Details → Choose PDF → Upload
     ↓
File saved to: storage/{SystemName}/{SystemName}_{date}_{timestamp}.pdf
     ↓
Database record created: student_notes table (is_system_note=true)
```

### Tab 2: Bulk Upload
Upload multiple PDFs at once for the same system:

**Features:**
- Select up to 50 PDF files
- All files use same system, date, and payment setting
- Auto-generates titles from filenames
- Progress tracking (shows X/Y files uploaded)
- All files organized in same system folder

**Perfect For:**
- Uploading entire week's materials
- Organizing module notes
- Batch processing scanned documents

**Bulk Upload Flow:**
```
Select System → Set Date & Payment → Choose Multiple PDFs → Upload All
     ↓
Each file saved: {System}/{System}_{date}_{timestamp}.pdf
     ↓
Individual database records with auto-titles
```

### Tab 3: Notes Library
View all uploaded notes:

**Filters:**
- System filter dropdown
- Shows all systems or filter by one

**Note Cards Display:**
- Title
- System name
- Upload date
- Payment status (🔒 Paid / 🔓 Free)
- File size
- Actions: View PDF, Delete

**Card Actions:**
- **👁️ View** - Opens signed URL in new tab
- **🗑️ Delete** - Removes from storage + marks deleted in DB

---

## 👥 Group Notes Manager

### Interface Layout

**Group Tabs:**
- A, B, C, D, E, F
- Click to switch between groups
- Green highlight = active group

**System Sections (Accordion):**
- 24 NCLEX systems organized by icon
- Click header to expand/collapse
- Shows note count per system
- Only systems with notes appear

### Note Card States

**Hidden (Red Badge):**
```
┌─────────────────────────────────┐
│ Title: Cardiovascular Week 1    │
│ 📅 12/3/2024  🔒 Paid  📦 2.3MB │
│ [✓ Show to Group A]  [👁️ View] │
└─────────────────────────────────┘
```

**Visible (Green Badge & Border):**
```
┌═════════════════════════════════┐ ← Green border
│ ✓ Visible Title: Cardio Week 1  │ ← Green badge
│ 📅 12/3/2024  🔒 Paid  📦 2.3MB │
│ [🚫 Hide from Group A] [👁️]     │
└═════════════════════════════════┘
```

### Permission System

**Database Table: `student_note_permissions`**
```sql
id              BIGSERIAL PRIMARY KEY
note_id         BIGINT (FK to student_notes)
group_name      TEXT ('Group A', 'Group B', etc.)
is_accessible   BOOLEAN
created_at      TIMESTAMPTZ
updated_at      TIMESTAMPTZ
UNIQUE(note_id, group_name)
```

**How It Works:**
1. Upload creates note with `is_system_note=true`
2. No permissions = hidden from all groups
3. Grant access = INSERT/UPDATE permission with `is_accessible=true`
4. Revoke access = UPDATE permission to `is_accessible=false`
5. Student query JOINs notes + permissions to filter visible notes

---

## 🗂️ File Organization

### Storage Structure

```
student-notes/
├── Medical Terminology/
│   ├── Medical Terminology_2024-12-03_1701627800001.pdf
│   ├── Medical Terminology_2024-12-03_1701627800002.pdf
│   └── ...
├── Cardiovascular System/
│   ├── Cardiovascular System_2024-11-15_1700000000001.pdf
│   ├── Cardiovascular System_2024-11-22_1700500000001.pdf
│   └── ...
├── Respiratory System/
│   └── ...
└── ... (24 systems total)
```

**Naming Convention:**
```
{SystemName}_{YYYY-MM-DD}_{UnixTimestamp}.pdf
```

**Why Timestamps?**
- Prevents filename collisions
- Maintains upload order
- Easy to identify most recent

---

## 📊 Database Schema

### student_notes Table
```sql
id                  BIGINT (auto-increment)
title               TEXT
description         TEXT
group_name          TEXT (stores system name now)
class_date          DATE
file_path           TEXT (storage path)
file_name           TEXT (original filename)
file_size           BIGINT (bytes)
uploaded_by         TEXT (admin email)
requires_payment    BOOLEAN
is_system_note      BOOLEAN (NEW - true for centralized notes)
deleted             BOOLEAN
created_at          TIMESTAMPTZ
updated_at          TIMESTAMPTZ
```

**Key Fields:**
- `group_name` - NOW stores NCLEX system (not group letter)
- `is_system_note` - Distinguishes centralized notes from old group notes
- `deleted` - Soft delete (keeps in DB, hidden from UI)

### student_note_permissions Table
```sql
id              BIGSERIAL PRIMARY KEY
note_id         BIGINT REFERENCES student_notes(id) ON DELETE CASCADE
group_name      TEXT ('Group A', 'Group B', 'Group C', ...)
is_accessible   BOOLEAN DEFAULT true
created_at      TIMESTAMPTZ DEFAULT now()
updated_at      TIMESTAMPTZ DEFAULT now()
UNIQUE(note_id, group_name)
```

**Foreign Key:**
- `note_id` → `student_notes.id`
- CASCADE delete (permission removed when note deleted)

**Unique Constraint:**
- One permission record per note-group pair
- Prevents duplicate assignments

---

## 🔐 Student Portal Integration

### Query Logic (Pseudocode)

```sql
SELECT n.*
FROM student_notes n
JOIN student_note_permissions p ON n.id = p.note_id
WHERE n.deleted = false
  AND n.is_system_note = true
  AND p.group_name = :userGroup  -- e.g., 'Group A'
  AND p.is_accessible = true
  AND (
    n.requires_payment = false 
    OR :userHasPaid = true
  )
ORDER BY n.class_date DESC, n.created_at DESC
```

**Payment Check:**
- If note has `requires_payment=true` → Check student payment status
- If student unpaid → Hide note (or show "Payment Required")
- If student paid OR note free → Show note

**Access Check:**
- Must have permission record with `is_accessible=true`
- No permission record = hidden
- Permission with `is_accessible=false` = hidden

---

## 🎨 UI/UX Design

### Notes Manager Design
- **Dark glassmorphism theme** (matches Group Manager)
- **3-tab interface** (Single / Bulk / Library)
- **Drag & drop zones** with visual feedback
- **Progress bars** with percentage + status text
- **Real-time file validation** (size, type)
- **Responsive grid** (adapts to screen size)

### Group Notes Design
- **Accordion system sections** (expand/collapse)
- **Visual access states** (green=visible, red=hidden)
- **One-click grant/revoke** (instant feedback)
- **Group tabs** (easy switching)
- **Note count badges** (see how many notes per system)

### Color System
```css
Accessible:   Green (#10b981)
Restricted:   Red (#ef4444)
Primary:      Purple gradient (#667eea → #764ba2)
Secondary:    Blue (#3b82f6)
Success:      Emerald (#10b981)
```

---

## 🔧 Technical Implementation

### File Upload Process

**Single Upload:**
```javascript
1. Validate file (PDF, < 50MB)
2. Generate unique file path
3. Upload to Supabase Storage
4. Insert database record
5. Reset form
6. Reload library (if on that tab)
```

**Bulk Upload:**
```javascript
1. Validate all files
2. Loop through each file:
   a. Generate unique path
   b. Upload to storage
   c. Insert DB record
   d. Update progress (X/Y)
3. Show completion message
4. Reset form
```

### Permission Management

**Grant Access:**
```javascript
1. Check if permission exists
2. If exists → UPDATE is_accessible=true
3. If not → INSERT new permission
4. Update local state
5. Re-render UI
```

**Revoke Access:**
```javascript
1. Find existing permission
2. UPDATE is_accessible=false
3. Update local state
4. Re-render UI
```

**Performance:**
- All notes loaded once on init
- All permissions loaded once on init
- Local state filtering (no re-fetch on group switch)
- Only database updates on grant/revoke

---

## 📱 Responsive Behavior

### Desktop (> 768px):
- Notes grid: 3 columns
- Group tabs: Horizontal row
- Full feature access

### Tablet (768px):
- Notes grid: 2 columns
- Group tabs: Horizontal wrap
- Compact spacing

### Mobile (< 768px):
- Notes grid: 1 column
- Group tabs: Vertical stack
- Touch-friendly buttons
- Simplified layout

---

## 🚨 Common Issues & Solutions

### Issue: "File already exists"
**Cause:** Uploading same file twice at exact same second
**Solution:** Timestamp includes milliseconds + increment for bulk

### Issue: "Permission not showing"
**Cause:** Database sync delay
**Solution:** Reload page or switch tabs to refresh

### Issue: "Note visible to wrong group"
**Cause:** Permission record mismatch
**Solution:** Check `student_note_permissions` table for note_id

### Issue: "Student can't see note"
**Checklist:**
1. ✅ Note uploaded with `is_system_note=true`?
2. ✅ Permission exists for student's group?
3. ✅ Permission has `is_accessible=true`?
4. ✅ Student has paid (if `requires_payment=true`)?
5. ✅ Note not marked `deleted=true`?

---

## 🔄 Migration from Old System

### Old System (Group-Based Upload):
```
Upload → Select Group A → PDF saved to group_notes/Group_A/
```

### New System (Centralized Upload):
```
Upload → Select System → PDF saved to {System}/
Later → Assign to Groups A, B, C via Group Notes
```

### Benefits:
✅ One PDF can be shared across groups
✅ Update once, reflects everywhere
✅ Better organization by topic
✅ Bulk upload support
✅ Cleaner file structure

### Drawbacks:
❌ Extra step (assign after upload)
❌ Two interfaces instead of one

**Recommendation:**
- Keep old `Notes-Manager.html` for backward compatibility
- Gradually migrate to new system
- Eventually deprecate old system

---

## 📈 Future Enhancements

### Planned Features:
- [ ] **Search/Filter** - Search notes by title, description
- [ ] **Bulk Assign** - Assign all notes in system to group
- [ ] **Version Control** - Upload new version of existing note
- [ ] **Analytics** - Track which notes viewed most
- [ ] **Tags** - Add custom tags to notes
- [ ] **Favorites** - Students can favorite notes
- [ ] **Comments** - Students can comment on notes
- [ ] **Download Tracking** - See who downloaded what
- [ ] **Expiration Dates** - Auto-hide notes after date
- [ ] **Reorder** - Drag to reorder notes within system

### Potential Improvements:
- [ ] Thumbnail previews (PDF first page)
- [ ] Rich text editor for descriptions
- [ ] Multi-file viewer (flip through PDFs)
- [ ] Print-friendly view
- [ ] Export group permissions as CSV
- [ ] Import notes from external sources
- [ ] OCR search within PDFs

---

## 🛠️ Maintenance Tasks

### Regular Maintenance:
- **Weekly:** Check storage usage (Supabase 1GB free tier)
- **Monthly:** Clean up deleted notes (permanent delete)
- **Quarterly:** Review permission assignments
- **Yearly:** Archive old semester notes

### Cleanup Script (SQL):
```sql
-- Permanently delete notes marked deleted > 30 days ago
DELETE FROM student_notes
WHERE deleted = true
  AND updated_at < NOW() - INTERVAL '30 days';

-- Find orphaned permissions (note deleted)
SELECT p.*
FROM student_note_permissions p
LEFT JOIN student_notes n ON p.note_id = n.id
WHERE n.id IS NULL;
```

---

## 📚 Admin Workflow Examples

### Example 1: New Cardiovascular Module

**Step 1: Bulk Upload**
1. Open `Notes-Manager-NEW.html`
2. Click "📦 Bulk Upload" tab
3. Select "Cardiovascular System"
4. Set class date: 2024-12-15
5. Leave "Requires Payment" ON
6. Drag 20 PDFs into drop zone
7. Click "📦 Upload All Files"
8. Wait for completion (progress shows 20/20)

**Step 2: Assign to Groups**
1. Open `Group-Notes.html`
2. Click "Group A" tab
3. Expand "❤️ Cardiovascular System"
4. See all 20 notes listed
5. Click "✓ Show to Group A" on each note
6. Repeat for Group B, C (skip D, E, F)

**Result:**
- Groups A, B, C can see all 20 notes
- Groups D, E, F cannot see any
- All notes in `Cardiovascular System/` folder
- Easy to add more notes later

### Example 2: Free Preview Note

**Scenario:** Give all groups free access to intro note

**Step 1: Upload**
1. Single upload tab
2. System: "Medical Terminology"
3. Title: "Week 1 - Introduction (FREE)"
4. Toggle "Requires Payment" OFF
5. Upload PDF

**Step 2: Assign to All Groups**
1. Open Group Notes
2. For each group (A-F):
   - Switch tab
   - Find note
   - Click "✓ Show to Group X"

**Result:**
- All students see note regardless of payment
- Good for introductory materials
- Encourages enrollment

### Example 3: Replace Outdated Note

**Scenario:** New version of note available

**Option A: Update Existing**
1. Delete old note from library
2. Upload new version with same title
3. Permissions preserved if re-assigned

**Option B: Keep Both**
1. Upload new note with " (Updated)" in title
2. Assign new note to groups
3. Hide old note (revoke permissions)
4. Keep old for reference

---

## 🔗 File Locations

### HTML Pages:
- `Notes-Manager-NEW.html` - New upload interface
- `Group-Notes.html` - Group assignment interface
- `Notes-Manager.html` - Old system (deprecated)
- `Student-Portal-Admin.html` - Admin dashboard (link to both)
- `student-portal.html` - Student view

### SQL Setup:
- `setup-group-permissions-system.sql` - Creates permissions table
- `create-system-notes-records.sql` - Template for system records

### Storage:
- Bucket: `student-notes`
- Path: `{SystemName}/{SystemName}_{date}_{timestamp}.pdf`

### Database Tables:
- `student_notes` - Main notes table
- `student_note_permissions` - Group access control
- `students` - Student records (for payment check)

---

## ✅ Testing Checklist

### Notes Manager Tests:
- [ ] Single upload works
- [ ] Bulk upload handles 10+ files
- [ ] Drag & drop zone responds
- [ ] Progress bar updates correctly
- [ ] File validation catches non-PDFs
- [ ] File validation catches oversized files
- [ ] Library shows uploaded notes
- [ ] Delete removes from storage
- [ ] Filter dropdown works
- [ ] Tab switching preserves data

### Group Notes Tests:
- [ ] Group tabs switch correctly
- [ ] System sections expand/collapse
- [ ] Grant access creates permission
- [ ] Revoke access updates permission
- [ ] View PDF opens signed URL
- [ ] Note count badges accurate
- [ ] Green/red badges correct
- [ ] Empty states show when no notes
- [ ] Loading spinner appears on init

### Integration Tests:
- [ ] Upload → appears in Group Notes
- [ ] Assign → visible in Student Portal
- [ ] Revoke → hidden in Student Portal
- [ ] Payment check works
- [ ] Free notes always visible
- [ ] Paid notes hidden for unpaid students

---

## 📞 Support

**Questions?** Check:
1. This guide (comprehensive)
2. Copilot instructions (`.github/copilot-instructions.md`)
3. Console logs (browser developer tools)
4. Supabase dashboard (check tables/storage)

**Found a bug?** Document:
- Steps to reproduce
- Expected vs actual behavior
- Browser console errors
- Supabase error messages

---

**Last Updated:** December 3, 2024  
**Version:** 1.0.0  
**Status:** ✅ Production Ready
