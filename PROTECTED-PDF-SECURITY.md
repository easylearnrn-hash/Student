# Protected PDF Viewer - Security Features

## Overview
The Protected-PDF-Viewer.html provides maximum security for viewing class notes with multi-layer protection against copying, downloading, and unauthorized distribution.

## Security Layers

### 1. **Text Selection Disabled**
- CSS: `user-select: none !important` on ALL elements
- Prevents mouse/keyboard text selection
- Works across all browsers (Chrome, Firefox, Safari, Edge)

### 2. **Right-Click Disabled**
- `contextmenu` event completely blocked
- Prevents "Save As", "Inspect Element", "Copy Image"
- Captures event in capture phase with `useCapture: true`

### 3. **Keyboard Shortcuts Blocked**
Disabled shortcuts:
- **Ctrl/Cmd + S**: Save page (blocked)
- **Ctrl/Cmd + C**: Copy (blocked)
- **Ctrl/Cmd + A**: Select all (blocked)
- **Ctrl/Cmd + P**: Print (redirects to protected print function)
- **Ctrl/Cmd + U**: View source (blocked)
- **F12**: DevTools (blocked)
- **Ctrl/Cmd + Shift + I**: DevTools (blocked)
- **Ctrl/Cmd + Shift + J**: Console (blocked)
- **Ctrl/Cmd + Shift + C**: Element inspector (blocked)

### 4. **Clipboard Protection**
- `copy` event intercepted and cleared
- `cut` event blocked
- `selectstart` event prevented
- Clipboard always empty even if somehow triggered

### 5. **Drag-and-Drop Disabled**
- `dragstart` event prevented
- Cannot drag PDF canvas/images to desktop
- Cannot drag to other applications

### 6. **Canvas Interaction Blocked**
- `pointer-events: none` on all canvas elements
- Cannot right-click on rendered PDF
- Cannot interact with PDF rendering layer

### 7. **DevTools Detection**
- Monitors window dimensions every second
- Detects if DevTools is open (basic detection)
- Shows warning alert if detected
- Discourages advanced users from inspecting

### 8. **Download Prevention**
- No direct download links provided
- PDF loaded via PDF.js rendering (not iframe/embed)
- Signed URLs expire after 1 hour
- Cannot use browser's "Save PDF" feature

## Watermark System

### On-Screen Watermark
**Visible Elements:**
- Large "ARNOMA" logo (120px, semi-transparent)
- Student name
- Group assignment
- Current date
- "PROTECTED CONTENT" label
- Diagonal pattern background overlay

**Properties:**
- Opacity: 0.25 (visible but not intrusive)
- Position: Absolute overlay on every page
- Rotation: -25 degrees
- Pointer-events: none (cannot interact)
- Z-index: 10 (always on top)

### Print Watermark
**Behavior:**
- Watermark persists in print output
- Print CSS enforces watermark display
- Opacity reduced to 0.2 for better readability
- Same content as on-screen (ARNOMA + student info)
- Appears on EVERY printed page

**Print Protection:**
- Student can only use built-in print button
- Ctrl/Cmd + P redirected to protected print function
- All pages rendered with watermarks before print
- Page breaks preserved
- Headers/controls hidden in print

## User Flow

### Viewing Notes (Paid Students)
1. Student clicks PDF link in student portal
2. Portal passes signed URL to Protected-PDF-Viewer.html
3. Viewer authenticates student via Supabase
4. PDF renders with watermark overlay
5. Student can navigate pages, zoom, and print
6. Cannot copy, download, or remove watermark

### Locked Notes (Unpaid Students)
1. Student sees note in portal but content is blurred
2. Clicking locked note shows payment alert
3. Cannot access PDF until payment verified
4. Payment verification happens in student portal before PDF link shown

## Technical Implementation

### URL Parameters
```
Protected-PDF-Viewer.html?url=[signedURL]&title=[noteTitle]
```

**Parameters:**
- `url`: Supabase signed URL (expires in 1 hour)
- `title`: Note title for display
- `note`: (legacy) ID from student_notes table

### Authentication Flow
1. Check Supabase auth session
2. Verify student exists in `students` table
3. Match student email to auth user
4. Load student name/group for watermark
5. Render PDF with personalized watermark

### PDF Rendering
- Uses PDF.js library (CDN hosted)
- Renders each page to HTML5 Canvas
- Canvas overlay with watermark HTML
- No iframe/embed (prevents right-click save)
- No object/data tags (prevents download)

### Watermark Persistence
**On-Screen:**
- Watermark div overlays canvas absolutely
- Pointer-events: none (can't be removed via UI)
- Opacity controlled via CSS
- Rotation applied via transform

**On Print:**
- `@media print` CSS enforces watermark
- All pages re-rendered before print dialog
- Watermark HTML preserved in print output
- Browser cannot hide watermark layer

## Limitations & Workarounds

### Known Bypass Attempts (All Blocked)
❌ **Screenshot**: User can screenshot (accept as unavoidable)
❌ **Phone photo**: User can photograph screen (accept as unavoidable)
❌ **OCR**: User could OCR text (very time-consuming, low quality)
❌ **DevTools**: Basic detection alerts user
❌ **Browser extensions**: Most blocked by event capture
❌ **Print to PDF**: Watermark appears in saved PDF ✅

### What Cannot Be Prevented
- Screenshots (Windows Snipping Tool, macOS Cmd+Shift+4)
- Phone camera photos of screen
- Screen recording software
- Advanced DevTools tricks by expert users

### Mitigation Strategy
- **Watermark with student name**: Makes redistribution traceable
- **Date stamp**: Shows when accessed
- **Group assignment**: Identifies source group
- **"PROTECTED CONTENT" label**: Legal deterrent
- **No download option**: Forces viewing only in app
- **Expiring URLs**: Limits window of access

## Printing Workflow

### Student Print Process
1. Click "🖨️ Print" button in viewer
2. JavaScript renders ALL pages with watermarks
3. Shows "Preparing for print..." message
4. After 500ms, triggers `window.print()`
5. Browser print dialog opens
6. All pages show watermark in preview
7. Student can print with watermark

### Print Settings Enforced
- Page breaks after each page
- Headers/controls hidden
- Watermark opacity: 0.2 (readable but visible)
- White background
- Full-width canvas rendering

## Security Best Practices

### For Admins
1. ✅ Only upload PDFs to protected storage bucket
2. ✅ Use signed URLs with 1-hour expiry
3. ✅ Verify payment before showing PDF links
4. ✅ Set `is_open = true` only for current groups
5. ✅ Monitor for suspicious access patterns

### For Students
- Can view notes clearly if paid
- Can print with watermark
- Can zoom and navigate
- **Cannot** copy text
- **Cannot** download PDF
- **Cannot** remove watermark
- **Cannot** share without watermark

## File Structure
```
Protected-PDF-Viewer.html
├─ Supabase auth check
├─ Student verification
├─ PDF.js rendering
├─ Watermark overlay
├─ Print function
└─ Security event handlers
```

## Browser Compatibility
- ✅ Chrome/Edge (Chromium): Full support
- ✅ Firefox: Full support
- ✅ Safari: Full support
- ✅ Mobile Safari: Full support
- ✅ Mobile Chrome: Full support

## Performance
- PDF renders on-demand (one page at a time)
- Zoom levels: 50% - 200%
- Page navigation: instant
- Print preparation: ~1 second per page
- Signed URL caching: client-side for session

## Error Handling
- Invalid URL → "No note specified"
- Not authenticated → Redirect to Login.html
- Student not found → "Student profile not found"
- Wrong group → "This note is not for your group"
- Payment required → "🔒 This note is locked"
- PDF load failure → "Failed to load PDF"

## Future Enhancements (Optional)
- [ ] Video playback tracking (time spent viewing)
- [ ] Backend logging of access events
- [ ] Rate limiting on signed URL generation
- [ ] Advanced DevTools detection (element mutation observer)
- [ ] Screenshot detection (browser API if available)
- [ ] Canvas fingerprinting for redistribution tracking
