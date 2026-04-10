-- ========================================================
-- PROTECTED PDF NOTES SYSTEM - COMPLETE DATABASE SETUP
-- ========================================================
-- This script creates the complete database structure for the
-- student notes system with payment verification and RLS policies.
-- ========================================================

-- 1. CREATE STUDENT_NOTES TABLE
-- ========================================================
CREATE TABLE IF NOT EXISTS student_notes (
  id BIGSERIAL PRIMARY KEY,
  title TEXT NOT NULL,
  description TEXT,
  group_name TEXT NOT NULL,  -- Group letter: A, B, C, D, E, F
  class_date DATE NOT NULL,
  pdf_url TEXT NOT NULL,  -- Path in storage bucket
  file_name TEXT NOT NULL,
  file_size INTEGER,
  uploaded_by TEXT,  -- Admin email who uploaded
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  deleted BOOLEAN DEFAULT FALSE,
  UNIQUE(group_name, class_date, deleted)  -- One note per group per date
);

-- 2. CREATE INDEXES
-- ========================================================
CREATE INDEX IF NOT EXISTS idx_notes_group_date 
  ON student_notes(group_name, class_date)
  WHERE deleted = FALSE;

CREATE INDEX IF NOT EXISTS idx_notes_created_at 
  ON student_notes(created_at DESC)
  WHERE deleted = FALSE;

-- 3. ENABLE ROW LEVEL SECURITY
-- ========================================================
ALTER TABLE student_notes ENABLE ROW LEVEL SECURITY;

-- 4. CREATE RLS POLICIES FOR STUDENT_NOTES TABLE
-- ========================================================

-- Drop existing policies if they exist
DROP POLICY IF EXISTS "Admin full access to notes" ON student_notes;
DROP POLICY IF EXISTS "Students view their group notes" ON student_notes;

-- Admin full access policy
CREATE POLICY "Admin full access to notes"
  ON student_notes FOR ALL
  USING (auth.jwt() ->> 'email' = 'hrachfilm@gmail.com');

-- Students can view their group's notes
CREATE POLICY "Students view their group notes"
  ON student_notes FOR SELECT
  USING (
    deleted = FALSE AND
    EXISTS (
      SELECT 1 FROM students
      WHERE students.email = auth.jwt() ->> 'email'
      AND students.group_name = student_notes.group_name
    )
  );

-- 5. CREATE PAYMENT VERIFICATION FUNCTION
-- ========================================================
CREATE OR REPLACE FUNCTION check_note_access(
  p_student_id BIGINT,
  p_note_id BIGINT
)
RETURNS BOOLEAN AS $$
DECLARE
  v_class_date DATE;
  v_group_name TEXT;
  v_has_payment BOOLEAN;
BEGIN
  -- Get note details
  SELECT class_date, group_name
  INTO v_class_date, v_group_name
  FROM student_notes
  WHERE id = p_note_id AND deleted = FALSE;
  
  -- If note not found, return false
  IF NOT FOUND THEN
    RETURN FALSE;
  END IF;
  
  -- Check if student has paid for this date
  SELECT EXISTS (
    SELECT 1 FROM payment_records
    WHERE student_id = p_student_id
    AND date = v_class_date
    AND status = 'paid'
  ) INTO v_has_payment;
  
  RETURN v_has_payment;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 6. CREATE UPDATED_AT TRIGGER
-- ========================================================

-- Drop existing trigger if it exists (but keep the function - it's shared)
DROP TRIGGER IF EXISTS update_student_notes_updated_at ON student_notes;

-- Create or replace the function (won't affect other tables using it)
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create the trigger for student_notes table
CREATE TRIGGER update_student_notes_updated_at
  BEFORE UPDATE ON student_notes
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- ========================================================
-- STORAGE POLICIES (RUN AFTER CREATING BUCKET)
-- ========================================================
-- 
-- IMPORTANT: First create the storage bucket:
-- 1. Go to Supabase Dashboard → Storage
-- 2. Create new bucket named: "student-notes"
-- 3. Set as PRIVATE (not public)
-- 4. Then run the policies below
-- 
-- ========================================================

-- Drop existing storage policies if they exist
DROP POLICY IF EXISTS "Admin can upload notes" ON storage.objects;
DROP POLICY IF EXISTS "Admin can update notes" ON storage.objects;
DROP POLICY IF EXISTS "Admin can delete notes" ON storage.objects;
DROP POLICY IF EXISTS "Students can read notes" ON storage.objects;

-- Admin can upload notes
CREATE POLICY "Admin can upload notes"
  ON storage.objects FOR INSERT
  WITH CHECK (
    bucket_id = 'student-notes' AND
    auth.jwt() ->> 'email' = 'hrachfilm@gmail.com'
  );

-- Admin can update notes
CREATE POLICY "Admin can update notes"
  ON storage.objects FOR UPDATE
  USING (
    bucket_id = 'student-notes' AND
    auth.jwt() ->> 'email' = 'hrachfilm@gmail.com'
  );

-- Admin can delete notes
CREATE POLICY "Admin can delete notes"
  ON storage.objects FOR DELETE
  USING (
    bucket_id = 'student-notes' AND
    auth.jwt() ->> 'email' = 'hrachfilm@gmail.com'
  );

-- Students can read notes (with signed URLs)
CREATE POLICY "Students can read notes"
  ON storage.objects FOR SELECT
  USING (
    bucket_id = 'student-notes' AND
    EXISTS (
      SELECT 1 FROM students
      WHERE students.email = auth.jwt() ->> 'email'
    )
  );

-- ========================================================
-- SETUP COMPLETE!
-- ========================================================
-- 
-- Next steps:
-- 1. ✅ Run this SQL in Supabase SQL Editor
-- 2. 📦 Create storage bucket "student-notes" in Supabase UI
-- 3. 🔒 Storage policies will auto-apply after bucket creation
-- 4. 🚀 Ready to build upload UI in Student Manager
-- 
-- ========================================================
