# Email Notification System - Implementation Guide

## Overview
All emails sent from the ARNOMA system are now logged to both:
1. **`sent_emails` table** - For Email System's "📨 Sent Emails" modal viewer
2. **`notifications` table** - For Payment Records' 🔔 Notification Center bell

## Implemented Modules

### ✅ 1. Calendar.html
**Payment Reminder Emails** (`sendPaymentReminderEmail()`)
- Email Type: `payment_reminder`
- Template: "Payment Reminder"
- Metadata includes: student_id, student_name, email, amount, email_type, subject, html

**Absence Notice Emails** (`sendAbsenceEmail()`)
- Email Type: `absence_notice`
- Template: "Absence Notice"
- Metadata includes: student_id, student_name, email, absence_date, email_type, subject, html

### ✅ 2. Login.html
**Registration Confirmation Emails** (`sendRegistrationEmail()`)
- Email Type: `registration`
- Template: "Registration Confirmation"
- Metadata includes: student_name, email, phone, email_type, subject, html

### ✅ 3. Email-System.html
**All Template-Based Emails** (`addSentEmail()`)
- Email Type: `manual` or custom
- Template: Custom or template name
- Metadata includes: email, email_type, subject, html, template_name
- **FIXED:** Column names updated from `recipient`/`body_html` to `recipient_email`/`html_content`

## Database Schema

### sent_emails Table
```sql
- id (uuid, primary key)
- recipient_email (text, required)
- recipient_name (text, optional)
- subject (text, required)
- html_content (text, required)
- template_id (uuid, optional)
- template_name (text, required)
- sent_at (timestamptz, required)
- email_type (text, required)
- resend_id (text, optional)
- delivery_status (text, optional)
- delivery_data (jsonb, optional)
- status (text, required)
- response_data (jsonb, optional)
```

### notifications Table
```sql
- id (bigint, primary key)
- type (varchar, required) - e.g., 'email_sent'
- category (varchar, required) - e.g., 'email' (ADDED for UI rendering)
- title (text, required)
- description (text, required)
- student_name (varchar, optional)
- group_name (varchar, optional)
- metadata (jsonb, optional) - Includes: subject, html, email, student_id, etc.
- timestamp (timestamptz, required)
- read (boolean, default false)
- created_at (timestamptz, required)
```

## How to Add Email Notification to New Email Functions

### Standard Pattern (Copy & Paste Template)

```javascript
async function yourEmailFunction(params) {
  try {
    // ... generate email HTML ...
    const emailHTML = generateYourEmailHTML(params);
    
    // Send email via Supabase Edge Function
    const response = await fetch(`${SUPABASE_URL}/functions/v1/send-email`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${SUPABASE_ANON_KEY}`,
      },
      body: JSON.stringify({
        to: recipientEmail,
        subject: 'Your Subject Here',
        html: emailHTML,
      }),
    });
    
    if (!response.ok) {
      throw new Error('Email send failed');
    }
    
    const result = await response.json();
    
    // ============================================================
    // DUAL NOTIFICATION LOGGING (COPY THIS ENTIRE BLOCK)
    // ============================================================
    try {
      const resendEmailId = result?.id || result?.data?.id || null;
      
      // 1. Log to sent_emails table (for Email System)
      const sentEmailRecord = {
        recipient_email: recipientEmail,
        recipient_name: recipientName,
        subject: 'Your Subject Here',
        html_content: emailHTML,
        template_name: 'Your Template Name',
        email_type: 'your_email_type',  // e.g., 'payment_reminder', 'absence_notice', 'registration'
        resend_id: resendEmailId,
        delivery_status: 'delivered',
        status: 'sent',
        sent_at: new Date().toISOString()
      };
      
      const { data: logData, error: logError } = await supabase
        .from('sent_emails')
        .insert([sentEmailRecord])
        .select();
      
      if (logError) {
        console.error('⚠️ Failed to log to sent_emails:', logError);
      } else {
        console.log('✅ Email logged to sent_emails:', logData[0]);
      }
      
      // 2. Log to notifications table (for Notification Center bell)
      const notificationRecord = {
        type: 'email_sent',
        category: 'email',  // REQUIRED for UI rendering
        title: 'Your Notification Title',
        description: `Short description of what was sent`,
        student_name: recipientName || null,
        metadata: {
          student_id: studentId,  // if applicable
          student_name: recipientName,
          email: recipientEmail,
          email_type: 'your_email_type',
          subject: 'Your Subject Here',
          html: emailHTML  // CRITICAL: Full email HTML for preview
        },
        timestamp: new Date().toISOString(),
        read: false,
        created_at: new Date().toISOString()
      };
      
      const { data: notifData, error: notifError } = await supabase
        .from('notifications')
        .insert([notificationRecord])
        .select();
      
      if (notifError) {
        console.error('⚠️ Failed to log to notifications:', notifError);
      } else {
        console.log('✅ Notification logged:', notifData[0]);
      }
      
    } catch (logErr) {
      console.error('⚠️ Error logging notifications (email still sent):', logErr);
    }
    // ============================================================
    // END DUAL NOTIFICATION LOGGING
    // ============================================================
    
    return result;
  } catch (err) {
    console.error('❌ Error sending email:', err);
    throw err;
  }
}
```

## Critical Fields

### For Email Preview to Work
**Must include in metadata:**
- `subject` - Email subject line
- `html` - **Full email HTML content** (not just a summary)
- `email` - Recipient email address

### For Notification Rendering
**Must include:**
- `category: 'email'` - Required for icon rendering
- `type: 'email_sent'` - Standard type for sent emails
- `description` - Shows in notification list
- `title` - Shows in notification header

## Testing Checklist

After adding notification logging to a new email function:

1. **Send a test email** from your function
2. **Check console logs** for:
   ```
   ✅ Email logged to sent_emails: {...}
   ✅ Notification logged: {...}
   ```
3. **Open Payment-Records.html** → Click 🔔 bell icon
4. **Verify notification appears** with correct title/description
5. **Click the notification** → Email preview modal should open
6. **Verify full email HTML displays** in preview
7. **Open Email-System.html** → Click "📨 Sent Emails" button
8. **Verify email appears** in sent emails list

## Future Email Functions

**ANY new email function you create MUST:**
1. Copy the dual logging block above
2. Customize the metadata fields
3. Include `html: emailHTML` in metadata
4. Set appropriate `email_type` value
5. Test with checklist above

## Common Email Types

- `payment_reminder` - Unpaid class reminders
- `absence_notice` - Absence notifications
- `registration` - New student welcome emails
- `manual` - Custom emails from Email System
- `test` - Test emails
- `class_reminder` - Upcoming class reminders (future)
- `schedule_change` - Schedule change notifications (future)

## Troubleshooting

**"No email content available" in preview:**
- Check that `metadata.html` contains full email HTML
- Verify column name is `html` not `body_html` or `body`

**Notification not appearing in bell:**
- Verify `category: 'email'` is set
- Check `notifications` table has the record
- Hard refresh Payment-Records.html

**Email not in Email System modal:**
- Verify column names: `recipient_email`, `html_content` (not old names)
- Check `sent_emails` table has the record
- Hard refresh Email-System.html

## Auto-Refresh Configuration

**Payment-Records.html:**
- Visible: Refreshes every 15 seconds
- Hidden: Refreshes every 30 minutes
- Notifications reload when bell icon clicked

---

**Last Updated:** December 2, 2025
**Implementation Status:** ✅ COMPLETE - All existing email functions now log notifications
