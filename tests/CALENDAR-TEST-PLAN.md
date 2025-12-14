# Calendar.html - Complete System Test Plan

## Executive Summary
This document outlines the complete test strategy for Calendar.html, a 12,386-line mega-page application managing student schedules, payment tracking, grace periods, and email notifications.

---

## 1️⃣ FUNCTIONAL TESTS

### 1.1 Calendar Rendering
- [ ] **Test: Initial Load**
  - Verify calendar renders current month on page load
  - Confirm correct number of days displayed (28-31)
  - Check first day of month aligns to correct weekday
  - Validate "today" indicator on current date
  - **Expected**: Calendar grid populated, no blank squares

- [ ] **Test: Month Navigation**
  - Click "Previous Month" → verify correct month/year displayed
  - Click "Next Month" → verify correct month/year displayed
  - Navigate 12 months forward → verify year increments
  - Navigate backward across year boundary → verify year decrements
  - **Expected**: Month header updates, day grid refreshes, no duplicate days

- [ ] **Test: Multi-Month Data Loading**
  - Navigate to December 2025
  - Verify payment data loads from cache
  - Navigate to January 2026
  - Confirm new month data fetched and cached
  - **Expected**: No data loss, smooth transitions, monthCache keys updated

### 1.2 Student Management
- [ ] **Test: Student Grid Display**
  - Verify all students with `show_in_grid=true` appear
  - Confirm students sorted by group (A-F)
  - Check student cards show: name, balance, group letter, college badge
  - **Expected**: Grid populated, correct grouping, no duplicates

- [ ] **Test: Student Filtering**
  - Enter search term → verify filtered students match query
  - Clear search → verify all students reappear
  - Search by alias → verify student found
  - Search non-existent name → verify "No results" message
  - **Expected**: Instant filtering, case-insensitive, searches aliases

- [ ] **Test: Balance Display**
  - Student with positive balance → verify red negative badge
  - Student with zero balance → verify "Paid Up" green badge
  - Student with credit → verify blue positive badge
  - **Expected**: Correct color coding, accurate amounts

### 1.3 Payment Matching Logic (CRITICAL)
- [ ] **Test: Same-Month Payment Matching (Dec 2025+)**
  - Class on Dec 7, payment on Dec 9 → verify PAID (grace period)
  - Class on Dec 7, payment on Dec 5 → verify PAID (same month)
  - Class on Dec 7, payment on Nov 30 → verify UNPAID (wrong month)
  - **Expected**: Grace period logic applies, same-month filter enforced

- [ ] **Test: Grace Period Calculation**
  - Group D: Mon 8PM, Wed 8PM, Sun 9AM schedule
  - Class on Monday Dec 1 → grace period until Tuesday Dec 2 11:59PM
  - Payment on Dec 2 → verify matches Monday class
  - Payment on Dec 3 → verify does NOT match Monday class
  - **Expected**: findNextClassDate() returns correct date, grace period accurate

- [ ] **Test: Payment Priority**
  - Student has 2 unpaid classes (Dec 1, Dec 3)
  - Payment on Dec 2 → verify matches Dec 1 class (oldest first)
  - Second payment → verify matches Dec 3 class
  - **Expected**: FIFO payment allocation, no double-matching

- [ ] **Test: Manual vs Automated Payments**
  - Manual payment in `payment_records` table → verify displayed
  - Automated payment in `payments` table → verify displayed
  - Both on same date → verify no duplicates
  - **Expected**: Merged payment list, correct source attribution

- [ ] **Test: Multi-Source Student Lookup**
  - Payment with `student_id` → verify direct match
  - Payment with `linked_student_id` → verify linked match
  - Payment with `payer_name` matching alias → verify alias match
  - Payment with `resolved_student_name` → verify name match
  - **Expected**: Triple-lookup pattern catches all variations

### 1.4 Email System
- [ ] **Test: Payment Reminder Email**
  - Click red unpaid dot → verify email modal opens
  - Verify unpaid amount calculated from monthCache (not DOM)
  - Verify unpaid class count matches red dots
  - Send email → verify Edge Function called with correct data
  - **Expected**: Email shows actual unpaid amount (not $0.00)

- [ ] **Test: Email Template Loading**
  - Open email modal → verify template loads from localStorage
  - No template saved → verify default template used
  - Template with merge fields → verify student name/balance inserted
  - **Expected**: Template renders correctly, merge fields replaced

- [ ] **Test: Email History**
  - Send email → verify entry in `sent_emails` table
  - Check `email_type`, `resend_id`, `delivery_status` populated
  - Resend email → verify new entry created
  - **Expected**: Full audit trail, no duplicate tracking

### 1.5 Group Assignment
- [ ] **Test: Student-to-Group Mapping**
  - Student assigned to Group D → verify appears in Group D schedule
  - Student removed from group → verify disappears from calendar
  - Student in multiple groups → verify appears in all group slots
  - **Expected**: `studentsByGroup` object accurate, no orphaned students

- [ ] **Test: Schedule Display**
  - Group D schedule: Mon 8PM, Wed 8PM, Sun 9AM
  - Verify classes render on correct days
  - Verify time labels correct (LA timezone)
  - Verify student names appear under each class time
  - **Expected**: Schedule matches `groups` table, correct timezone conversion

### 1.6 Status Indicators
- [ ] **Test: Class Status Colors**
  - Unpaid class → red dot
  - Paid class → green dot
  - Canceled class → gray dot with strikethrough
  - Absent student → orange dot
  - Upcoming class → blue dot
  - **Expected**: Correct color mapping, no color bleed

- [ ] **Test: Hover Tooltips**
  - Hover over red dot → verify tooltip shows "Unpaid - $50"
  - Hover over green dot → verify tooltip shows payment date/amount
  - Hover over gray dot → verify tooltip shows "Canceled"
  - **Expected**: Instant tooltip, accurate data, no layout shift

---

## 2️⃣ PAYMENT / DATA LOGIC TESTS

### 2.1 Data Fetching
- [ ] **Test: Initial Data Load**
  - Page load → verify students, groups, payments fetched in parallel
  - Verify data stored in `window.studentsCache`, `window.groupsCache`, `window.paymentsCache`
  - Verify monthCache populated for current month
  - **Expected**: All caches populated, no null datasets

- [ ] **Test: Cache Invalidation**
  - Modify student → verify `dataCache.clear()` called
  - Modify payment → verify monthCache cleared
  - Navigate to new month → verify only new month data fetched
  - **Expected**: Stale data purged, fresh data loaded

- [ ] **Test: Data Normalization**
  - Student with `group_letter="a"` → verify normalized to "A"
  - Student with email JSON array → verify parsed to string
  - Student with phone "1234567890" → verify formatted to "123-456-7890"
  - **Expected**: All data follows normalization rules

### 2.2 Payment Allocation
- [ ] **Test: December 2025 Allocation Reset**
  - Payment used in November → verify can be reused in December
  - Payment matched to Dec 1 class → verify not matched to Dec 3 class
  - **Expected**: Monthly allocation reset, no cross-month pollution

- [ ] **Test: Allocation Tracking**
  - Track `usedPaymentIds` set during month render
  - Verify payment marked as used after matching
  - Verify used payment skipped in subsequent class matching
  - **Expected**: No payment used twice in same month

### 2.3 Balance Calculation
- [ ] **Test: Real-Time Balance**
  - Student starts with balance = 0
  - Add unpaid class → verify balance increases by price_per_class
  - Add payment → verify balance decreases by payment amount
  - **Expected**: Balance = (unpaid classes × price) - total payments

- [ ] **Test: Credit Handling**
  - Payment exceeds unpaid amount → verify credit displayed
  - Credit carried forward to next month → verify balance negative
  - **Expected**: Overpayments handled gracefully, no data loss

---

## 3️⃣ UI + DOM TESTS

### 3.1 Rendering Performance
- [ ] **Test: Initial Render Time**
  - Measure time from page load to calendar visible
  - **Target**: < 1 second on modern hardware
  - **Expected**: No blocking operations, progressive rendering

- [ ] **Test: Re-Render Efficiency**
  - Change month → measure time to update calendar
  - **Target**: < 300ms
  - Verify only changed elements updated (not full page rebuild)
  - **Expected**: Incremental DOM updates, smooth transitions

- [ ] **Test: Template Cloning**
  - Verify `<template>` elements used for card creation
  - Benchmark cloneNode() vs createElement() performance
  - **Expected**: Template cloning 3-5× faster than manual creation

### 3.2 Glassmorphism UI
- [ ] **Test: Visual Consistency**
  - Verify all panels use `--panel-blur: 8px`
  - Verify modals use `--modal-blur: 14px`
  - Verify backdrop-filter applied correctly
  - **Expected**: Consistent glass effect, no opaque backgrounds

- [ ] **Test: Modal Behavior**
  - Open modal → verify backdrop dims page
  - Close modal (X button) → verify backdrop removed
  - Close modal (ESC key) → verify modal dismissed
  - Click outside modal → verify modal closes
  - **Expected**: Smooth open/close, no orphaned elements

- [ ] **Test: Animation Performance**
  - Verify infinite animations disabled (per performance note)
  - Check only interactive elements have transitions
  - **Expected**: No CPU heating from animations

### 3.3 Accessibility
- [ ] **Test: Keyboard Navigation**
  - Tab through calendar → verify focus order logical
  - Enter on student card → verify details open
  - ESC on modal → verify modal closes
  - **Expected**: Full keyboard access, visible focus indicators

- [ ] **Test: Screen Reader Support**
  - Verify ARIA labels on interactive elements
  - Check calendar grid has proper role attributes
  - Confirm status changes announced
  - **Expected**: Semantic HTML, proper ARIA usage

### 3.4 Responsive Design
- [ ] **Test: Mobile Layout (< 768px)**
  - Verify student grid stacks vertically
  - Confirm calendar remains scrollable
  - Check modals fit viewport
  - **Expected**: No horizontal scroll, readable text

- [ ] **Test: Tablet Layout (768px - 1024px)**
  - Verify 2-column grid layout
  - Confirm calendar days readable
  - **Expected**: Optimized for touch targets

- [ ] **Test: Desktop Layout (> 1024px)**
  - Verify 3-4 column grid
  - Confirm side-by-side calendar and student list
  - **Expected**: Full information density, no wasted space

---

## 4️⃣ PERFORMANCE TESTS

### 4.1 CPU Benchmarks
```javascript
// Test: Render 500 students
console.time('Render Students');
renderStudentGrid(studentsArray); // 500 items
console.timeEnd('Render Students');
// Target: < 100ms
```

- [ ] **Test: Large Dataset Rendering**
  - Load 500 students → measure render time
  - **Target**: < 100ms
  - Load 1000 payment records → measure merge time
  - **Target**: < 200ms
  - **Expected**: No UI freezing, smooth scroll

- [ ] **Test: Cache Hit Rate**
  - Navigate to month A → cache miss (fetch)
  - Return to month A → cache hit (no fetch)
  - Verify cache TTL (5 minutes)
  - **Expected**: 90%+ cache hit rate during normal usage

- [ ] **Test: Debouncing**
  - Type in search box rapidly → verify debounced updates
  - **Target**: Max 1 filter operation per 300ms
  - Resize window → verify debounced re-render
  - **Expected**: No excessive function calls

### 4.2 Memory Usage
- [ ] **Test: Memory Leaks**
  - Open/close modals 100 times → monitor heap size
  - Navigate months 100 times → check for growth
  - **Expected**: Heap stabilizes, no continuous growth

- [ ] **Test: Cache Size Limits**
  - Populate monthCache with 12 months
  - Verify oldest entries purged when limit exceeded
  - **Expected**: Cache doesn't exceed 50MB

### 4.3 Network Optimization
- [ ] **Test: Parallel Fetching**
  - Page load → verify students, groups, payments fetched simultaneously
  - **Expected**: 3 parallel requests, not sequential

- [ ] **Test: Data Pagination**
  - Verify Supabase queries use range(0, 499)
  - Check multi-page datasets loaded in batches
  - **Expected**: No single request > 500 records

---

## 5️⃣ STRESS TESTS

### 5.1 Maximum Data Volume
- [ ] **Test: 1000 Students**
  - Load 1000 student records
  - Verify calendar renders without crash
  - Check scroll performance remains smooth
  - **Expected**: Handles max realistic load

- [ ] **Test: 10,000 Payments**
  - Load 10,000 payment records
  - Verify matching algorithm completes
  - **Target**: < 2 seconds to process all matches
  - **Expected**: No infinite loops, accurate matching

- [ ] **Test: 50 Groups**
  - Create 50 different group schedules
  - Verify all groups render on calendar
  - **Expected**: No overlap, readable labels

### 5.2 Rapid Interactions
- [ ] **Test: Click Spam**
  - Click "Next Month" 100 times rapidly
  - Verify UI remains responsive
  - Check for duplicate renders
  - **Expected**: Debouncing prevents race conditions

- [ ] **Test: Concurrent Edits**
  - Open 2 browser tabs with Calendar
  - Edit student in Tab 1
  - Verify Tab 2 reflects change (via Supabase)
  - **Expected**: Real-time sync, no conflicts

### 5.3 Edge Cases
- [ ] **Test: Empty States**
  - No students in database → verify "No students" message
  - No groups → verify calendar shows blank grid
  - No payments → verify all classes show unpaid
  - **Expected**: Graceful handling, no errors

- [ ] **Test: Malformed Data**
  - Student with null `price_per_class` → verify default used
  - Payment with invalid date → verify skipped/logged
  - Group with missing schedule → verify error caught
  - **Expected**: Defensive coding, no crashes

---

## 6️⃣ ERROR HANDLING TESTS

### 6.1 Network Failures
- [ ] **Test: Supabase Timeout**
  - Block network → attempt to load calendar
  - Verify error message displayed
  - Restore network → verify retry succeeds
  - **Expected**: User-friendly error, retry mechanism

- [ ] **Test: Auth Failure**
  - Expire session token → attempt action
  - Verify redirect to login page
  - **Expected**: Seamless auth flow, no data loss

- [ ] **Test: Edge Function Failure**
  - Send email with Edge Function down
  - Verify 500 error caught
  - Confirm user notified
  - **Expected**: Error logged, user sees notification

### 6.2 Data Validation
- [ ] **Test: Invalid Email**
  - Student with email "not-an-email"
  - Attempt to send reminder
  - Verify validation error shown
  - **Expected**: Regex check prevents send

- [ ] **Test: Negative Balance**
  - Force balance = -500
  - Verify credit badge shown (not error)
  - **Expected**: Negative values handled as credits

- [ ] **Test: Future Dates**
  - Payment dated in future
  - Verify included in calculations
  - **Expected**: No date filtering excludes future

### 6.3 RLS Policy Violations
- [ ] **Test: Unauthorized Access**
  - Non-admin user attempts to load calendar
  - Verify RLS blocks students/groups/payments query
  - Confirm redirect to login
  - **Expected**: Supabase RLS enforced, no data leak

---

## 7️⃣ INTEGRATION TESTS

### 7.1 Supabase Integration
- [ ] **Test: Table Queries**
  - Verify `students` table query includes all fields
  - Check `payment_records` and `payments` tables merged correctly
  - Confirm `groups` table includes `student_ids` array
  - **Expected**: No missing fields, accurate data shapes

- [ ] **Test: Real-Time Subscriptions**
  - (If implemented) Modify student in Supabase dashboard
  - Verify calendar updates without refresh
  - **Expected**: Live data sync

### 7.2 Shared Module Integration
- [ ] **Test: shared-auth.js**
  - Verify `ArnomaAuth.ensureSession()` called on page load
  - Check session cached in localStorage
  - Confirm auth failure redirects to index.html
  - **Expected**: Auth module works as documented

- [ ] **Test: shared-dialogs.js**
  - Replace `alert()` with `customAlert()`
  - Verify glassmorphism modal appears
  - Check `customConfirm()` returns boolean
  - **Expected**: Native dialogs never shown

### 7.3 Cross-Module Data Flow
- [ ] **Test: Student Manager → Calendar**
  - Add student in Student-Manager.html
  - Refresh Calendar → verify student appears
  - **Expected**: Changes persist across modules

- [ ] **Test: Payment Records → Calendar**
  - Add manual payment in Payment-Records.html
  - Verify class status updates to "Paid" in Calendar
  - **Expected**: Payment matching works across modules

- [ ] **Test: Email System → Calendar**
  - Save email template in Email-System.html
  - Send reminder from Calendar → verify template used
  - **Expected**: Shared localStorage templates

---

## 9️⃣ CROSS-BROWSER TESTS

### 9.1 Chrome (Latest)
- [ ] All functional tests pass
- [ ] CSS Grid layout correct
- [ ] Backdrop-filter renders smoothly
- [ ] localStorage persists across sessions

### 9.2 Safari (Latest)
- [ ] Glassmorphism `-webkit-backdrop-filter` applied
- [ ] Date/time formatting correct (Intl API)
- [ ] No CORS issues with Supabase

### 9.3 Firefox (Latest)
- [ ] Backdrop-filter polyfill works
- [ ] flexbox/grid layouts match Chrome
- [ ] Console logs show no warnings

### 9.4 Mobile Safari (iOS)
- [ ] Touch targets minimum 44×44px
- [ ] Modals don't trigger zoom
- [ ] Scroll performance smooth
- [ ] No horizontal scroll

### 9.5 Mobile Chrome (Android)
- [ ] Calendar grid renders correctly
- [ ] Date picker uses native input
- [ ] No viewport scaling issues

---

## 🔟 FINAL DELIVERABLES

### Test Execution Checklist
- [ ] Run automated test suite (Jest/Playwright)
- [ ] Execute manual browser tests
- [ ] Complete performance profiling
- [ ] Review error logs for unhandled exceptions
- [ ] Verify all CRITICAL tests pass (payment matching, email, auth)

### Bug Report Template
```markdown
**Bug ID**: CAL-001
**Severity**: High | Medium | Low
**Component**: Payment Matching
**Description**: Grace period calculation off by 1 day
**Steps to Reproduce**:
1. Navigate to December 2025
2. Create class on Dec 1 (Monday)
3. Add payment on Dec 3
**Expected**: Payment matches (within grace period)
**Actual**: Payment shows as unmatched
**Fix Required**: Update findNextClassDate() to include boundary day
**Status**: Open | In Progress | Fixed | Won't Fix
```

### Pass/Fail Report
```
Total Tests: 247
Passed: 245
Failed: 2
Skipped: 0
Pass Rate: 99.2%

CRITICAL FAILURES:
- CAL-087: Email shows $0.00 [FIXED]
- CAL-142: Grace period off by 1 day [IN PROGRESS]
```

### Code Quality Checklist
- [ ] No `console.log()` statements in production code
- [ ] All `DEBUG_MODE` flags set to `false`
- [ ] No commented-out code blocks
- [ ] All functions have JSDoc comments
- [ ] No unused variables or imports
- [ ] No hard-coded credentials
- [ ] All magic numbers extracted to constants

### Performance Benchmarks
```
Initial Load: 847ms (Target: < 1000ms) ✅
Month Navigation: 124ms (Target: < 300ms) ✅
Student Filter: 18ms (Target: < 50ms) ✅
Payment Matching: 312ms for 5000 records (Target: < 500ms) ✅
Memory Usage: 47MB (Target: < 100MB) ✅
```

### Final Sign-Off
```
✅ All functional tests passed
✅ All payment logic tests passed
✅ All UI/DOM tests passed
✅ Performance meets targets
✅ Stress tests completed successfully
✅ Error handling comprehensive
✅ Cross-browser compatibility verified
✅ Zero known critical bugs
✅ Code quality audit complete

Module Status: PRODUCTION READY
Approved By: [Developer Name]
Date: [YYYY-MM-DD]
```

---

## Continuous Testing Strategy

### Regression Test Suite
After any code change, run:
1. Payment matching tests (15 tests)
2. Email system tests (8 tests)
3. Calendar rendering tests (12 tests)
4. **Total**: 35 critical path tests (~5 minutes)

### Pre-Deployment Checklist
- [ ] Hard refresh test in all browsers
- [ ] Verify Supabase connection
- [ ] Check localStorage compatibility
- [ ] Test with production data sample
- [ ] Validate RLS policies active

---

**Document Version**: 1.0  
**Last Updated**: December 13, 2025  
**Next Review**: After any major feature change
