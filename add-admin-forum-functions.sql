-- Add RPC functions for admin to manage forum messages
-- Run this in Supabase SQL Editor

-- Function to delete forum message (admin only)
CREATE OR REPLACE FUNCTION admin_delete_forum_message(message_id BIGINT)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  -- Check if user is admin
  IF NOT EXISTS (
    SELECT 1 FROM admin_accounts 
    WHERE auth_user_id = auth.uid()
  ) THEN
    RAISE EXCEPTION 'Unauthorized: Admin access required';
  END IF;

  -- Delete the message
  DELETE FROM forum_messages WHERE id = message_id;
END;
$$;

-- Function to toggle pin on forum message (admin only)
CREATE OR REPLACE FUNCTION admin_toggle_pin_forum_message(message_id BIGINT, new_pin_state BOOLEAN)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  -- Check if user is admin
  IF NOT EXISTS (
    SELECT 1 FROM admin_accounts 
    WHERE auth_user_id = auth.uid()
  ) THEN
    RAISE EXCEPTION 'Unauthorized: Admin access required';
  END IF;

  -- Update pin state
  UPDATE forum_messages 
  SET is_pinned = new_pin_state
  WHERE id = message_id;
END;
$$;

-- Function to edit forum message (admin only)
CREATE OR REPLACE FUNCTION admin_edit_forum_message(message_id BIGINT, new_message TEXT)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  -- Check if user is admin
  IF NOT EXISTS (
    SELECT 1 FROM admin_accounts 
    WHERE auth_user_id = auth.uid()
  ) THEN
    RAISE EXCEPTION 'Unauthorized: Admin access required';
  END IF;

  -- Update message
  UPDATE forum_messages 
  SET message = new_message,
      edited_at = NOW()
  WHERE id = message_id;
END;
$$;

-- Success message
SELECT 'Admin forum management functions created successfully' AS result;
