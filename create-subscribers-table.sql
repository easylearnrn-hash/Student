-- ============================================================
-- SUBSCRIBERS TABLE
-- Stores people who signed up via the Subscribe button on
-- the login page. Separate from students and waiting list.
-- ============================================================

CREATE TABLE IF NOT EXISTS subscribers (
  id          BIGSERIAL PRIMARY KEY,
  full_name   TEXT NOT NULL,
  email       TEXT,
  phone       TEXT,
  status      TEXT DEFAULT 'active' CHECK (status IN ('active', 'converted')),
  converted_student_id BIGINT,
  notes       TEXT,
  created_at  TIMESTAMPTZ DEFAULT NOW(),
  updated_at  TIMESTAMPTZ DEFAULT NOW()
);

-- Indexes
CREATE INDEX IF NOT EXISTS idx_subscribers_email  ON subscribers (email);
CREATE INDEX IF NOT EXISTS idx_subscribers_status ON subscribers (status);

-- Row-Level Security
ALTER TABLE subscribers ENABLE ROW LEVEL SECURITY;

-- Anyone (anon + authenticated) can subscribe via the public form
CREATE POLICY "Public can insert subscribers"
  ON subscribers FOR INSERT
  TO anon, authenticated
  WITH CHECK (true);

-- Only admins can read subscriber records
CREATE POLICY "Admin can read subscribers"
  ON subscribers FOR SELECT
  USING (is_arnoma_admin());

-- Only admins can update (e.g., mark as converted)
CREATE POLICY "Admin can update subscribers"
  ON subscribers FOR UPDATE
  USING (is_arnoma_admin());

-- Only admins can delete
CREATE POLICY "Admin can delete subscribers"
  ON subscribers FOR DELETE
  USING (is_arnoma_admin());
