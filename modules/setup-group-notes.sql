-- =====================================================
-- Group Notes with Payment-Locked Access
-- =====================================================
-- This schema creates a system where admins can add notes
-- for specific groups and class dates. Students can only
-- access notes for classes they have paid for.
-- =====================================================

-- Create note_folders table for organizing notes by system/topic
CREATE TABLE IF NOT EXISTS public.note_folders (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  folder_name TEXT NOT NULL UNIQUE,
  description TEXT,
  icon TEXT DEFAULT '📚',
  sort_order INTEGER DEFAULT 0,
  is_current BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  deleted_at TIMESTAMPTZ
);

-- Create note_templates table - reusable notes that can be assigned to multiple groups
CREATE TABLE IF NOT EXISTS public.note_templates (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  folder_id UUID REFERENCES public.note_folders(id) ON DELETE SET NULL,
  note_title TEXT NOT NULL,
  note_content TEXT,
  file_url TEXT,
  file_name TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  created_by TEXT,
  deleted_at TIMESTAMPTZ
);

-- Create note_assignments table - links templates to specific groups and dates
CREATE TABLE IF NOT EXISTS public.note_assignments (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  template_id UUID REFERENCES public.note_templates(id) ON DELETE CASCADE,
  group_id TEXT NOT NULL,
  class_date DATE NOT NULL,
  is_open BOOLEAN DEFAULT false,
  assigned_at TIMESTAMPTZ DEFAULT NOW(),
  assigned_by TEXT,
  deleted_at TIMESTAMPTZ,
  UNIQUE(template_id, group_id, class_date)
);

-- Create indexes for performance
CREATE INDEX IF NOT EXISTS idx_note_templates_folder 
  ON public.note_templates(folder_id) 
  WHERE deleted_at IS NULL;

CREATE INDEX IF NOT EXISTS idx_note_assignments_template 
  ON public.note_assignments(template_id) 
  WHERE deleted_at IS NULL;

CREATE INDEX IF NOT EXISTS idx_note_assignments_group_date 
  ON public.note_assignments(group_id, class_date) 
  WHERE deleted_at IS NULL;

CREATE INDEX IF NOT EXISTS idx_note_folders_sort 
  ON public.note_folders(sort_order) 
  WHERE deleted_at IS NULL;

-- Enable RLS
ALTER TABLE public.note_folders ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.note_templates ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.note_assignments ENABLE ROW LEVEL SECURITY;

-- Drop existing policies if any
DROP POLICY IF EXISTS "Admins can manage note folders" ON public.note_folders;
DROP POLICY IF EXISTS "Students can view note folders" ON public.note_folders;
DROP POLICY IF EXISTS "Admins can manage note templates" ON public.note_templates;
DROP POLICY IF EXISTS "Students can view note templates" ON public.note_templates;
DROP POLICY IF EXISTS "Admins can manage note assignments" ON public.note_assignments;
DROP POLICY IF EXISTS "Students can view assigned notes" ON public.note_assignments;

-- Folder policies
CREATE POLICY "Admins can manage note folders"
  ON public.note_folders
  FOR ALL
  USING (
    EXISTS (
      SELECT 1 FROM public.admin_accounts
      WHERE admin_accounts.email = auth.jwt() ->> 'email'
    )
  );

CREATE POLICY "Students can view note folders"
  ON public.note_folders
  FOR SELECT
  USING (deleted_at IS NULL);

-- Note template policies
CREATE POLICY "Admins can manage note templates"
  ON public.note_templates
  FOR ALL
  USING (
    EXISTS (
      SELECT 1 FROM public.admin_accounts
      WHERE admin_accounts.email = auth.jwt() ->> 'email'
    )
  );

CREATE POLICY "Students can view note templates"
  ON public.note_templates
  FOR SELECT
  USING (
    deleted_at IS NULL
    AND EXISTS (
      SELECT 1
      FROM public.note_assignments
      WHERE note_assignments.template_id = note_templates.id
        AND note_assignments.deleted_at IS NULL
        AND EXISTS (
          SELECT 1
          FROM public.students
          WHERE students.email = auth.jwt() ->> 'email'
            AND students.show_in_grid IS TRUE
            AND UPPER(
              REGEXP_REPLACE(COALESCE(students.group_name, ''), '^group\\s*', '')
            ) = UPPER(
              REGEXP_REPLACE(COALESCE(note_assignments.group_id, ''), '^group\\s*', '')
            )
        )
    )
  );

-- Note assignment policies
CREATE POLICY "Admins can manage note assignments"
  ON public.note_assignments
  FOR ALL
  USING (
    EXISTS (
      SELECT 1 FROM public.admin_accounts
      WHERE admin_accounts.email = auth.jwt() ->> 'email'
    )
  );

-- Student policy: Can view assignments for their group (payment check done in app layer)
CREATE POLICY "Students can view assigned notes"
  ON public.note_assignments
  FOR SELECT
  USING (
    deleted_at IS NULL
    AND EXISTS (
      SELECT 1
      FROM public.students
      WHERE students.email = auth.jwt() ->> 'email'
        AND students.show_in_grid IS TRUE
        AND UPPER(
          REGEXP_REPLACE(COALESCE(students.group_name, ''), '^group\\s*', '')
        ) = UPPER(
          REGEXP_REPLACE(COALESCE(public.note_assignments.group_id, ''), '^group\\s*', '')
        )
    )
  );

-- Create function to auto-update updated_at timestamp
CREATE OR REPLACE FUNCTION update_group_notes_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger for auto-updating timestamps
DROP TRIGGER IF EXISTS set_group_notes_updated_at ON public.group_notes;
CREATE TRIGGER set_group_notes_updated_at
  BEFORE UPDATE ON public.group_notes
  FOR EACH ROW
  EXECUTE FUNCTION update_group_notes_updated_at();

-- Grant permissions
GRANT SELECT ON public.note_folders TO authenticated;
GRANT ALL ON public.note_folders TO service_role;
GRANT SELECT ON public.group_notes TO authenticated;
GRANT ALL ON public.group_notes TO service_role;

-- Insert default folders
INSERT INTO public.note_folders (folder_name, description, icon, sort_order) 
VALUES 
  ('Medical Terminology', 'Medical terms and abbreviations', '📖', 1),
  ('Human Anatomy', 'Body structures and systems', '🫀', 2),
  ('Medication Suffixes and Drug Classes', 'Drug classifications and naming', '💊', 3),
  ('Cardiovascular System', 'Heart, blood vessels, circulation', '❤️', 4),
  ('Endocrine System', 'Hormones, metabolism, diabetes', '⚡', 5),
  ('Gastrointestinal & Hepatic System', 'Digestion, liver, nutrition', '🍽️', 6),
  ('Respiratory System', 'Lungs, breathing, oxygenation', '🫁', 7),
  ('Renal', 'Kidneys, fluids, electrolytes', '💧', 8),
  ('Fluids, Electrolytes & Nutrition', 'Fluid balance and nutrition', '💉', 9),
  ('Eye Disorders', 'Vision and eye conditions', '👁️', 10),
  ('EENT', 'Ears, eyes, nose, throat', '👂', 11),
  ('Burns and Skin', 'Integumentary system and wounds', '🩹', 12),
  ('Reproductive and Sexual Health System', 'Reproductive health', '🌸', 13),
  ('Maternal Health', 'Pregnancy, labor, postpartum', '🤰', 14),
  ('Pediatrics', 'Children, growth, development', '👶', 15),
  ('Medical-Surgical Care', 'General med-surg nursing', '🏥', 16),
  ('Mental Health', 'Psychiatric nursing care', '🧘', 17),
  ('Autoimmune & Infectious Disorders', 'Immunity and infections', '🛡️', 18),
  ('Neurology', 'Brain, nerves, neurological disorders', '🧠', 19),
  ('Cancer', 'Oncology and cancer care', '🎗️', 20),
  ('Musculoskeletal Disorders', 'Bones, muscles, mobility', '🦴', 21),
  ('Psycho-Social Aspects', 'Psychosocial nursing care', '💭', 22),
  ('Nursing Skills and Fundamentals', 'Basic nursing skills', '🩺', 23),
  ('Pharmacology', 'Drug actions and interactions', '💊', 24)
ON CONFLICT (folder_name) DO NOTHING;

COMMENT ON TABLE public.note_folders IS 'Organizes notes by body system/topic (e.g., Cardiovascular, Respiratory)';
COMMENT ON TABLE public.group_notes IS 'Stores notes for specific groups and class dates. Access is controlled by payment status.';
COMMENT ON COLUMN public.group_notes.folder_id IS 'Reference to note folder/category';
COMMENT ON COLUMN public.group_notes.group_id IS 'Group identifier (A, B, C, etc.)';
COMMENT ON COLUMN public.group_notes.class_date IS 'Date of the class this note belongs to';
COMMENT ON COLUMN public.group_notes.note_title IS 'Title of the note';
COMMENT ON COLUMN public.group_notes.note_content IS 'Text content of the note';
COMMENT ON COLUMN public.group_notes.file_url IS 'URL to uploaded PDF or file';
COMMENT ON COLUMN public.group_notes.file_name IS 'Original filename';
