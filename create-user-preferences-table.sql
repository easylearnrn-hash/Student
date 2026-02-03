-- Create user_preferences table for storing user settings
-- This table stores navbar settings and other user preferences

CREATE TABLE IF NOT EXISTS user_preferences (
  id BIGSERIAL PRIMARY KEY,
  user_id UUID NOT NULL UNIQUE REFERENCES auth.users(id) ON DELETE CASCADE,
  navbar_settings JSONB,
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create index on user_id for faster lookups
CREATE INDEX IF NOT EXISTS idx_user_preferences_user_id ON user_preferences(user_id);

-- Enable RLS
ALTER TABLE user_preferences ENABLE ROW LEVEL SECURITY;

-- Policy: Users can manage their own preferences
CREATE POLICY "Users can manage own preferences"
ON user_preferences
FOR ALL
TO authenticated
USING (user_id = auth.uid())
WITH CHECK (user_id = auth.uid());

-- Policy: Admins can view all preferences
CREATE POLICY "Admins can view all preferences"
ON user_preferences
FOR SELECT
TO authenticated
USING (
  EXISTS (
    SELECT 1 FROM admin_accounts 
    WHERE admin_accounts.auth_user_id = auth.uid()
  )
);

COMMENT ON TABLE user_preferences IS 'Stores user-specific preferences like navbar settings';
COMMENT ON COLUMN user_preferences.navbar_settings IS 'JSON object containing navbar configuration (size, opacity, position, button order, etc.)';
