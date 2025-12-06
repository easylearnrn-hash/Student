# Student Alert System - Implementation Guide

## Overview
The Student Alert System allows admins to create personalized alerts that students see when they log into the student portal. Admins can select specific students, customize messages with variables, and set alert types and expiration dates.

## Setup Instructions

### 1. Database Setup
Run the SQL script to create the necessary table:
```bash
# In Supabase SQL Editor, run:
create-student-alerts-table.sql
```

This creates:
- `student_alerts` table with proper structure
- RLS policies for admin and student access
- Indexes for performance
- Auto-cleanup functions for expired alerts

### 2. Admin Usage (Student-Portal-Admin.html)

**Accessing the Alert System:**
1. Click "💬 Student Chat" button in the header
2. In the chat modal, click the "🔔 Alert" button (next to the X)
3. This opens the Alert Creation modal

**Creating an Alert:**
1. **Write Message**: Enter your alert message in the textarea
2. **Use Variables** (optional):
   - `{student_name}` → Replaced with student's name
   - `{group}` → Replaced with student's group (A-F)
   - `{balance}` → Replaced with student's balance
   - `{email}` → Replaced with student's email
   
   Example: "Hi {student_name}, your balance is ${balance}"

3. **Select Students**: 
   - Check individual students
   - Or use "Select All / Deselect All" button
   
4. **Choose Alert Type**:
   - ℹ️ **Info** (blue) - General information
   - ⚠️ **Warning** (yellow) - Important notices
   - 🚨 **Urgent** (red) - Critical alerts
   - ✅ **Success** (green) - Positive messages

5. **Set Expiration** (optional):
   - Leave empty for persistent alerts
   - Or set date/time when alert should auto-expire

6. Click "Create Alert"

### 3. Student View Integration

**To display alerts on student portal**, add this code to `student-portal.html`:

```javascript
// Add near the top of the script section
async function loadStudentAlerts() {
  try {
    const { data: { user } } = await supabase.auth.getUser();
    if (!user) return;
    
    // Get student record
    const { data: student } = await supabase
      .from('students')
      .select('id')
      .eq('email', user.email)
      .single();
    
    if (!student) return;
    
    // Fetch unread, non-expired alerts
    const { data: alerts, error } = await supabase
      .from('student_alerts')
      .select('*')
      .eq('student_id', student.id)
      .eq('is_read', false)
      .or('expires_at.is.null,expires_at.gt.' + new Date().toISOString())
      .order('created_at', { ascending: false });
    
    if (error) throw error;
    
    // Display alerts
    if (alerts && alerts.length > 0) {
      displayAlerts(alerts);
    }
    
  } catch (error) {
    console.error('Error loading alerts:', error);
  }
}

function displayAlerts(alerts) {
  const alertContainer = document.getElementById('alertContainer'); // Create this element
  
  alerts.forEach(alert => {
    const alertEl = document.createElement('div');
    alertEl.className = `alert alert-${alert.alert_type}`;
    alertEl.innerHTML = `
      <div class="alert-icon">${getAlertIcon(alert.alert_type)}</div>
      <div class="alert-content">
        <p>${alert.message}</p>
        ${alert.expires_at ? `<small>Expires: ${new Date(alert.expires_at).toLocaleDateString()}</small>` : ''}
      </div>
      <button class="alert-dismiss" onclick="dismissAlert('${alert.id}')">×</button>
    `;
    alertContainer.appendChild(alertEl);
  });
}

function getAlertIcon(type) {
  const icons = {
    info: 'ℹ️',
    warning: '⚠️',
    urgent: '🚨',
    success: '✅'
  };
  return icons[type] || 'ℹ️';
}

async function dismissAlert(alertId) {
  try {
    await supabase
      .from('student_alerts')
      .update({ is_read: true })
      .eq('id', alertId);
    
    // Remove from UI
    document.querySelector(`[data-alert-id="${alertId}"]`).remove();
    
  } catch (error) {
    console.error('Error dismissing alert:', error);
  }
}

// Call on page load
document.addEventListener('DOMContentLoaded', () => {
  loadStudentAlerts();
});
```

**Add CSS for alerts in student-portal.html:**

```css
#alertContainer {
  position: fixed;
  top: 20px;
  right: 20px;
  z-index: 9999;
  max-width: 400px;
}

.alert {
  background: rgba(255,255,255,0.95);
  backdrop-filter: blur(10px);
  border-radius: 16px;
  padding: 16px 20px;
  margin-bottom: 12px;
  display: flex;
  align-items: flex-start;
  gap: 12px;
  box-shadow: 0 8px 32px rgba(0,0,0,0.2);
  animation: slideInRight 0.3s ease-out;
}

@keyframes slideInRight {
  from {
    transform: translateX(400px);
    opacity: 0;
  }
  to {
    transform: translateX(0);
    opacity: 1;
  }
}

.alert-info {
  border-left: 4px solid #3b82f6;
}

.alert-warning {
  border-left: 4px solid #f59e0b;
}

.alert-urgent {
  border-left: 4px solid #ef4444;
  animation: pulseAlert 2s infinite;
}

.alert-success {
  border-left: 4px solid #10b981;
}

@keyframes pulseAlert {
  0%, 100% { box-shadow: 0 8px 32px rgba(0,0,0,0.2); }
  50% { box-shadow: 0 8px 32px rgba(239,68,68,0.5); }
}

.alert-icon {
  font-size: 24px;
  line-height: 1;
}

.alert-content {
  flex: 1;
  color: #1e293b;
}

.alert-content p {
  margin: 0 0 4px 0;
  font-weight: 600;
  font-size: 14px;
}

.alert-content small {
  color: #64748b;
  font-size: 12px;
}

.alert-dismiss {
  background: rgba(0,0,0,0.1);
  border: none;
  width: 24px;
  height: 24px;
  border-radius: 50%;
  cursor: pointer;
  font-size: 18px;
  display: flex;
  align-items: center;
  justify-content: center;
  transition: all 0.2s;
  color: #64748b;
}

.alert-dismiss:hover {
  background: rgba(0,0,0,0.2);
  transform: rotate(90deg);
}
```

## Features

### Variable Replacement
Messages are personalized for each student:
- Template: "Hi {student_name}, your balance is ${balance}"
- Student 1 sees: "Hi John Smith, your balance is $150"
- Student 2 sees: "Hi Jane Doe, your balance is $200"

### Alert Types with Visual Styles
- **Info**: General announcements
- **Warning**: Payment reminders, schedule changes
- **Urgent**: Immediate action required (animated pulse)
- **Success**: Positive feedback, confirmations

### Expiration
- **No expiration**: Alert stays until student dismisses
- **With expiration**: Auto-deletes after specified date/time

### Security
- RLS ensures students only see their own alerts
- Admins can create/view/delete all alerts
- Expired alerts auto-clean (run `SELECT delete_expired_alerts();` periodically)

## Use Cases

1. **Payment Reminders**: 
   - "Hi {student_name}, your balance is ${balance}. Please make a payment."
   
2. **Schedule Changes**:
   - "⚠️ {student_name}, Group {group} class moved to 5:00 PM tomorrow"
   
3. **Exam Announcements**:
   - "📚 Midterm exam on Friday! Check your email for details."
   
4. **Positive Feedback**:
   - "✅ Great job {student_name}! You scored 95% on the last test!"

## Maintenance

**Clean expired alerts periodically:**
```sql
-- Run in Supabase SQL Editor or via cron job
SELECT delete_expired_alerts();
```

**View all alerts for a student:**
```sql
SELECT * FROM student_alerts 
WHERE student_id = '<student-uuid>'
ORDER BY created_at DESC;
```

**Mark all alerts as read:**
```sql
UPDATE student_alerts 
SET is_read = true 
WHERE student_id = '<student-uuid>';
```

## Troubleshooting

**Error: "relation student_alerts does not exist"**
- Run `create-student-alerts-table.sql` in Supabase SQL Editor

**Alerts not showing for students**
- Check RLS policies are enabled
- Verify student email matches auth user
- Check browser console for errors

**Can't create alerts**
- Ensure you're logged in as admin
- Verify admin email is in `admin_accounts` table
- Check browser console for errors
