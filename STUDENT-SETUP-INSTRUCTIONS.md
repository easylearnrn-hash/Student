# 📚 Student Account Setup Guide

## Step 1: Check Which Students Need Accounts

Run this SQL first:
```sql
SELECT id, name, email, auth_user_id
FROM students
WHERE show_in_grid = true
ORDER BY name;
```

Students with `auth_user_id = null` need accounts created.

---

## Step 2: Create Auth Account in Supabase Dashboard

For **EACH student**:

1. Go to Supabase Dashboard → **Authentication** → **Users**
2. Click **"Add User"** (green button top right)
3. Fill in:
   - **Email**: `student@email.com` (from database)
   - **Password**: `TempPass2024!` (temporary - they can change later)
   - **Auto Confirm User**: ✅ **CHECK THIS BOX** (important!)
4. Click **Create User**
5. **COPY THE UUID** that appears (looks like: `a1b2c3d4-e5f6-7890-abcd-ef1234567890`)

---

## Step 3: Link Auth Account to Student Record

After creating the auth user, run this SQL **with the actual UUID**:

```sql
UPDATE students 
SET auth_user_id = 'PASTE-THE-ACTUAL-UUID-HERE',
    role = 'student'
WHERE email = 'student@email.com';
```

**Replace**:
- `PASTE-THE-ACTUAL-UUID-HERE` with the UUID you copied
- `student@email.com` with the student's actual email

---

## Step 4: Test Student Login

1. Open `Login.html` in browser
2. Click **"Student Login"** tab
3. Login with:
   - Email: `student@email.com`
   - Password: `TempPass2024!`
4. Should redirect to student portal with their data

---

## 🚀 Quick Test: Create ONE Student First

Let's test with one student before doing all 20:

1. Pick any student from your database
2. Follow Steps 2-4 above for that ONE student
3. Test their login works
4. Then repeat for the rest

---

## ⚡ Alternative: Let Students Register Themselves

If you want, I can create a **Student Registration Page** where:
- Students go to the signup page
- They enter their email (must match database)
- They create their own password
- System automatically links their account

This is much faster than manually creating 20+ accounts!

Let me know if you want me to build this! 🎓
