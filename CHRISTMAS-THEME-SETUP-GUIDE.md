# 🎄 Christmas Theme Setup Guide

## The Problem We Fixed

**OLD APPROACH (Broken)**: localStorage  
- ❌ Only affected admin's browser
- ❌ Students saw nothing
- ❌ Each browser needed separate configuration

**NEW APPROACH (Working)**: Supabase Database  
- ✅ Global setting affects ALL users
- ✅ Admin controls it centrally
- ✅ Students see changes immediately on reload

---

## Step 1: Create Database Table

Run this SQL in your Supabase SQL Editor:

```sql
-- Located in: setup-portal-settings-table.sql
CREATE TABLE IF NOT EXISTS portal_settings (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  setting_key text UNIQUE NOT NULL,
  setting_value jsonb NOT NULL,
  updated_at timestamptz DEFAULT now(),
  updated_by uuid REFERENCES auth.users(id)
);

-- Enable RLS + policies (see full file for details)

-- Insert default (disabled)
INSERT INTO portal_settings (setting_key, setting_value)
VALUES ('christmas_theme', '{"enabled": false}'::jsonb)
ON CONFLICT (setting_key) DO NOTHING;
```

**IMPORTANT**: Copy the entire contents of `setup-portal-settings-table.sql` and run it in Supabase.

---

## Step 2: Upload Files to Production

Upload these files to your server (`student.richyfesta.com`):

1. **Student-Portal-Admin.html** (admin interface)
2. **student-portal.html** (student interface)

Both files have been updated to use the database instead of localStorage.

---

## Step 3: Enable the Theme

1. Go to **Student-Portal-Admin.html** on your live site
2. Navigate to **Settings tab** (⚙️ icon)
3. **Check the "Enable Christmas Theme" checkbox**
4. You'll see an alert: **"✅ Christmas Theme Enabled!"**

The setting is now saved in Supabase and will affect **every student** who visits the portal.

---

## Step 4: Verify It's Working

### Test as Admin:
1. Open browser console (F12)
2. Check the Settings tab checkbox
3. Look for: `🎄 Christmas Theme saved to database: ENABLED ✅`

### Test as Student:
1. Open **student-portal.html** in a **different browser** (or incognito)
2. Log in as a student
3. Check console - should see:
   ```
   🎄 Fetching Christmas theme setting from database...
   🎄 Christmas Theme Check: ENABLED
   🎄 Christmas Theme: Class added to body
   ❄️ Snow Effect: Initializing...
   ❄️ Snow Effect: Started (999 particles)
   ```

4. **Visual confirmation**:
   - ❄️ Snowflakes at top/bottom of page
   - 🎄 Christmas tree on right side
   - ❄️ Falling snow animation
   - ✍️ "Welcome" text in Dancing Script font

---

## How It Works

### Admin Side (Student-Portal-Admin.html):

```javascript
// When checkbox is toggled:
async function toggleChristmasTheme() {
  const isEnabled = checkbox.checked;
  
  // Save to Supabase
  await supabase
    .from('portal_settings')
    .update({ 
      setting_value: { enabled: isEnabled },
      updated_at: new Date().toISOString()
    })
    .eq('setting_key', 'christmas_theme');
}
```

### Student Side (student-portal.html):

```javascript
// On page load:
const { data } = await supabase
  .from('portal_settings')
  .select('setting_value')
  .eq('setting_key', 'christmas_theme')
  .single();

const christmasEnabled = data?.setting_value?.enabled === true;

if (christmasEnabled) {
  document.body.classList.add('christmas-theme');
  initializeSnowEffect();
}
```

### CSS (student-portal.html):

```css
/* Hidden by default */
#christmas-tree-container { display: none; }
#snowCanvas { display: none; }
body::before, body::after { display: none; }

/* Shown when enabled */
body.christmas-theme #christmas-tree-container { display: block; }
body.christmas-theme #snowCanvas { display: block; }
body.christmas-theme::before { display: block; } /* Top snowflakes */
body.christmas-theme::after { display: block; }  /* Bottom snowflakes */
body.christmas-theme #welcomeMessage { 
  font-family: 'Dancing Script', cursive; 
}
```

---

## Troubleshooting

### "Failed to save setting" Error
- **Cause**: RLS policies not set up correctly
- **Fix**: Re-run `setup-portal-settings-table.sql` in Supabase

### Students Still Don't See Theme
- **Check 1**: Verify checkbox is checked in admin portal
- **Check 2**: Run this query in Supabase SQL Editor:
  ```sql
  SELECT * FROM portal_settings WHERE setting_key = 'christmas_theme';
  ```
  Should return: `{"enabled": true}`

- **Check 3**: Check student portal console for errors
- **Check 4**: Hard refresh student portal (**Cmd+Shift+R**)

### Theme Partially Working
- **Symptoms**: See snowflakes but no tree, or tree but no snow
- **Fix**: CSS issue - check that `body.christmas-theme` class is present:
  ```javascript
  document.body.classList.contains('christmas-theme') // should return true
  ```

---

## Disable the Theme (After Holidays)

1. Go to **Student-Portal-Admin.html**
2. Settings tab → **Uncheck the checkbox**
3. Alert confirms: **"❌ Christmas Theme Disabled"**
4. All decorations will disappear for all students on next page load

---

## Database Schema

```sql
Table: portal_settings
Columns:
  - id: uuid (primary key)
  - setting_key: text (unique) ← 'christmas_theme'
  - setting_value: jsonb ← {"enabled": true/false}
  - updated_at: timestamptz
  - updated_by: uuid (references admin_accounts)

RLS Policies:
  - Admins: Full read/write access
  - Anon (students): Read-only access
```

---

## Future Settings You Can Add

This `portal_settings` table can be extended for other global portal configurations:

```sql
-- Example: Add announcement banner
INSERT INTO portal_settings (setting_key, setting_value)
VALUES ('announcement_banner', '{
  "enabled": true,
  "message": "Holiday break: Dec 20 - Jan 5",
  "color": "green"
}'::jsonb);

-- Example: Add maintenance mode
INSERT INTO portal_settings (setting_key, setting_value)
VALUES ('maintenance_mode', '{
  "enabled": false,
  "message": "System maintenance in progress"
}'::jsonb);
```

---

## Files Modified

- ✅ `Student-Portal-Admin.html` - Admin toggle (Supabase write)
- ✅ `student-portal.html` - Student display (Supabase read)
- ✅ `setup-portal-settings-table.sql` - Database schema

---

## Commit History

- **2c93e14** - 🎄 Fix: Switch Christmas theme from localStorage to Supabase (global control)
- **e3a347e** - 🔍 Debug: Add detailed logging to Christmas theme toggle + user alerts
- **23bad54** - 🐛 Debug: Add extensive logging and debug panel for Christmas theme
- **a108d63** - 🎄 Christmas: Add admin checkbox control + conditional CSS + snow/tree animations
- **acba24e** - 🎨 Initial Christmas theme integration

---

**Status**: ✅ Ready for Production  
**Next Step**: Run `setup-portal-settings-table.sql` in Supabase, then upload files to server!
