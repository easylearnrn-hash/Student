# Copilot Instructions for ARNOMA Modules

## Architecture & Data Flow
- This repo is a collection of standalone HTML mega-pages (e.g., `Calendar.html`, `Student-Manager.html`, `student-portal.html`) that each bundle markup, styles, and vanilla JS; there is **no bundler or module system**, so every page must remain self-contained.
- Every interactive view talks directly to Supabase via the CDN `@supabase/supabase-js@2` client; the shared backend schema centers on `students`, `student_notes`, `payment_records`, `payments`, `nurses_forum`, `email_templates`, `sent_emails`, and `test_email_addresses`.
- **Data flows between modules**: e.g., `Student-Manager.html` writes `students.show_in_grid` and `students.balance`, which are consumed by `Calendar.html`, `student-portal.html`, and `Payment-Records.html`. Changing a column shape requires updating all consumers.
- **Cross-module dependencies**: always grep for table/column names across all HTML files before schema changes to find all affected rendering and query logic.

## Authentication, Permissions & Shared Utilities
- **Admin authentication**: Admin-only tools (Notes Manager, Payment Records, Email System) load `shared-auth.js` and must gate actions with `ArnomaAuth.ensureSession`. This checks session cache in `localStorage` (keys: `arnoma:auth:session`, `arnoma:auth:user`) with 7-day TTL.
- **Student authentication**: Student-facing pages rely on Supabase auth sessions OR the admin impersonation token saved in `sessionStorage.impersonation_token` (set by admins in `Student-Manager.html`).
- **Admin detection**: `student-portal.html` verifies admin status by checking `admin_accounts` table in Supabase. Students must NOT be in both `students` AND `admin_accounts` tables. Portal Admin button is hidden by default and only shown for verified admins.
- **Impersonation pattern**: Always call `exitImpersonation()` when building admin tools that redirect back to the portal; clears `sessionStorage.impersonation_token` and navigates to admin view.
- **Modal dialogs**: Use `shared-dialogs.js` helpers (`customAlert`, `customConfirm`, `customPrompt`) for consistent glassmorphism modals instead of `window.alert/confirm/prompt`.
- **Debug logging**: `DEBUG_MODE` flags live near the top of most scripts; flip to `true` for verbose emoji-tagged logging via the local `debugLog` wrapper (e.g., `✅`, `❌`, `🔄`), then **always revert to `false` before committing**.

## Key Module Contracts & Data Shapes
- **Student-Manager.html**: Normalizes group codes via `canonicalizeGroupCode(value)` (strips "group" prefix, uppercases single letter), enforces numeric `price_per_class`/`balance`, and toggles `show_in_grid`. Any new student fields saved here must be added to the Supabase mapping block (`saveStudent`) and the card renderer.
- **Calendar.html**: Depends on `students.show_in_grid = true` to display students in the calendar grid. Uses `DOMCache` and `DataCache` (5-min TTL) for performance. Emoji-narrated logs (e.g., `🌟 Calendar initialized`).
- **student-portal.html**: Aggregates payments from BOTH `payment_records` (manual) AND `payments` (Zelle) by matching `linked_student_id`, `student_id`, and `resolved_student_name`; keep that triple-query flow intact when altering payment logic.
- **Notes-Manager.html**: Uploads PDFs to `student-notes` storage bucket and inserts `student_notes.requires_payment` boolean; `Protected-PDF-Viewer.html` enforces this field to block unpaid students (client-side watermark + shortcut blocking).
- **Email-System.html**: Calls Supabase Edge Function `functions/v1/send-email` and stores `sent_emails` with `email_type`, `resend_id`, `delivery_status`. Tracks in `localStorage` keys: `arnoma-email-templates-v7`, `arnoma-automations-v1`, `arnoma-sent-emails-v1`.
- **Payment-Records.html**: Expects `payment_records.status` values: `paid`, `unpaid`, `pending`, `cancelled`, or `absent`. Neon badges render based on these exact strings.
- **PharmaQuest.html**: Standalone NCLEX study game; no shared state with other modules.

## Email & Phone Field Handling
- **Email normalization**: Use `parseEmailField(emailData)` from `Student-Manager.html` to handle arrays OR JSON strings; returns array of emails.
- **Primary email**: Use `getPrimaryEmailValue(emailData)` to extract first email after normalization.
- **Email storage**: Fields may be arrays `["email1", "email2"]` or JSON strings `'["email1","email2"]'`; always sanitize before calling `.replace` or string methods.
- **Phone formatting**: Auto-format to `xxx-xxx-xxxx` in Student Manager; display one per line.

## Group Code Normalization
- **Canonical form**: Groups must be uppercase single letters (A-F). Use `canonicalizeGroupCode(value)` which strips "group" prefix, removes non-alphanumeric chars, and uppercases.
- **Display form**: Use `formatGroupDisplay(code)` → `"Group A"` for UI rendering.
- **Consistency**: Never invent new parsing logic; reuse these helpers across all modules.

## External Services & SQL Tooling
- **Supabase credentials**: Hard-coded per page (SUPABASE_URL, SUPABASE_ANON_KEY); reuse existing constants instead of introducing env loaders.
- **Edge Functions**: Currently deployed: `send-email`, `gmail-refresh-token`, `gmail-oauth-callback`. Document any new Edge Functions you call.
- **SQL migrations**: Manual helpers (`setup-notes-system.sql`, `create-notes-system.sql`, `fix-absences-rls.sql`, `migrate-forum-database.sql`) are run directly in Supabase SQL editor. Update them alongside schema changes so ops can replay setup.
- **Email delivery**: Runs through Resend API; ensure `sent_emails` captures all metadata (type, resend_id, delivery_status) so previews keep working.

## Local Development Workflow
- **No build step**: Serve directory with static server (team convention: `python3 -m http.server 8000` from repo root) and load via `http://localhost:8000/<page>.html`.
- **Live Supabase**: Everything hits live Supabase; test destructive changes in a staging project or behind feature flags. There is no mock backend.
- **Debugging**: Browser console logs (emoji-tagged in Student Manager and Calendar) are the primary debugging tool. Watch for `✅`, `❌`, `⚠️`, `🔄` messages before assuming data bugs.
- **Cache busting**: Pages include `Cache-Control: no-cache` meta tags; force reload (Cmd+Shift+R) if stale JS persists.

## Performance Patterns
- **DOM caching**: `DOMCache` objects (e.g., in `Calendar.html`, `Student-Manager.html`) eliminate repeated `getElementById` calls. Initialize once in `init()`, invalidate when DOM changes.
- **Data caching**: `DataCache` with TTL (default 5 minutes) caches expensive computations (month data, filtered lists). Check cache age before refetching.
- **Example pattern**:
  ```javascript
  const DOMCache = {
    studentsGrid: null,
    init() { this.studentsGrid = document.getElementById('studentsGrid'); },
    invalidate(key) { this[key] = null; }
  };
  const DataCache = {
    students: null,
    lastFetch: {},
    TTL: 5 * 60 * 1000,
    get(key) {
      const age = Date.now() - (this.lastFetch[key] || 0);
      return age > this.TTL ? null : this[key];
    }
  };
  ```

## Implementation Conventions & Gotchas
- **Preserve existing functionality**: Never remove working code; only ADD features. Backward compatibility is critical.
- **Script loading**: Use `<script src="...">` tags; ES module imports (`import/export`) are NOT supported.
- **localStorage keys**: Document all new keys you add. Existing: `arnoma:auth:session`, `arnoma:auth:user`, `arnoma-email-templates-v7`, `arnoma-automations-v1`, `arnoma-sent-emails-v1`.
- **sessionStorage keys**: `impersonation_token` (admin impersonation flow).
- **Payment status strings**: Must be exact: `paid`, `unpaid`, `pending`, `cancelled`, `absent`.
- **PDF security**: `Protected-PDF-Viewer.html` uses signed URLs + client-side restrictions (watermark overlay, shortcut blocking, right-click disabled). Keep all protections intact.

## Validation Checklist
- **Manual testing required**: After editing a module, reload via local server and walk through the primary flow: auth → data fetch → main action. There are no automated tests.
- **Cross-module sync**: For Supabase schema changes, confirm all affected pages stay in sync. Example: adding a column to `students` requires updating Student Manager cards, Student Portal display, Calendar filters, and Payment exports.
- **Pre-commit cleanup**: Reset `DEBUG_MODE` to `false`, remove `console.log` spam, ensure helper scripts are linked with `<script src="...">`.
- **Status values**: Verify payment/student status strings match expected enums before saving.
- **Email field safety**: Test email normalization with both array and JSON string inputs.
