-- Add category column to notifications table
ALTER TABLE notifications
ADD COLUMN IF NOT EXISTS category VARCHAR(50);

-- Set default category for existing records
UPDATE notifications
SET category = 'email'
WHERE category IS NULL AND type LIKE '%email%';
