# 🔔 Comprehensive Notification Tracking - ALL Modules

## Overview
Implementation plan to add notification tracking to **EVERY action** across **ALL HTML modules** in the ARNOMA system. Every user action will create a detailed notification visible in the Notification Center.

---

## Modules Requiring Notifications

### ✅ COMPLETED
1. **Calendar.html** - Payment operations
   - ✅ Payment reassignment
   - ✅ Payment moves (previous/next)
   - ✅ Payment ignore

### 🔄 IN PROGRESS

#### 2. **Payment-Records.html** (HIGH PRIORITY)
**Actions to Track**:
- [ ] `toggleAbsence()` - Mark student absent/unabsent
- [ ] `saveManualPayment()` - Add manual payment
- [ ] `updatePaymentStatus()` - Change payment status (paid/unpaid/pending/cancelled)
- [ ] `deletePayment()` - Delete payment record (if exists)

**Notification Examples**:
- "Marked [Student Name] as ABSENT for [Date]"
- "Marked [Student Name] as PRESENT (unabsent) for [Date]"
- "Added manual payment of $XX for [Student Name] on [Date]"
- "Changed payment status from [Old Status] to [New Status] for [Student Name]"

---

#### 3. **Email-System.html** (CRITICAL - User Emphasized)
**Actions to Track**:
- [ ] `sendManualEmail()` - Manual email send
- [ ] `sendAutomatedEmail()` - Automated email send
- [ ] `sendBulkEmail()` - Bulk email send
- [ ] `createEmailTemplate()` - Create new template
- [ ] `updateEmailTemplate()` - Update existing template
- [ ] `deleteEmailTemplate()` - Delete template
- [ ] `createAutomation()` - Create automation rule
- [ ] `updateAutomation()` - Update automation rule
- [ ] `deleteAutomation()` - Delete automation rule
- [ ] `pauseAutomation()` - Pause/unpause automation

**CRITICAL**: Email notifications MUST include **complete email body** in payload
- Field: `payload.body_html` or `payload.email_body`
- User requirement: "whole email body in it"

**Notification Examples**:
- "Sent manual email to [Recipient]: [Subject]" (with full body in payload)
- "Sent automated email '[Template Name]' to [Recipient Count] recipients" (with body)
- "Created email template: [Template Name]"
- "Automation '[Name]' triggered and sent [Count] emails"

---

#### 4. **Student-Manager.html** (HIGH PRIORITY)
**Actions to Track**:
- [ ] `addCredit()` - Add credit to student account
- [ ] `useCredit()` - Apply credit to class payment
- [ ] `addStudent()` - Create new student
- [ ] `updateStudent()` - Update student information
- [ ] `deleteStudent()` - Delete student
- [ ] `updateStudentGroup()` - Change student group
- [ ] `updatePricePerClass()` - Update class pricing
- [ ] `toggleShowInGrid()` - Show/hide student in calendar grid

**Notification Examples**:
- "Added $XX credit to [Student Name]'s account (New balance: $YY)"
- "Used $XX credit for [Student Name] on [Date] (Remaining: $YY)"
- "Added new student: [Student Name] (Group [Letter], $XX per class)"
- "Updated [Student Name]: Changed group from [Old] to [New]"
- "Deleted student: [Student Name]"

---

#### 5. **Group-Manager.html** (MEDIUM PRIORITY)
**Actions to Track**:
- [ ] `saveGroup()` - Create/update group
- [ ] `deleteGroupFromDB()` - Delete group
- [ ] `updateGroupSchedule()` - Update group schedule
- [ ] `addSkippedClass()` - Add skipped/makeup class
- [ ] `removeSkippedClass()` - Remove skipped class
- [ ] `updateGroupStudents()` - Update students in group

**Notification Examples**:
- "Created new group: [Group Name] with [Student Count] students"
- "Updated group [Name]: Changed schedule from [Old] to [New]"
- "Deleted group: [Group Name]"
- "Added skipped class for [Group Name] on [Date] (Reason: [Reason])"
- "Added makeup class for [Group Name] on [Date]"

---

#### 6. **Group-Notes.html** (HIGH PRIORITY - User Mentioned)
**Actions to Track**:
- [ ] `grantAccess()` - Grant note access to group
- [ ] `grantIndividualAccess()` - Grant access to individual student
- [ ] `grantFreeAccess()` - Grant free access to note
- [ ] `freeSingleNote()` - Make single note free
- [ ] `toggleSystemOngoing()` - Toggle ongoing status for system
- [ ] `revokeAccess()` - Remove note access
- [ ] `batchGrantAccess()` - Grant access to multiple students

**CRITICAL**: Track whether access is FREE or PAID
- Include: `access_type: 'free' | 'paid'`
- Include: `requires_payment: true | false`

**Notification Examples**:
- "Opened '[Note Title]' for Group [Letter] (FREE access)"
- "Opened '[Note Title]' for Group [Letter] (PAID - $XX per student)"
- "Granted FREE access to '[Note Title]' for [Student Name]"
- "Granted individual access to '[Note Title]' for [Student Name]"
- "Made '[Note Title]' permanently FREE for all students"

---

#### 7. **Notes-Manager-NEW.html** (MEDIUM PRIORITY)
**Actions to Track**:
- [ ] `uploadNote()` - Upload new PDF note
- [ ] `deleteNote()` - Delete note
- [ ] `updateNoteSettings()` - Update note settings (title, payment requirement, etc.)
- [ ] `createNoteFolder()` - Create new folder
- [ ] `deleteNoteFolder()` - Delete folder
- [ ] `moveNoteToFolder()` - Move note to different folder

**Notification Examples**:
- "Uploaded new note: [Title] to [System/Folder]"
- "Deleted note: [Title]"
- "Updated note '[Title]': Changed from PAID to FREE"
- "Created new folder: [Folder Name] for Group [Letter]"

---

#### 8. **Student-Portal-Admin.html** (MEDIUM PRIORITY)
**Actions to Track**:
- [ ] `createAlert()` - Create student alert
- [ ] `deleteAlert()` - Delete alert
- [ ] `updateAlert()` - Update alert
- [ ] `sendBulkAlert()` - Send alert to multiple students
- [ ] `impersonateStudent()` - View as student (admin action)
- [ ] `exitImpersonation()` - Exit student view

**Notification Examples**:
- "Created alert for [Student Name]: [Alert Title]"
- "Sent bulk alert to [Count] students: [Title]"
- "Admin impersonated student: [Student Name]"

---

#### 9. **Video-Upload-Manager.html** (LOW PRIORITY)
**Actions to Track**:
- [ ] `uploadVideo()` - Upload new video
- [ ] `deleteVideo()` - Delete video
- [ ] `updateVideoSettings()` - Update video settings
- [ ] `grantVideoAccess()` - Grant video access to group/student

**Notification Examples**:
- "Uploaded new video: [Title]"
- "Granted video access to Group [Letter]: [Video Title]"

---

#### 10. **Test-Manager.html** (LOW PRIORITY)
**Actions to Track**:
- [ ] `createTest()` - Create new test
- [ ] `deleteTest()` - Delete test
- [ ] `addQuestion()` - Add question to test
- [ ] `deleteQuestion()` - Delete question
- [ ] `createQuestionBank()` - Create Q-Bank
- [ ] `toggleTestActive()` - Activate/deactivate test

**Notification Examples**:
- "Created new test: [Test Name]"
- "Added [Count] questions to test: [Test Name]"
- "Created Q-Bank: [Category Name] with [Count] questions"

---

## Implementation Priority Order

### Phase 1: CRITICAL (Start Immediately)
1. ✅ Calendar.html - COMPLETE
2. 🔄 Payment-Records.html - Absence tracking, manual payments
3. 🔄 Email-System.html - ALL emails with FULL body
4. 🔄 Group-Notes.html - Note access (free vs paid tracking)

### Phase 2: HIGH PRIORITY (Next)
5. Student-Manager.html - Credit operations, student CRUD
6. Notes-Manager-NEW.html - Note uploads/management

### Phase 3: MEDIUM PRIORITY
7. Group-Manager.html - Group operations
8. Student-Portal-Admin.html - Alerts, impersonation

### Phase 4: LOW PRIORITY
9. Video-Upload-Manager.html - Video management
10. Test-Manager.html - Test/question management

---

## Standard Implementation Pattern

### 1. Add createNotification Function
```javascript
// After Supabase client initialization
async function createNotification(type, title, message, category, payload = {}) {
  try {
    const { error } = await supabase.from('notifications').insert({
      type: type,
      title: title,
      message: message,
      category: category,
      payload: payload,
      read: false,
      is_read: false,
      timestamp: new Date().toISOString(),
      created_at: new Date().toISOString()
    });
    
    if (error) {
      console.error('❌ Error creating notification:', error);
      return null;
    }
    
    return true;
  } catch (err) {
    console.error('❌ Exception creating notification:', err);
    return null;
  }
}

// Make globally available
window.createNotification = createNotification;
```

### 2. Insert Notification Calls
**Pattern**: After successful DB operation, before user feedback

```javascript
// After successful database operation
if (error) {
  console.error('❌ Error:', error);
  await customAlert('Error', error.message);
  return;
}

// ✅ CREATE NOTIFICATION
await createNotification(
  'action_type',
  'Notification Title',
  'Detailed message with ${variables}',
  'category',
  {
    relevant_data: value,
    more_data: moreValue,
    action: 'action_name'
  }
);

// User feedback
await customAlert('Success', '✅ Action completed!');
```

---

## Notification Categories

### Defined Categories
- `payment` - Payment operations (reassign, move, ignore, status change)
- `email` - Email operations (manual, automated, bulk)
- `absence` - Absence tracking (mark/unmark)
- `student` - Student management (add, update, delete, credit)
- `group` - Group operations (create, update, delete, schedule)
- `note` - Note management (upload, delete, access grants)
- `video` - Video management
- `test` - Test/question management
- `alert` - Student alerts
- `admin` - Admin actions (impersonation, settings)

---

## Special Requirements by Module

### Email-System.html
**MUST include complete email body**:
```javascript
await createNotification(
  'manual_email_sent',
  'Manual Email Sent',
  `Sent email to ${recipient}: ${subject}`,
  'email',
  {
    recipient: recipient,
    subject: subject,
    body_html: fullEmailBody,  // ⚠️ COMPLETE email body
    template_id: templateId,
    sent_at: new Date().toISOString()
  }
);
```

### Group-Notes.html
**MUST distinguish FREE vs PAID access**:
```javascript
await createNotification(
  'note_access_granted',
  'Note Access Granted',
  `Opened '${noteTitle}' for Group ${groupLetter} (${accessType})`,
  'note',
  {
    note_id: noteId,
    note_title: noteTitle,
    group_letter: groupLetter,
    access_type: isFree ? 'FREE' : 'PAID',  // ⚠️ REQUIRED
    requires_payment: requiresPayment,
    granted_at: new Date().toISOString()
  }
);
```

### Student-Manager.html
**MUST include balance changes for credit operations**:
```javascript
await createNotification(
  'credit_added',
  'Credit Added',
  `Added $${amount} credit to ${studentName}'s account`,
  'student',
  {
    student_name: studentName,
    student_id: studentId,
    amount: amount,
    previous_balance: oldBalance,  // ⚠️ Track balance change
    new_balance: newBalance,       // ⚠️ Track balance change
    reason: reason,
    action: 'credit_add'
  }
);
```

---

## Testing Checklist (Per Module)

### For Each Action:
- [ ] Perform action in UI
- [ ] Verify notification appears in Notification Center
- [ ] Verify notification title is clear and descriptive
- [ ] Verify notification message includes relevant details
- [ ] Verify payload contains ALL required data
- [ ] Verify special requirements met (email body, free/paid, balance changes)
- [ ] Verify notification groups correctly by date
- [ ] Verify real-time update works (notification appears immediately)
- [ ] Verify mark as read works
- [ ] Verify badge counter updates

---

## File Modification Checklist

### For Each HTML File:
1. [ ] Add `createNotification()` function after Supabase client init
2. [ ] Identify all action functions (search for `async function`)
3. [ ] Add notification call to each action (after success, before alert)
4. [ ] Test each notification type
5. [ ] Update this document with ✅ when complete

---

## Progress Tracking

### Files Status:
- ✅ Calendar.html - COMPLETE (4 notification types)
- ⏳ Payment-Records.html - Function exists, needs calls added
- ⏳ Email-System.html - Not started
- ⏳ Student-Manager.html - Not started
- ⏳ Group-Manager.html - Not started
- ⏳ Group-Notes.html - Not started
- ⏳ Notes-Manager-NEW.html - Not started
- ⏳ Student-Portal-Admin.html - Not started
- ⏳ Video-Upload-Manager.html - Not started
- ⏳ Test-Manager.html - Not started

---

**Last Updated**: December 18, 2025
**Status**: Phase 1 in progress
**Next**: Group-Notes.html (note access tracking with free/paid distinction)
