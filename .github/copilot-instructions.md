# Copilot Instructions for ARNOMA Modules

## Repo shape & runtime
- Each page (`Calendar.html`, `Student-Manager.html`, `Payment-Records.html`, `student-portal.html`, `Group-Notes.html`, `Test-Manager.html`, `Tests-Library.html`, `Student-Test.html`, `Notes-Manager-NEW.html`, `Protected-PDF-Viewer.html`, `PharmaQuest.html`) is a standalone HTML mega-page with inline CSS/JS; there is no bundler or module loader.
- All pages load `@supabase/supabase-js@2` via CDN and hard-code the shared `SUPABASE_URL`/`SUPABASE_ANON_KEY`; always reuse these constants and instantiate clients with `window.supabase.createClient`.

## Cross-module data contracts
- Shared Supabase tables include `students`, `student_notes`, `payment_records`, `payments`, `tests`, `test_questions`, `question_banks`, `qbank_questions`, `sent_emails`, and `admin_accounts`—changing a column means updating every HTML page that queries it.
- `Student-Manager.html` owns `students.show_in_grid`, `price_per_class`, and `balance`; `Calendar.html`, `student-portal.html`, and `Payment-Records.html` all read those fields, so keep schema and normalization logic consistent.

## Auth, impersonation & shared UI
- Admin tools must import `shared-auth.js` and wrap entry points with `ArnomaAuth.ensureSession(supabase)`, which caches tokens in `localStorage` (`arnoma:auth:session`, `arnoma:auth:user`) for 7 days and redirects to `index.html` on failure.
- Student sessions plus admin impersonation lean on Supabase auth plus `sessionStorage.impersonation_token`; always call `exitImpersonation()` before returning to student views.
- Use `shared-dialogs.js` (`customAlert`, `customConfirm`, `customPrompt`) instead of native dialogs to preserve the glassmorphism UI shell.

## Data normalization helpers
- Reuse `canonicalizeGroupCode`/`formatGroupDisplay` for group letters, `parseEmailField` and `getPrimaryEmailValue` for array-or-JSON email fields, and Student Manager’s phone formatter for `xxx-xxx-xxxx` output.
- Payment status strings are immutable (`paid|unpaid|pending|cancelled|absent`); Payment-Records neon badges and Student Portal summaries assume these exact tokens.

## Notes & PDF security
- `Notes-Manager-NEW.html` uploads PDFs to the `student-notes` bucket and writes `student_notes.requires_payment`; `Protected-PDF-Viewer.html` enforces the flag with signed URLs, watermarks, and shortcut blocking—don’t weaken those checks when editing the viewer.

## Payments, email, and logging
- Student Portal combines manual `payment_records` and automated `payments` by matching `linked_student_id`, `student_id`, and `resolved_student_name`; maintain that triple-lookup when touching payment logic.
- `Email-System.html` calls the Supabase Edge Function `functions/v1/send-email`, persists `sent_emails` metadata (`email_type`, `resend_id`, `delivery_status`), and stores drafts/history in `localStorage` (`arnoma-email-templates-v7`, `arnoma-automations-v1`, `arnoma-sent-emails-v1`).
- Each mega-page exposes a `DEBUG_MODE` flag plus an emoji `debugLog`; toggle it on for troubleshooting and reset to `false` before committing.

## Calendar & caching patterns
- `Calendar.html` and `Student-Manager.html` both define `DOMCache` + `DataCache` helpers (5‑minute TTL) to avoid repeated DOM lookups and Supabase queries—whenever you mutate the DOM or invalidate data, clear the relevant cache entries.

## Test system specifics
- `Test-Manager.html` orchestrates `tests`, `test_questions`, `question_banks`, and `qbank_questions`: it supports single-question creation, pipe-delimited or multi-line bulk imports (auto-detects ✔️ answers), and JSON uploads that can auto-create Q-Banks.
- Custom Q-Bank categories are stored in `localStorage.customCategories`; JSON imports may spawn new banks and then link inserted questions through `qbank_questions`.
- `Tests-Library.html` groups active tests by `system_category` and counts linked banks, while `Student-Test.html` fetches by `testId`, provides shuffle via `toggleShuffle`, and displays reactions sourced from `localStorage.arnoma-test-reactions-v1` (also edited inside Test Manager’s Reactions tab with `{ correct: string[], incorrect: string[] }`).

## Notes on SQL & migrations
- Root-level `*.sql` files (`setup-notes-system.sql`, `setup-test-questions-rls.sql`, `optimize-payment-records-indexes.sql`, etc.) document manual Supabase migrations; update or add scripts whenever you touch schema or RLS so ops can replay changes.
- Before renaming a column/table, grep every HTML mega-page and markdown playbook to keep cross-module queries synced.

## Local dev workflow
- Serve the repo statically (`python3 -m http.server 8000` from the repo root) and open `http://localhost:8000/<page>.html`; there’s no bundler, build step, or automated tests, so manually walk through auth → data fetch → primary action after each change.
- Supabase calls hit the live project—use staging data or feature flags for risky work, and force refresh (`Cmd+Shift+R`) when inline scripts appear stale.
