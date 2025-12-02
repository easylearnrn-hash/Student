# Online Status Tracking Setup

## Overview
The online status tracking feature allows admins to see which students are currently online, when they were last seen, and their session history.

## Database Setup

**IMPORTANT**: You must run the SQL file first to create the database table.

1. Open your Supabase project dashboard
2. Go to the SQL Editor
3. Copy the contents of `setup-student-sessions.sql`
4. Run the SQL script

This will create:
- `student_sessions` table with RLS policies
- Automatic cleanup function for inactive sessions (30-minute timeout)
- Indexes for performance

## How It Works

### Student Portal (`student-portal.html`)
- **Session Start**: When a student logs in, `startSession()` creates a new session record
- **Heartbeat**: Every 2 minutes, `updateSessionActivity()` updates the `last_activity` timestamp
- **Session End**: When a student logs out, `endSession()` marks the session as inactive

### Admin Portal (`Student-Portal-Admin.html`)
- **Status Button**: Each student row now has an "ℹ️ Status" button
- **Status Modal**: Clicking the button shows:
  - 🟢 **Online Now** - if the student has an active session (last activity within 30 minutes)
  - 🔴 **Offline** - if the student's last session ended or timed out
  - ⚪ **Never logged in** - if the student has no session history
- **Session Details**:
  - Logged in time
  - Session duration
  - Last activity time
  - Recent session history (up to 5 sessions)

## Features

### Automatic Cleanup
The database automatically marks sessions as inactive if:
- No heartbeat received for 30 minutes
- Cleanup function runs every 5 minutes via pg_cron

### Real-Time Updates
- Heartbeat updates every 2 minutes ensure accurate "last seen" times
- Session duration is calculated in real-time

### Session History
- Tracks up to 5 recent sessions per student
- Shows login time, duration, and status (Active/Ended)

## UI Design
- Glassmorphism modal with backdrop blur
- Animated status indicators with pulsing green dot for online users
- Gradient headers matching the existing admin portal theme
- Responsive layout with smooth animations

## Testing

1. **Test Session Creation**:
   - Log in as a student via `student-portal.html`
   - Check Supabase database: `student_sessions` table should have a new row with `is_active = true`

2. **Test Heartbeat**:
   - Wait 2 minutes while logged in
   - Check database: `last_activity` should update every 2 minutes

3. **Test Session End**:
   - Log out from student portal
   - Check database: session should be marked `is_active = false` with `logout_time` set

4. **Test Admin View**:
   - Log in as admin to `Student-Portal-Admin.html`
   - Click "ℹ️ Status" button on any student row
   - Modal should show current status and session history

5. **Test Idle Timeout**:
   - Log in as student and leave inactive for 30+ minutes
   - Session should automatically be marked inactive by cleanup function

## Security

- **RLS Policies**: 
  - Students can only view/update their own sessions
  - Admins (in `admin_accounts` table) can view all sessions
  - No one can delete sessions (audit trail)
  
- **Authentication**: 
  - All queries require valid Supabase auth session
  - Admin portal uses `ensureAdminSession()` before loading session data

## Future Enhancements

Possible improvements:
- Push notifications when students come online
- Daily/weekly activity reports
- Export session history to CSV
- Real-time status updates without refresh (using Supabase realtime subscriptions)
- Session duration analytics and charts
