# Copilot Instructions for ARNOMA Modules

## 🏗️ Architecture Overview

### Mega-page Pattern (No Build System)
Each HTML file is a **self-contained application** with inline CSS/JS—no bundler, no modules, no transpilation:
- **Admin Tools**: `Calendar.html`, `Student-Manager.html`, `Payment-Records.html`, `Test-Manager.html`, `Notes-Manager-NEW.html`, `Group-Notes.html`, `Email-System.html`
- **Student Facing**: `student-portal.html`, `Tests-Library.html`, `Student-Test.html`, `Protected-PDF-Viewer.html`, `PharmaQuest.html`
- **Shared Modules**: `shared-auth.js`, `shared-dialogs.js` (imported via `<script src>`—no module syntax)

All pages load Supabase via CDN: `https://cdn.jsdelivr.net/npm/@supabase/supabase-js@2.45.1`  

---

## ⚠️ CRITICAL: Supabase Client Variable Name Enforcement

### ❗ THE ONLY VALID SUPABASE CLIENT VARIABLE IS:

```javascript
supabaseClient
```

### 🚫 NEVER USE:
- ❌ `Supabase`
- ❌ `supabase`
- ❌ `client`
- ❌ `db`
- ❌ Any other variation

### ✅ MANDATORY PATTERN:

**All HTML pages MUST use this exact pattern:**

```javascript
const SUPABASE_URL = 'https://ekndrsvdyajpbaghhzol.supabase.co';
const SUPABASE_ANON_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImVrbmRyc3ZkeWFqcGJhZ2hoem9sIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzMyNjc4NTEsImV4cCI6MjA0ODg0Mzg1MX0.VCJxi5ECgy4gCzk6UbkAJSaWBpx7_y0kZSZRgD7HkVo';
const supabaseClient = window.supabase.createClient(SUPABASE_URL, SUPABASE_ANON_KEY);
```

### 📌 Enforcement Rules:

1. **Before writing ANY Supabase code:**
   - Scan the current file for existing Supabase client variable
   - If `supabaseClient` exists, REUSE IT
   - NEVER create new variables like `supabase`, `client`, etc.

2. **All Supabase operations MUST use `supabaseClient`:**
   ```javascript
   // ✅ CORRECT
   await supabaseClient.from('students').select('*')
   await supabaseClient.auth.signIn()
   await supabaseClient.storage.from('bucket').upload()
   
   // ❌ WRONG - Will cause "supabase.from is not a function" error
   await supabase.from('students').select('*')
   await Supabase.from('students').select('*')
   ```

3. **Auto-Fix Rule:**
   - If you catch yourself writing `supabase.from(...)`, immediately rewrite as `supabaseClient.from(...)`
   - This applies to ALL Supabase operations: queries, inserts, updates, deletes, auth, storage, realtime

4. **Applies to:**
   - Database queries (`.from()`, `.select()`, `.insert()`, `.update()`, `.delete()`)
   - Authentication (`.auth.signIn()`, `.auth.signOut()`, `.auth.getSession()`)
   - Storage operations (`.storage.from()`)
   - Realtime subscriptions (`.channel()`, `.on()`)
   - Edge Function calls (`.functions.invoke()`)

### 🧠 Copilot Behavior:
**ASSUME**: "This project uses `supabaseClient` as the single source of truth for all Supabase access. No exceptions."

---

## 🗄️ Data Layer: Supabase Schema & Cross-Module Contracts

### Complete Table Schema & Indexes
All tables with their primary keys, indexes, and unique constraints:

**Key Payment Tables**:
- `payments` - Automated payment imports (Zelle/Venmo)
  - PK: `id`
  - Unique: `gmail_id`, `(student_id, for_class)` where both NOT NULL
  - Key indexes: `student_id`, `for_class`, `email_date`, `payer_name`, `linked_student_id`
  - Important: `unique_student_class_payment` prevents duplicate student-date combinations

- `payment_records` - Manual payment entries
  - PK: `id`
  - Index: `(student_id, status)` where status='paid'

- `credit_payments` - Credit-based payments
  - PK: `id`
  - Unique: `(student_id, class_date)`
  - Indexes: `student_id`, `class_date`, `applied_class_date`, `(student_id, applied_class_date)`

- `manual_payment_moves` - Payment reassignment history
  - PK: `id`
  - Unique: `(student_id, from_date, to_date)`
  - Indexes: `student_id`, `(from_date, to_date)`

**Student & Group Tables**:
- `students` - Student records
  - PK: `id`
  - Indexes: `auth_user_id`, `show_in_grid`
  - Fields: `name`, `group_name` (stores "A", "B", "C", etc.), `price_per_class`, `balance`, `aliases[]`, `email`, `phone`, `status`, `notes`, `show_in_grid`
  - **IMPORTANT**: Uses `group_name` NOT `group_letter`

- `student_absences` - Absence tracking
  - PK: `id`
  - Unique: `(student_id, class_date)`
  - Indexes: `class_date`, `(student_id, class_date)`

- `groups` - Group definitions
  - PK: `id`
  - Index: `group_name`
  - Fields: `group_name` (stores "A", "B", "C", etc.), `schedule` (TEXT format like "Mon 8:00 PM, Wed 8:00 PM"), `active`, `color`, `one_time_schedules`, `updated_at`

- `skipped_classes` - Group-wide class cancellations
  - PK: `id`
  - Unique: `(group_name, class_date)`
  - Indexes: `group_name`, `class_date`, `skip_type`, `(group_name, class_date)`, `(group_name, class_date, skip_type)`

**Notes & Documents**:
- `student_notes` - PDF notes system
  - PK: `id`
  - Indexes: `created_at`, `(group_name, class_date)`, `requires_payment`, `(group_name, sort_order, created_at)`, `category`, `system_category`
  - Fields: `title`, `pdf_url`, `system_category`, `requires_payment`, `is_system_note`, `class_date`, `created_at`

- `note_folders` - Note organization
  - PK: `id`
  - Unique: `(folder_name, group_name)`
  - Indexes: `group_name`, `sort_order`
  - **FIXED**: Uses `group_name` NOT `group_letter`

- `note_templates` - Note templates
  - PK: `id`
  - Index: `folder_id`

- `note_assignments` - Template-to-group assignments
  - PK: `id`
  - Unique: `(template_id, group_id, class_date)`
  - Indexes: `(group_id, class_date)`, `template_id`, `sort_order`

- `note_purchases` - Note purchase tracking
  - PK: `id`
  - Unique: `purchase_code`, `(student_id, note_id)`
  - Indexes: `student_id`, `note_id`, `payment_id`, `purchase_code`, `status`

- `note_free_access` - Free note access grants
  - PK: `id`
  - Unique: `(note_id, group_letter)`, `(note_id, student_id)`
  - Indexes: `note_id`, `student_id`, `group_letter`
  - Fields: `note_id`, `access_type` ('group' or 'individual'), `group_letter`, `student_id`, `created_by`

- `student_note_permissions` - Note access permissions
  - PK: `id`
  - Unique: `(note_id, student_id, group_name)`
  - Indexes: `note_id`, `student_id`, `group_name`, `is_accessible`

**Test System**:
- `tests` - Test containers
  - PK: `id`
  - Index: `is_active`

- `test_questions` - Test questions
  - PK: `id`
  - Indexes: `test_id`, `category`, `difficulty`, `rationale`

- `question_banks` - Question bank definitions
  - PK: `id`

- `qbank_questions` - Questions in banks
  - PK: `id`
  - Unique: `(qbank_id, question_id)`
  - Indexes: `qbank_id`, `question_id`

- `test_reactions` - Test UI reactions
  - PK: `id`

**Email & Communication**:
- `sent_emails` - Email audit trail
  - PK: `id`
  - Indexes: `recipient_email`, `sent_at`, `template_id`

- `email_templates` - Email templates
  - PK: `id`
  - Unique: `name`
  - Indexes: `name`, `(trigger_category, trigger_type)`

- `automations` - Email automations
  - PK: `id`
  - Indexes: `active`, `created_at`, `recipient_type`, `template_id`, `(trigger_category, trigger_type)`, `trigger_category`, `trigger_type`

- `auto_reminder_paused` - Paused reminders
  - PK: `id`
  - Unique: `student_id`
  - Index: `student_id`

**Admin & Auth**:
- `admin_accounts` - Admin whitelist
  - PK: `auth_user_id`
  - Unique: `email`

- `user_preferences` - User settings
  - PK: `id`
  - Unique: `user_id`
  - Index: `user_id`

**Session & Activity**:
- `session_logs` - Session tracking
  - PK: `id`
  - Indexes: `student_id`, `session_start`, `is_active`

- `student_sessions` - Active sessions
  - PK: `id`
  - Indexes: `student_id`, `last_activity`, `is_active`

**Alerts & Notifications**:
- `student_alerts` - Student alerts
  - PK: `id`
  - Indexes: `student_id`, `created_at`, `is_read`, `read_at`, `has_question`, `student_answer`, `scheduled_for`, `show_on_open`

- `notifications` - System notifications
  - PK: `id`
  - Indexes: `timestamp`, `type`, `student_name`, `is_read`, `read`

**Supporting Tables**:
- `payer_aliases` - Payment name aliases
  - PK: `id`
  - Indexes: `student_id`, `payer_name`

- `schedule_changes` - Schedule change log
  - PK: `id`
  - Indexes: `group_name`, `created_at`

- `credit_log` - Credit balance history
  - PK: `id`
  - Indexes: `student_id`, `created_at`

- `portal_settings` - Portal configuration
  - PK: `id`
  - Unique: `setting_key`
  - Index: `setting_key`

- `student_waiting_list` - Waiting list
  - PK: `id`
  - Unique: `email`
  - Indexes: `email`, `status`, `created_at`

- `gmail_credentials` - Gmail OAuth tokens
  - PK: `id`
  - Unique: `user_id`
  - Indexes: `user_id`, `expires_at`

- `test_email_addresses` - Test email whitelist
  - PK: `id`
  - Unique: `email`
  - Index: `email`

- `pdf_media` - PDF media files
  - PK: `id`
  - Indexes: `note_id`, `created_at`

- `forum_messages` - Forum posts
  - PK: `id`
  - Indexes: `student_id`, `created_at`, `is_pinned`, `id` (where attachment_url NOT NULL)

- `forum_replies` - Forum replies
  - PK: `id`
  - Indexes: `message_id`, `student_id`

- `group_notes` - Group note assignments (legacy?)
  - PK: `id`
  - Indexes: `(group_id, class_date)`, `folder_id`, `class_date`

### Core Tables (shared across all pages)
| Table | Owner | Readers | Key Fields | Notes |
|-------|-------|---------|-----------|-------|
| `students` | `Student-Manager.html` | `Calendar`, `student-portal`, `Payment-Records` | `id`, `name`, `group_name`, `price_per_class`, `balance`, `show_in_grid`, `aliases[]`, `email`, `phone`, `status`, `notes` | Source of truth for student records |
| `payment_records` | `Payment-Records.html` | `Calendar`, `student-portal` | `student_id`, `date`, `amount`, `status` (`paid\|unpaid\|pending\|cancelled\|absent`) | Manual payment entries |
| `payments` | Auto (Zelle/Venmo) | `Payment-Records`, `student-portal` | `linked_student_id`, `student_id`, `resolved_student_name`, `payer_name`, `for_class` | Automated payment imports with unique constraint on (student_id, for_class) |
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

### Row Level Security (RLS) Policies
Complete RLS policies by table - **NEVER modify these without explicit instruction**:

**Admin Helper Function**:
- `is_arnoma_admin()` - Checks if user exists in `admin_accounts` table

**Key Policy Patterns**:

1. **Admin-Only Tables** (full access for admins):
   - `admin_accounts`, `automations`, `email_templates`, `sent_emails`, `test_email_addresses`
   - `manual_payment_moves`, `notifications`, `schedule_changes`
   
2. **Admin Write / Public Read**:
   - `payments` - Admins manage, anon can read/insert (for automated imports), update with gmail_id
   - `payment_records` - Admins manage, anon can read
   - `students` - Admins manage, authenticated can view own record
   - `tests`, `test_questions`, `question_banks`, `qbank_questions` - Admins manage, public can view active

3. **Student Self-Access**:
   - `student_alerts` - Students can view/update own alerts, admins full access
   - `student_sessions` - Students can create/view/update own sessions, admins full access
   - `session_logs` - Students can create/view/update own logs, admins view all
   - `forum_messages`, `forum_replies` - Students can create/delete own, view all

4. **Group-Based Access**:
   - `student_notes` - Students view their group's non-deleted notes, admins full access
   - `note_assignments` - Students view assigned notes for their group
   - `group_notes` - Students view their group's notes, admins manage
   - `skipped_classes` - Students read their group's skipped classes, admins manage

5. **Special Cases**:
   - `note_purchases` - Public can create/update/view, admins full access
   - `note_free_access` - Students view free access, anon can read (for impersonation)
   - `student_note_permissions` - Authenticated users can manage/read
   - `credit_payments`, `credit_log` - Students view own, admins manage
   - `portal_settings` - Everyone can read, admins can update
   - `student_waiting_list` - Anon can insert, authenticated can read/update/delete

**Critical Policy Rules**:
- **Never weaken payment table policies** - Calendar and Payment-Records depend on admin-only writes
- **Anon read policies** exist for impersonation mode (admin viewing as student)
- **Public policies** (`{public}` role) allow both authenticated and anon access
- **Test suite patterns** - Some policies check for `audit_test_%` prefix in names
- **Email-based auth** - Many policies use `auth.jwt() ->> 'email'` for matching
- **UID-based auth** - Admin policies use `auth.uid()` matched against `admin_accounts.auth_user_id`

**Common Policy Checks**:
```sql
-- Admin check (UID)
EXISTS (SELECT 1 FROM admin_accounts WHERE admin_accounts.auth_user_id = auth.uid())

-- Admin check (Email)
EXISTS (SELECT 1 FROM admin_accounts WHERE admin_accounts.email = (auth.jwt() ->> 'email'))

-- Student self-access (UID)
student_id IN (SELECT students.id FROM students WHERE students.auth_user_id = auth.uid())

-- Student self-access (Email)
student_id IN (SELECT students.id FROM students WHERE students.email = auth.email())

-- Helper function
is_arnoma_admin()
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
