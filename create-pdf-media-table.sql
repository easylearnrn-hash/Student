-- ============================================================
-- PDF MEDIA TABLE
-- Stores media items (GIFs, videos, links) associated with student notes
-- ============================================================

-- Create table
CREATE TABLE IF NOT EXISTS pdf_media (
  id BIGSERIAL PRIMARY KEY,
  note_id BIGINT NOT NULL REFERENCES student_notes(id) ON DELETE CASCADE,
  type TEXT NOT NULL CHECK (type IN ('image', 'video', 'link')),
  title TEXT NOT NULL,
  url TEXT NOT NULL,
  description TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create indexes for performance
CREATE INDEX idx_pdf_media_note_id ON pdf_media(note_id);
CREATE INDEX idx_pdf_media_created_at ON pdf_media(created_at DESC);

-- Enable RLS
ALTER TABLE pdf_media ENABLE ROW LEVEL SECURITY;

-- Admin policy: Full access
CREATE POLICY "Admin full access to pdf_media"
  ON pdf_media
  FOR ALL
  USING (
    EXISTS (
      SELECT 1 FROM admin_accounts
      WHERE email = auth.jwt() ->> 'email'
    )
  );

-- Student policy: Read only for their accessible notes
CREATE POLICY "Students can view media for their notes"
  ON pdf_media
  FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM student_notes sn
      WHERE sn.id = pdf_media.note_id
      AND (
        -- Public notes (no payment required)
        sn.requires_payment = false
        OR
        -- Notes they have access to via note_permissions
        EXISTS (
          SELECT 1 FROM note_permissions np
          WHERE np.note_id = sn.id
          AND np.group_name = (
            SELECT group_letter FROM students
            WHERE auth_user_id = auth.uid()
          )
        )
      )
    )
  );

-- Comments
COMMENT ON TABLE pdf_media IS 'Stores media content (GIFs, videos, links) for student notes/PDFs';
COMMENT ON COLUMN pdf_media.note_id IS 'References student_notes.id';
COMMENT ON COLUMN pdf_media.type IS 'Media type: image (GIF), video, or link';
COMMENT ON COLUMN pdf_media.title IS 'Display title for the media';
COMMENT ON COLUMN pdf_media.url IS 'Full URL to the media resource';
COMMENT ON COLUMN pdf_media.description IS 'Optional description/context for students';
