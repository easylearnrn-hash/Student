-- Create portal_settings table for global portal configuration
CREATE TABLE IF NOT EXISTS portal_settings (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  setting_key text UNIQUE NOT NULL,
  setting_value jsonb NOT NULL,
  updated_at timestamptz DEFAULT now(),
  updated_by uuid REFERENCES auth.users(id)
);

-- Enable RLS
ALTER TABLE portal_settings ENABLE ROW LEVEL SECURITY;

-- Admin read access
CREATE POLICY "Admins can read portal settings"
  ON portal_settings
  FOR SELECT
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM admin_accounts
      WHERE email = auth.jwt()->>'email'
      AND is_active = true
    )
  );

-- Admin write access
CREATE POLICY "Admins can update portal settings"
  ON portal_settings
  FOR ALL
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM admin_accounts
      WHERE email = auth.jwt()->>'email'
      AND is_active = true
    )
  );

-- Anon read access (for students to see settings)
CREATE POLICY "Anyone can read portal settings"
  ON portal_settings
  FOR SELECT
  TO anon
  USING (true);

-- Insert default Christmas theme setting (disabled by default)
INSERT INTO portal_settings (setting_key, setting_value)
VALUES ('christmas_theme', '{"enabled": false}'::jsonb)
ON CONFLICT (setting_key) DO NOTHING;

-- Create index for faster lookups
CREATE INDEX IF NOT EXISTS idx_portal_settings_key ON portal_settings(setting_key);

-- Add helpful comment
COMMENT ON TABLE portal_settings IS 'Global portal configuration settings (Christmas theme, announcements, etc.)';
