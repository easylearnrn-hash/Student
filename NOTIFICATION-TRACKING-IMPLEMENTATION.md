# Complete Notification Tracking Implementation Guide

## Overview
This guide shows exactly where to add `createNotification()` calls for EVERY user action across all modules.

---

## 1. CALENDAR.HTML - Payment Reassignments

### Location 1: reassignPaymentFromModal() - After successful reassignment
**File**: `Calendar.html`  
**Line**: ~11710 (after the successful update)

```javascript
// EXISTING CODE (around line 11700-11710):
const { error } = await supabaseClient
  .from('payments')
  .update({ for_class: newDate })
  .eq('id', paymentId);

if (error) {
  console.error('❌ Error reassigning payment:', error);
  await customAlert('Error', `Failed to reassign payment: ${error.message}`);
  return;
}

// ✅ ADD THIS NOTIFICATION:
await createNotification(
  'payment_reassignment',
  'Payment Reassigned',
  `Reassigned $${amount} payment for ${studentName} from ${currentForClass} to ${newDate}`,
  'payment',
  {
    student_name: studentName,
    amount: amount,
    from_date: currentForClass,
    to_date: newDate,
    payment_id: paymentId,
    action: 'reassign'
  }
);

await customAlert('Success', `✅ Payment reassigned from ${currentForClass} to ${newDate}`);
```

---

### Location 2: movePaymentToPrevious() - After moving payment
**File**: `Calendar.html`  
**Line**: ~12900 (after successful move)

```javascript
// Find the successful update section and add:
await createNotification(
  'payment_move',
  'Payment Moved to Previous Class',
  `Moved $${payment.amount} payment for ${student.name} from ${currentDateStr} to ${targetDate}`,
  'payment',
  {
    student_name: student.name,
    amount: payment.amount,
    from_date: currentDateStr,
    to_date: targetDate,
    direction: 'previous',
    action: 'move'
  }
);
```

---

### Location 3: movePaymentToNext() - After moving payment
**File**: `Calendar.html`  
**Line**: ~12970 (after successful move)

```javascript
// Add after successful update:
await createNotification(
  'payment_move',
  'Payment Moved to Next Class',
  `Moved $${payment.amount} payment for ${student.name} from ${currentDateStr} to ${targetDate}`,
  'payment',
  {
    student_name: student.name,
    amount: payment.amount,
    from_date: currentDateStr,
    to_date: targetDate,
    direction: 'next',
    action: 'move'
  }
);
```

---

### Location 4: ignorePayment() - After ignoring payment
**File**: `Calendar.html`  
**Line**: ~11770 (after successful ignore)

```javascript
// Add after successful insert:
await createNotification(
  'payment_ignored',
  'Payment Ignored',
  `Ignored payment for student ID ${studentId}`,
  'payment',
  {
    payment_id: paymentId,
    student_id: studentId,
    ignored_by: userEmail,
    action: 'ignore'
  }
);
```

---

## 2. PAYMENT-RECORDS.HTML - Absences & Manual Payments

### Location 1: toggleAbsence() - Mark/Unmark Absent
**File**: `Payment-Records.html`  
**Function**: `toggleAbsence(studentId, classDate)`  
**Search for**: `toggleAbsence` function

```javascript
// After marking ABSENT (insert):
await createNotification(
  'student_absent',
  'Student Marked Absent',
  `${student.name} marked absent for ${classDate}`,
  'absence',
  {
    student_name: student.name,
    student_id: studentId,
    class_date: classDate,
    action: 'mark_absent'
  }
);

// After UNMARKING absent (delete):
await createNotification(
  'student_unabsent',
  'Absence Removed',
  `${student.name} unmarked absent for ${classDate}`,
  'absence',
  {
    student_name: student.name,
    student_id: studentId,
    class_date: classDate,
    action: 'unmark_absent'
  }
);
```

---

### Location 2: saveManualPayment() - Add Manual Payment
**File**: `Payment-Records.html`  
**Function**: `saveManualPayment()`  
**Search for**: `saveManualPayment` or manual payment save

```javascript
// After successful payment insert:
await createNotification(
  'manual_payment_added',
  'Manual Payment Added',
  `Added $${amount} ${status} payment for ${studentName} on ${date}`,
  'payment',
  {
    student_name: studentName,
    student_id: studentId,
    amount: amount,
    date: date,
    status: status,
    action: 'manual_payment'
  }
);
```

---

### Location 3: updatePaymentStatus() - Change Payment Status
**File**: `Payment-Records.html`  
**Function**: Payment status change (if exists)

```javascript
// After status update:
await createNotification(
  'payment_status_changed',
  'Payment Status Updated',
  `${studentName}'s $${amount} payment on ${date} changed from ${oldStatus} to ${newStatus}`,
  'payment',
  {
    student_name: studentName,
    amount: amount,
    date: date,
    old_status: oldStatus,
    new_status: newStatus,
    action: 'status_change'
  }
);
```

---

## 3. STUDENT-MANAGER.HTML - Credits & Student Management

### Location 1: Add Credit
**File**: `Student-Manager.html`  
**Function**: Credit add function  
**Search for**: `add.*credit|addCredit|credit.*balance`

```javascript
// After successful credit addition:
await createNotification(
  'credit_added',
  'Credit Added',
  `Added $${amount} credit to ${studentName} - ${reason}`,
  'payment',
  {
    student_name: studentName,
    student_id: studentId,
    amount: amount,
    reason: reason,
    new_balance: newBalance,
    action: 'add_credit'
  }
);
```

---

### Location 2: Use Credit
**File**: `Student-Manager.html`  
**Function**: Credit usage/application  
**Search for**: `use.*credit|applyCredit|credit.*payment`

```javascript
// After applying credit to a class:
await createNotification(
  'credit_used',
  'Credit Applied',
  `Applied $${amount} credit for ${studentName} on ${classDate}`,
  'payment',
  {
    student_name: studentName,
    student_id: studentId,
    amount: amount,
    class_date: classDate,
    remaining_balance: remainingBalance,
    action: 'use_credit'
  }
);
```

---

### Location 3: Add Student
**File**: `Student-Manager.html`  
**Function**: `addStudent()` or `saveStudent()`  
**Search for**: `addStudent|saveStudent`

```javascript
// After successful student creation:
await createNotification(
  'student_added',
  'New Student Added',
  `Added ${studentName} to Group ${groupLetter} ($${pricePerClass}/class)`,
  'student',
  {
    student_name: studentName,
    student_id: newStudentId,
    group_letter: groupLetter,
    price_per_class: pricePerClass,
    action: 'add_student'
  }
);
```

---

### Location 4: Update Student
**File**: `Student-Manager.html`  
**Function**: `updateStudent()` or student edit save

```javascript
// After successful student update:
const changes = {
  group_letter: newGroup,
  price_per_class: newPrice,
  // ... other changed fields
};

await createNotification(
  'student_updated',
  'Student Updated',
  `Updated ${studentName}: ${Object.keys(changes).join(', ')}`,
  'student',
  {
    student_name: studentName,
    student_id: studentId,
    changes: changes,
    action: 'update_student'
  }
);
```

---

### Location 5: Delete Student
**File**: `Student-Manager.html`  
**Function**: `deleteStudent()` or student removal

```javascript
// After successful deletion:
await createNotification(
  'student_deleted',
  'Student Removed',
  `Removed student: ${studentName}`,
  'student',
  {
    student_name: studentName,
    student_id: studentId,
    action: 'delete_student'
  }
);
```

---

## 4. EMAIL-SYSTEM.HTML - All Email Sending

### Location 1: Manual Email Send
**File**: `Email-System.html`  
**Function**: `sendEmail()` or manual send function  
**Search for**: `sendEmail|send.*manual`

```javascript
// After successful email send:
await createNotification(
  'manual_email',
  'Email Sent',
  `Sent "${subject}" to ${recipientName || recipientEmail}`,
  'email',
  {
    recipient: recipientEmail,
    recipient_name: recipientName,
    subject: subject,
    body_html: bodyHtml,
    template_name: templateName || 'manual',
    email_type: 'manual',
    sent_at: new Date().toISOString()
  }
);
```

---

### Location 2: Automated Email Send
**File**: `Email-System.html`  
**Function**: Automation trigger function  
**Search for**: `automation|trigger.*email|automated.*send`

```javascript
// After each automated email send:
await createNotification(
  'automated_email',
  'Automated Email Sent',
  `Sent "${subject}" to ${recipientName || recipientEmail} (Automation #${automationId})`,
  'email',
  {
    recipient: recipientEmail,
    recipient_name: recipientName,
    subject: subject,
    body_html: bodyHtml,
    automation_id: automationId,
    trigger_type: triggerType,
    email_type: 'automated',
    sent_at: new Date().toISOString()
  }
);
```

---

### Location 3: Bulk Email Send
**File**: `Email-System.html`  
**Function**: Bulk send function

```javascript
// After bulk send completes:
await createNotification(
  'bulk_email',
  'Bulk Email Sent',
  `Sent "${subject}" to ${successCount}/${totalCount} recipients`,
  'email',
  {
    recipient_count: successCount,
    total_count: totalCount,
    subject: subject,
    template_name: templateName,
    email_type: 'bulk',
    sent_at: new Date().toISOString()
  }
);
```

---

## 5. Add createNotification Function to ALL Files

Each file needs the `createNotification` function. Add this AFTER the Supabase client initialization:

```javascript
// Add after: const supabaseClient = window.supabase.createClient(...)

// ============================================================
// NOTIFICATION SYSTEM
// ============================================================
async function createNotification(type, title, message, category, payload = {}) {
  try {
    console.log('🔔 Creating notification:', { type, title, category });

    const { data, error } = await supabaseClient
      .from('notifications')
      .insert([
        {
          type: type,
          title: title,
          message: message,
          category: category,
          payload: payload,
          read: false,
          is_read: false,
          timestamp: new Date().toISOString(),
          created_at: new Date().toISOString()
        }
      ])
      .select();

    if (error) {
      console.error('❌ Error creating notification:', error);
      return null;
    }

    console.log('✅ Notification created:', data[0]);
    return data[0];

  } catch (err) {
    console.error('❌ Exception creating notification:', err);
    return null;
  }
}

// Make globally available
window.createNotification = createNotification;
```

---

## Files That Need This Function:
1. ✅ `Payment-Records.html` - Already has it
2. ⏳ `Calendar.html` - **NEEDS IT**
3. ⏳ `Student-Manager.html` - **NEEDS IT**  
4. ⏳ `Email-System.html` - **NEEDS IT**
5. ⏳ `Group-Manager.html` - **NEEDS IT**
6. ⏳ `Notes-Manager-NEW.html` - **NEEDS IT** (for note uploads/assignments)

---

## Quick Search Patterns

Use these search patterns to find where to add notifications:

### Calendar.html:
- `reassignPaymentFromModal`
- `movePaymentToPrevious`
- `movePaymentToNext`
- `ignorePayment`

### Payment-Records.html:
- `toggleAbsence`
- `saveManualPayment`
- `updatePaymentStatus`

### Student-Manager.html:
- `addStudent`
- `updateStudent`
- `deleteStudent`
- `addCredit`
- `useCredit`
- `applyCredit`

### Email-System.html:
- `sendEmail`
- `sendAutomatedEmail`
- `sendBulkEmail`
- `triggerAutomation`

---

## Testing Checklist

After implementation, test EVERY action:

- [ ] Reassign payment in Calendar
- [ ] Move payment to previous class
- [ ] Move payment to next class
- [ ] Ignore a payment
- [ ] Mark student absent
- [ ] Unmark student absent
- [ ] Add manual payment
- [ ] Change payment status
- [ ] Add credit to student
- [ ] Use credit for a class
- [ ] Add new student
- [ ] Update student info
- [ ] Delete student
- [ ] Send manual email
- [ ] Send automated email
- [ ] Send bulk email

Each action should create a visible notification in the Notification Center! 🔔

---

## Priority Order for Implementation:

1. **HIGH PRIORITY** (Most common actions):
   - Payment-Records: Mark/unmark absent
   - Payment-Records: Add manual payment
   - Email-System: All email sends
   - Student-Manager: Add credit, use credit

2. **MEDIUM PRIORITY**:
   - Calendar: Payment reassignments
   - Student-Manager: Add/update/delete student

3. **LOW PRIORITY** (Less frequent):
   - Calendar: Ignore payment
   - Notes uploads/assignments

---

## Next Steps:

1. Add `createNotification` function to all files (see list above)
2. Implement notifications for HIGH PRIORITY actions first
3. Test each action creates a notification
4. Move to MEDIUM and LOW priority actions
5. Update this checklist as you complete each item

---

**Remember**: EVERY user action should create a notification with:
- Clear title
- Descriptive message
- Correct category (payment, email, absence, student)
- Complete payload with all relevant data
