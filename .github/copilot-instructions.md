# Copilot Instructions for ARNOMA Modules

## 🏗️ Architecture Overview

### Mega-page Pattern (No Build System)
Each HTML file is a **self-contained application** with inline CSS/JS—no bundler, no modules, no transpilation:
- **Admin Tools**: `Calendar.html`, `Student-Manager.html`, `Payment-Records.html`, `Test-Manager.html`, `Notes-Manager-NEW.html`, `Group-Notes.html`, `Email-System.html`
- **Student Facing**: `student-portal.html`, `Tests-Library.html`, `Student-Test.html`, `Protected-PDF-Viewer.html`, `PharmaQuest.html`
- **Shared Modules**: `shared-auth.js`, `shared-dialogs.js` (imported via `<script src>`—no module syntax)

All pages load Supabase via CDN: `https://cdn.jsdelivr.net/npm/@supabase/supabase-js@2.45.1`  
**CRITICAL**: Always hard-code `SUPABASE_URL` and `SUPABASE_ANON_KEY` in each page, then instantiate: `window.supabase.createClient(SUPABASE_URL, SUPABASE_ANON_KEY)`

---

## 🗄️ Data Layer: Supabase Schema & Cross-Module Contracts

### Core Tables (shared across all pages)
| Table | Owner | Readers | Key Fields | Notes |
|-------|-------|---------|-----------|-------|
| `students` | `Student-Manager.html` | `Calendar`, `student-portal`, `Payment-Records` | `id`, `name`, `group_letter`, `price_per_class`, `balance`, `show_in_grid`, `aliases[]` | Source of truth for student records |
| `payment_records` | `Payment-Records.html` | `Calendar`, `student-portal` | `student_id`, `date`, `amount`, `status` (`paid\|unpaid\|pending\|cancelled\|absent`) | Manual payment entries |
| `payments` | Auto (Zelle/Venmo) | `Payment-Records`, `student-portal` | `linked_student_id`, `student_id`, `resolved_student_name`, `payer_name` | Automated payment imports |
| `student_notes` | `Notes-Manager-NEW.html` | `Group-Notes`, `student-portal`, `Protected-PDF-Viewer` | `pdf_url`, `requires_payment`, `is_system_note`, `system_category` | PDFs in `student-notes` bucket |
| `tests` | `Test-Manager.html` | `Tests-Library`, `Student-Test` | `test_name`, `system_category`, `is_active` | Test containers |
| `test_questions` | `Test-Manager.html` | `Student-Test` | `test_id`, `question_text`, `correct_answer` | Questions belong to tests |
| `question_banks` / `qbank_questions` | `Test-Manager.html` | `Tests-Library`, `Student-Test` | `category`, `difficulty` | Q-Bank system |
| `sent_emails` | `Email-System.html` | — | `email_type`, `resend_id`, `delivery_status` | Email audit trail |
| `admin_accounts` | `shared-auth.js` | All admin tools | `email`, `is_active` | Admin whitelist for RLS |

### Data Normalization Rules
- **Group codes**: Always use `canonicalizeGroupCode()` / `formatGroupDisplay()` for A-F letters
- **Email fields**: Parse with `parseEmailField()` / `getPrimaryEmailValue()` (handles JSON arrays or strings)
- **Phone numbers**: Format as `xxx-xxx-xxxx` using Student Manager's formatter
- **Payment status**: Exact strings required (`paid`, `unpaid`, `pending`, `cancelled`, `absent`)—Payment-Records neon badges and Student Portal summaries hard-code these

**DANGER ZONE**: Changing a column in `students` or `payment_records` requires updating 4+ HTML pages. Always `grep` before renaming:
```bash
grep -r "price_per_class" *.html
```

---

## 🔐 Auth & Impersonation

### Admin Auth Flow (`shared-auth.js`)
1. Import script: `<script src="shared-auth.js"></script>`
2. Wrap entry points: `ArnomaAuth.ensureSession(supabase)` (returns Promise)
3. Caches session in `localStorage`:
   - `arnoma:auth:session` → full session object (7-day TTL)
   - `arnoma:auth:user` → user email
4. On auth failure → redirects to `index.html`

**Example**:
```javascript
const session = await ArnomaAuth.ensureSession(supabase);
if (!session) return; // redirected to login
```

### Impersonation Mode (Admin → Student View)
- Admin can "View as Student" from `Student-Portal-Admin.html`
- Token stored: `sessionStorage.impersonation_token` + `localStorage.impersonation_token` (fallback)
- `student-portal.html` detects token → loads student data
- **EXIT**: Always call `exitImpersonation()` to clear tokens before returning to admin view

**CRITICAL**: Protected-PDF-Viewer skips session tracking when impersonation is active (see `student-portal.html` line 8536).

---

## 🎨 UI Patterns: Glassmorphism & Shared Dialogs

### Shared Dialog System (`shared-dialogs.js`)
Replace native `alert()`, `confirm()`, `prompt()` to preserve glassmorphism UI:
```javascript
await customAlert('Success', 'Student added!');
const ok = await customConfirm('Delete?', 'Cannot undo');
const name = await customPrompt('Student Name', 'Enter name...');
```

**Why**: Native dialogs break the glassmorphism shell and look jarring.

### CSS Variables (Design System)
All pages use consistent CSS variables:
```css
--primary-gradient: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
--panel-blur: 8px;    /* Page panels */
--modal-blur: 14px;   /* Modals/dialogs */
--list-blur: 0px;     /* Lists (performance) */
```

**Performance Note**: Infinite animations disabled in `student-portal.html` (see line 47-77)—only interactive elements get transitions.

---

## ⚡ Performance: Caching & DOM Optimization

### Two-Tier Cache Pattern (Calendar + Student-Manager + Payment-Records)
1. **DOMCache**: Stores `querySelector()` results (5-min TTL)
   ```javascript
   const card = domCache.get('student-123') || document.querySelector('[data-id="123"]');
   domCache.set('student-123', card);
   ```

2. **DataCache**: Stores Supabase queries (5-min TTL)
   ```javascript
   if (dataCache.has('students')) return dataCache.get('students');
   const { data } = await supabase.from('students').select('*');
   dataCache.set('students', data);
   ```

**CRITICAL**: When mutating DOM or data, **clear cache**:
```javascript
domCache.clear();
dataCache.clear();
```

### Template Cloning (Payment-Records)
**Old (slow)**: 15+ `createElement()` calls per card  
**New (fast)**: Clone pre-built `<template>` once
```javascript
const card = templates.paymentCard.content.cloneNode(true);
// Update text fields in batch
```

See `PAYMENT-RECORDS-OPTIMIZATION-COMPLETE.md` for full details.

---

## �� Notes System: Upload → Assign → Protect

### 3-Stage Flow
1. **Upload** (`Notes-Manager-NEW.html`):
   - Admin uploads PDFs → `student-notes` bucket
   - Path: `{SystemName}/{SystemName}_{date}_{timestamp}.pdf`
   - Creates `student_notes` record (`is_system_note=true`, `requires_payment`)

2. **Assign** (`Group-Notes.html`):
   - Admin assigns notes to groups A-F
   - Writes to `note_permissions` table

3. **Protect** (`Protected-PDF-Viewer.html`):
   - Enforces `requires_payment` flag
   - Generates signed URLs (60-min expiry)
   - Adds watermarks, blocks right-click/shortcuts

**Security Rule**: Never weaken PDF security checks in Protected-PDF-Viewer—payments depend on this.

---

## �� Payment Logic: Multi-Source Reconciliation

### Student Portal Payment Display
Combines **two sources**:
1. **Manual** (`payment_records` table) → added by admin
2. **Automated** (`payments` table) → Zelle/Venmo imports

**Triple-Lookup Pattern**:
```javascript
payments.filter(p => 
  p.student_id === studentId ||
  p.linked_student_id === studentId ||
  p.resolved_student_name === student.name ||
  student.aliases.includes(p.payer_name)
);
```

**WARNING**: `Calendar.html` previously had over-engineered "coverage maps"—replaced with simple date-matching logic from `index.html` (see `CALENDAR-FIX-COMPLETE-GUIDE.md`).

### Email System Edge Function
- Calls: `${SUPABASE_URL}/functions/v1/send-email`
- Stores drafts/history in localStorage:
  - `arnoma-email-templates-v7`
  - `arnoma-automations-v1`
  - `arnoma-sent-emails-v1`
- Logs to `sent_emails` table (`email_type`, `resend_id`, `delivery_status`)

---

## 🧪 Test System: Tests → Questions → Q-Banks

### Architecture
```
tests (container)
  ├── test_questions (many-to-one)
  └── qbank_questions (many-to-many via question_banks)
```

### Admin Workflow (Test-Manager.html)
1. **Create Test**: Tab 1 → fills `tests` table
2. **Add Questions**: 3 methods:
   - **Single**: Manual entry
   - **Bulk CSV**: Pipe-delimited (`Question|A|B|C|D|✔️C`)
   - **JSON Upload**: Auto-creates Q-Banks if not exist

3. **Q-Bank Categories**: Stored in `localStorage.customCategories` (user-defined)

### Student Workflow (Student-Test.html)
- Fetches questions by `testId`
- Shuffle: `toggleShuffle()` button
- Reactions: From `localStorage.arnoma-test-reactions-v1`:
  ```json
  {
    "correct": ["🎉", "🔥", "💪"],
    "incorrect": ["😅", "🤔", "📚"]
  }
  ```

Editable in Test Manager → Reactions tab.

---

## 🛠️ SQL Migrations & Schema Changes

### Manual Migration Workflow
Root `.sql` files document all schema changes:
- `setup-notes-system.sql` → Notes tables + RLS
- `create-tests-system.sql` → Test system
- `optimize-payment-records-indexes.sql` → Performance indexes
- `add-college-field.sql` → Student schema change

**Process**:
1. Write `.sql` file with DDL + RLS policies
2. Run in Supabase SQL Editor
3. **CRITICAL**: `grep` all HTML files for affected columns:
   ```bash
   grep -r "old_column_name" *.html
   ```
4. Update every match (no find-replace—verify each)

**Why**: No ORM or type-checking—breaking changes are silent until runtime.

---

## 🐛 Debugging & Local Dev

### DEBUG_MODE Pattern
Each mega-page defines:
```javascript
const DEBUG_MODE = false;
const debugLog = (...args) => DEBUG_MODE && console.log(...args);
```

Usage:
```javascript
debugLog('📚 Loaded notes:', notes.length);
```

**ALWAYS** reset `DEBUG_MODE = false` before committing.

### Local Server
```bash
python3 -m http.server 8000
open http://localhost:8000/student-portal.html
```

**No build step**—just serve static files. Changes require hard refresh: `Cmd+Shift+R` (macOS).

### Live Data Warning
All Supabase calls hit **production**. No staging environment. Best practices:
- Use feature flags for risky changes
- Test with inactive students/tests (`is_active=false`)
- Manually walk through: Auth → Data Fetch → Primary Action

---

## 📚 Key Documentation Files

Reference these for deep dives:
- `TEST-SYSTEM-COMPLETE-GUIDE.md` → Full test/Q-Bank architecture
- `CALENDAR-FIX-COMPLETE-GUIDE.md` → Payment allocation replacement
- `PAYMENT-RECORDS-OPTIMIZATION-COMPLETE.md` → Performance patterns
- `NEW-NOTES-SYSTEM-GUIDE.md` → Notes upload/assign workflow
- `PROTECTED-PDF-SECURITY.md` → PDF viewer security model

---

## 🚨 Common Pitfalls

1. **Schema Changes**: Always `grep` before renaming columns—no TypeScript to catch errors
2. **Cache Invalidation**: Mutating DOM/data? Clear `domCache` and `dataCache`
3. **Payment Status Strings**: Must be exact (`paid`, not `Paid` or `PAID`)
4. **Impersonation Cleanup**: Call `exitImpersonation()` or tokens persist across sessions
5. **DEBUG_MODE**: Never commit with `DEBUG_MODE = true`
6. **Hard Refresh**: Browser caches inline scripts aggressively—use `Cmd+Shift+R`

---

# 🚫 Global Hard Restrictions (Copilot MUST Obey These)

### Absolutely DO NOT:
- Invent new files, folders, modules, or architectures.
- Add frameworks (React, Vue, Angular), bundlers (Vite, Webpack), or Node-based tooling.
- Introduce TypeScript, JSX, or any language not already present.
- Modify Supabase schema, tables, indexes, RLS, or Edge Functions unless explicitly instructed.
- Create or rename columns, tables, or APIs on its own.
- Change visual layout, styling, design language, or UX patterns without direct instructions.
- "Helpfully rewrite" or refactor entire sections unless the user explicitly says to.
- Alter cross-module logic flows, data shapes, or shared helper function contracts.
- Touch files other than the ones the user explicitly mentioned.
- Generate placeholder logic, fake endpoints, or speculative behaviors.

### Copilot MUST:
- Change ONLY what the user points to.
- Maintain the Liquid Glass aesthetic exactly as implemented.
- Match existing code patterns and naming conventions.
- Preserve functional behavior unless the user explicitly requests a change.
- Keep edits minimal, local, precise, and non-destructive.
- Ask for clarification if an instruction could affect multiple modules.
- Prefer doing **less** rather than guessing or improvising.

---

# End of Instructions
