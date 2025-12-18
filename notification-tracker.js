/**
 * NOTIFICATION TRACKER - Global Notification System
 * This file contains the createNotification function that should be included in ALL HTML files
 * and called for EVERY user action
 */

// Create notification helper function
async function createNotification(type, title, message, category, payload = {}) {
  try {
    console.log('🔔 Creating notification:', { type, title, category });

    // Ensure supabaseClient exists (should be defined in parent file)
    if (typeof supabaseClient === 'undefined') {
      console.error('❌ supabaseClient not defined - cannot create notification');
      return null;
    }

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

    // Trigger badge update if function exists
    if (typeof updateNotificationBadge === 'function') {
      updateNotificationBadge();
    }

    return data[0];

  } catch (err) {
    console.error('❌ Exception creating notification:', err);
    return null;
  }
}

// Make globally available
if (typeof window !== 'undefined') {
  window.createNotification = createNotification;
}

/**
 * ============================================================
 * NOTIFICATION CALLS TO ADD TO EACH MODULE
 * ============================================================
 */

/**
 * CALENDAR.HTML - Payment Management Notifications
 */
const CALENDAR_NOTIFICATIONS = {
  
  // Payment Reassignment
  paymentReassigned: async (studentName, amount, fromDate, toDate, reason = '') => {
    await createNotification(
      'payment_reassignment',
      'Payment Reassigned',
      `Reassigned $${amount} payment for ${studentName} from ${fromDate} to ${toDate}${reason ? ` (${reason})` : ''}`,
      'payment',
      {
        student_name: studentName,
        amount: amount,
        from_date: fromDate,
        to_date: toDate,
        reason: reason,
        action: 'reassign'
      }
    );
  },

  // Payment Moved (Previous/Next)
  paymentMoved: async (studentName, amount, fromDate, toDate, direction) => {
    await createNotification(
      'payment_move',
      `Payment Moved ${direction}`,
      `Moved $${amount} payment for ${studentName} from ${fromDate} to ${toDate}`,
      'payment',
      {
        student_name: studentName,
        amount: amount,
        from_date: fromDate,
        to_date: toDate,
        direction: direction,
        action: 'move'
      }
    );
  },

  // Payment Ignored
  paymentIgnored: async (studentName, amount, date, reason = '') => {
    await createNotification(
      'payment_ignored',
      'Payment Ignored',
      `Ignored $${amount} payment for ${studentName} on ${date}${reason ? ` (${reason})` : ''}`,
      'payment',
      {
        student_name: studentName,
        amount: amount,
        date: date,
        reason: reason,
        action: 'ignore'
      }
    );
  }
};

/**
 * PAYMENT-RECORDS.HTML - Student Absence & Payment Notifications
 */
const PAYMENT_RECORDS_NOTIFICATIONS = {
  
  // Student Marked Absent
  studentAbsent: async (studentName, classDate, groupName = '') => {
    await createNotification(
      'student_absent',
      'Student Marked Absent',
      `${studentName} marked absent for ${classDate}${groupName ? ` (${groupName})` : ''}`,
      'absence',
      {
        student_name: studentName,
        class_date: classDate,
        group_name: groupName,
        action: 'mark_absent'
      }
    );
  },

  // Student Unmarked Absent
  studentUnabsent: async (studentName, classDate, groupName = '') => {
    await createNotification(
      'student_unabsent',
      'Absence Removed',
      `${studentName} unmarked absent for ${classDate}${groupName ? ` (${groupName})` : ''}`,
      'absence',
      {
        student_name: studentName,
        class_date: classDate,
        group_name: groupName,
        action: 'unmark_absent'
      }
    );
  },

  // Manual Payment Added
  manualPaymentAdded: async (studentName, amount, date, status) => {
    await createNotification(
      'manual_payment_added',
      'Manual Payment Added',
      `Added $${amount} ${status} payment for ${studentName} on ${date}`,
      'payment',
      {
        student_name: studentName,
        amount: amount,
        date: date,
        status: status,
        action: 'manual_payment'
      }
    );
  },

  // Payment Status Changed
  paymentStatusChanged: async (studentName, amount, date, oldStatus, newStatus) => {
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
  }
};

/**
 * STUDENT-MANAGER.HTML - Credit & Student Management Notifications
 */
const STUDENT_MANAGER_NOTIFICATIONS = {
  
  // Credit Added
  creditAdded: async (studentName, amount, reason = '') => {
    await createNotification(
      'credit_added',
      'Credit Added',
      `Added $${amount} credit to ${studentName}${reason ? ` - ${reason}` : ''}`,
      'payment',
      {
        student_name: studentName,
        amount: amount,
        reason: reason,
        action: 'add_credit'
      }
    );
  },

  // Credit Used
  creditUsed: async (studentName, amount, classDate) => {
    await createNotification(
      'credit_used',
      'Credit Applied',
      `Applied $${amount} credit for ${studentName} on ${classDate}`,
      'payment',
      {
        student_name: studentName,
        amount: amount,
        class_date: classDate,
        action: 'use_credit'
      }
    );
  },

  // Student Added
  studentAdded: async (studentName, groupLetter, pricePerClass) => {
    await createNotification(
      'student_added',
      'New Student Added',
      `Added ${studentName} to Group ${groupLetter} ($${pricePerClass}/class)`,
      'student',
      {
        student_name: studentName,
        group_letter: groupLetter,
        price_per_class: pricePerClass,
        action: 'add_student'
      }
    );
  },

  // Student Updated
  studentUpdated: async (studentName, changes) => {
    const changeText = Object.entries(changes)
      .map(([key, value]) => `${key}: ${value}`)
      .join(', ');
    
    await createNotification(
      'student_updated',
      'Student Updated',
      `Updated ${studentName} - ${changeText}`,
      'student',
      {
        student_name: studentName,
        changes: changes,
        action: 'update_student'
      }
    );
  },

  // Student Deleted
  studentDeleted: async (studentName) => {
    await createNotification(
      'student_deleted',
      'Student Removed',
      `Removed student: ${studentName}`,
      'student',
      {
        student_name: studentName,
        action: 'delete_student'
      }
    );
  }
};

/**
 * EMAIL-SYSTEM.HTML - Email Notifications
 */
const EMAIL_NOTIFICATIONS = {
  
  // Manual Email Sent
  manualEmailSent: async (recipientEmail, recipientName, subject, bodyHtml, templateName = '') => {
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
        template_name: templateName,
        email_type: 'manual'
      }
    );
  },

  // Automated Email Sent
  automatedEmailSent: async (recipientEmail, recipientName, subject, bodyHtml, automationId, triggerType) => {
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
        email_type: 'automated'
      }
    );
  },

  // Bulk Email Sent
  bulkEmailSent: async (recipientCount, subject, templateName) => {
    await createNotification(
      'bulk_email',
      'Bulk Email Sent',
      `Sent "${subject}" to ${recipientCount} recipients`,
      'email',
      {
        recipient_count: recipientCount,
        subject: subject,
        template_name: templateName,
        email_type: 'bulk'
      }
    );
  }
};

// Export for use in modules
if (typeof module !== 'undefined' && module.exports) {
  module.exports = {
    createNotification,
    CALENDAR_NOTIFICATIONS,
    PAYMENT_RECORDS_NOTIFICATIONS,
    STUDENT_MANAGER_NOTIFICATIONS,
    EMAIL_NOTIFICATIONS
  };
}
