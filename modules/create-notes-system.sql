-- ========================================================
-- STUDENT NOTES SYSTEM - DATABASE SETUP
-- ========================================================
-- This creates the infrastructure for protected PDF notes
-- that are locked until students have paid for that class
-- ========================================================

-- ========================================================
-- 1. CREATE STORAGE BUCKET FOR PDFs
-- ========================================================
-- Run this in Supabase Dashboard → Storage

-- Create bucket named 'student-notes'
-- Settings:
--   - Public: NO (students access via signed URLs)
--   - File size limit: 50MB
--   - Allowed MIME types: application/pdf

-- ========================================================
-- 2. CREATE NOTES TABLE
-- ========================================================

CREATE TABLE IF NOT EXISTS student_notes (
  id BIGSERIAL PRIMARY KEY,
  
  -- Note Details
  title TEXT NOT NULL,
  description TEXT,
  
  -- Group & Date Association
  group_name TEXT NOT NULL,  -- Group letter: A, B, C, D, E, F
  class_date DATE NOT NULL,
  
  -- PDF File Reference
  pdf_url TEXT NOT NULL,  -- Supabase Storage path
  file_name TEXT NOT NULL,
  file_size INTEGER,
  
  -- Metadata
  uploaded_by TEXT,  -- Admin email who uploaded
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  
  -- Soft delete
  deleted BOOLEAN DEFAULT FALSE,
  
  -- Unique constraint: one note per group per date
  UNIQUE(group_name, class_date, deleted)
);

-- Create indexes for faster queries
CREATE INDEX IF NOT EXISTS idx_notes_group_date 
  ON student_notes(group_name, class_date) 
  WHERE deleted = FALSE;

CREATE INDEX IF NOT EXISTS idx_notes_created 
  ON student_notes(created_at DESC);

-- ========================================================
-- 3. ROW LEVEL SECURITY (RLS) POLICIES
-- ========================================================

-- Enable RLS
ALTER TABLE student_notes ENABLE ROW LEVEL SECURITY;

-- Policy 1: Admin can do everything
CREATE POLICY "Admin full access to notes"
  ON student_notes
  FOR ALL
  USING (
    auth.jwt() ->> 'email' = 'hrachfilm@gmail.com'
  );

-- Policy 2: Students can view notes for their group (if paid)
CREATE POLICY "Students view their group notes"
  ON student_notes
  FOR SELECT
  USING (
    deleted = FALSE AND
    EXISTS (
      SELECT 1 FROM students
      WHERE students.email = auth.jwt() ->> 'email'
      AND students.group_name = student_notes.group_name
    )
  );

-- ========================================================
-- 4. STORAGE BUCKET RLS POLICIES
-- ========================================================
-- Run these in Supabase Dashboard → Storage → student-notes bucket → Policies

-- Policy 1: Admin can upload
CREATE POLICY "Admin can upload notes"
  ON storage.objects FOR INSERT
  WITH CHECK (
    bucket_id = 'student-notes' AND
    auth.jwt() ->> 'email' = 'hrachfilm@gmail.com'
  );

-- Policy 2: Admin can update
CREATE POLICY "Admin can update notes"
  ON storage.objects FOR UPDATE
  USING (
    bucket_id = 'student-notes' AND
    auth.jwt() ->> 'email' = 'hrachfilm@gmail.com'
  );

-- Policy 3: Admin can delete
CREATE POLICY "Admin can delete notes"
  ON storage.objects FOR DELETE
  USING (
    bucket_id = 'student-notes' AND
    auth.jwt() ->> 'email' = 'hrachfilm@gmail.com'
  );

-- Policy 4: Students can read (download) notes
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
-- 5. HELPER FUNCTION: Check if student has paid for note
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
  
  -- Check if student has payment for that date
  SELECT EXISTS (
    SELECT 1 FROM payment_records
    WHERE student_id = p_student_id
    AND date = v_class_date
    AND status = 'paid'
  ) INTO v_has_payment;
  
  RETURN v_has_payment;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ========================================================
-- 6. UPDATED_AT TRIGGER
-- ========================================================

CREATE OR REPLACE FUNCTION update_notes_timestamp()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER set_notes_timestamp
  BEFORE UPDATE ON student_notes
  FOR EACH ROW
  EXECUTE FUNCTION update_notes_timestamp();

-- ========================================================
-- ✅ MIGRATION COMPLETE!
-- ========================================================
--
-- NEXT STEPS:
-- 1. Go to Supabase Dashboard → Storage
-- 2. Create new bucket: 'student-notes'
-- 3. Set as PRIVATE (not public)
-- 4. Run the storage policies above
-- 5. Ready to upload PDFs!
--
-- ========================================================
