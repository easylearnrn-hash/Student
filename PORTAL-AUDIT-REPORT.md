# ARNOMA Portal Audit Report

_Date:_ December 2, 2025  
_Author:_ GitHub Copilot AI Assistant

## 1. Scope
- `student-portal.html`
- `Student-Portal-Admin.html`
- Shared dependencies: `shared-auth.js`, `shared-dialogs.js`
- Supabase tables touched: `students`, `groups`, `student_sessions`, `payment_records`, `payments`, `note_assignments`, `note_templates`, `note_folders`, `schedule_changes`, `forum_messages`, `forum_replies`, `nurses_forum`.

## 2. Authentication & Impersonation
- Student portal enforces Supabase Auth via `checkAuthentication()`, falling back to impersonation tokens stored in `sessionStorage.impersonation_token`.
- Admin portal requires `ArnomaAuth.ensureSession`, attaches listeners once, and records current admin email for note creation and audit trails.
- Impersonation flow validates token expiry + student ID, hides the admin button, and ensures logout clears timers.

## 3. Core Data Flows
### 3.1 Student Portal
- **Schedule:** Loads group records, normalizes codes via `canonicalizeGroupCode`, renders triple timezone schedule, and computes next class countdown. Announcements merge `schedule_changes` with `note_assignments` (template metadata).
- **Payments:** Aggregates manual `payment_records` (by student_id) plus Zelle `payments` using ID/name/alias matching. Cards show unpaid amount, latest paid info, and detailed history list.
- **Class Materials:** Pulls `note_assignments` for the student’s normalized group, cross references `note_templates` + folders, and gates attachments using `checkIfPaid`. Missing templates render warnings.
- **Forum:** Uses `forum_messages` + `forum_replies`, includes local badge tracking and 30s polling to surface unread activity.
- **Sessions:** Writes to `student_sessions` on login, updates heartbeat every two minutes, and ends sessions on logout or unload.

### 3.2 Admin Portal
- **Stats Overview:** Counts students, notes, payments (manual + Zelle), and forum threads (with RLS fallbacks).
- **Student Management:** Loads `students` with linked `groups` and `student_sessions` to show online indicators; supports CRUD via modal.
- **Notes & Group Manager:** Fetches folders + templates, supports drag/drop reordering, bulk group assignment creation, and status toggles using shared dialogs.
- **Payments:** Combines `payment_records` joined to `students` with Zelle data, enabling quick filtering and deletion of manual entries.
- **Forum:** Reads `nurses_forum`, counts replies, and allows deletion cascades (parent + replies).
- **Systems Tab:** UI placeholder referencing NCLEX modules; no backend coupling yet.

## 4. Shared Utilities
- `shared-auth.js`: Caches Supabase sessions in `localStorage` with TTL, exposes `ArnomaAuth.ensureSession` + listener attachment.
- `shared-dialogs.js`: Provides glassmorphism `customAlert`, `customConfirm`, `customPrompt` used throughout admin actions.

## 5. Validation & Tooling
- Ran `npx --yes htmlhint student-portal.html Student-Portal-Admin.html`.
- Issue found: empty `iframe` `src` in PharmaQuest modal. Resolved by setting default to `about:blank` while retaining dynamic loading.
- Re-run confirmed zero HTML lint errors. No additional automated tests exist for this static project.

## 6. Recommendations
1. **Document impersonation token contract** so future tooling (or other modules) respects `studentId`, `expiresAt`, and `adminEmail` fields.
2. **Align forum tables**: Student portal uses `forum_messages`/`forum_replies`, admin uses `nurses_forum`. Consider migrating to a single schema or add compatibility notes.
3. **Note health check**: Add admin-side script to flag `note_assignments` whose templates are missing to prevent student-facing warnings.
4. **Session query limits**: Admin session viewer currently pulls the last 10 entries; ensure index coverage and consider date filters as volume grows.

## 7. Completed Fixes
| File | Description |
| --- | --- |
| `student-portal.html` | Set default PharmaQuest iframe `src="about:blank"` to satisfy HTML validators while keeping runtime swap logic. |

## 8. Quality Gate Status
| Gate | Result | Notes |
| --- | --- | --- |
| Build | PASS | Static HTML; no build step required. |
| Lint | PASS | `htmlhint` clean on both portal files. |
| Tests | PASS | No automated tests available; HTMLHint serves as syntax validation. |

## 9. Next Steps
- Review and optionally implement the recommendations above.
- Re-run the HTML hint command after future changes to maintain lint compliance:  
  ```bash
  cd "/Users/richyf/Library/Mobile Documents/com~apple~CloudDocs/COMPLETE NEW /modules"
  npx --yes htmlhint student-portal.html Student-Portal-Admin.html
  ```
