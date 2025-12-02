-- ========================================================
-- FORUM DATABASE MIGRATION
-- From: author_id UUID → To: student_id INTEGER
-- ========================================================

-- STEP 1: Drop old tables (removes author_id UUID schema)
-- --------------------------------------------------------

DROP TABLE IF EXISTS forum_replies CASCADE;
DROP TABLE IF EXISTS forum_messages CASCADE;

-- STEP 2: Create new tables with student_id INTEGER
-- --------------------------------------------------------

-- Forum Messages Table
CREATE TABLE forum_messages (
  id BIGSERIAL PRIMARY KEY,
  student_id INTEGER NOT NULL,
  student_name TEXT NOT NULL,
  student_email TEXT NOT NULL,
  message TEXT NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Forum Replies Table
CREATE TABLE forum_replies (
  id BIGSERIAL PRIMARY KEY,
  message_id BIGINT REFERENCES forum_messages(id) ON DELETE CASCADE,
  student_id INTEGER NOT NULL,
  student_name TEXT NOT NULL,
  message TEXT NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- STEP 3: Enable Row Level Security
-- --------------------------------------------------------

ALTER TABLE forum_messages ENABLE ROW LEVEL SECURITY;
ALTER TABLE forum_replies ENABLE ROW LEVEL SECURITY;

-- STEP 4: Create RLS Policies
-- --------------------------------------------------------

-- Everyone can read all messages
CREATE POLICY "Anyone can view forum messages"
  ON forum_messages FOR SELECT
  USING (true);

-- Students can create messages
CREATE POLICY "Students can create messages"
  ON forum_messages FOR INSERT
  WITH CHECK (true);

-- Students can update their own messages
CREATE POLICY "Students can update own messages"
  ON forum_messages FOR UPDATE
  USING (student_id = current_setting('app.current_student_id', true)::integer);

-- Students can delete their own messages
CREATE POLICY "Students can delete own messages"
  ON forum_messages FOR DELETE
  USING (student_id = current_setting('app.current_student_id', true)::integer);

-- Everyone can read all replies
CREATE POLICY "Anyone can view replies"
  ON forum_replies FOR SELECT
  USING (true);

-- Students can create replies
CREATE POLICY "Students can create replies"
  ON forum_replies FOR INSERT
  WITH CHECK (true);

-- Students can delete their own replies
CREATE POLICY "Students can delete own replies"
  ON forum_replies FOR DELETE
  USING (student_id = current_setting('app.current_student_id', true)::integer);

-- STEP 5: Create indexes for performance
-- --------------------------------------------------------

CREATE INDEX idx_forum_messages_student_id ON forum_messages(student_id);
CREATE INDEX idx_forum_messages_created_at ON forum_messages(created_at DESC);
CREATE INDEX idx_forum_replies_message_id ON forum_replies(message_id);
CREATE INDEX idx_forum_replies_student_id ON forum_replies(student_id);

-- ========================================================
-- ✅ MIGRATION COMPLETE!
-- ========================================================
-- 
-- Your forum now uses:
-- - student_id INTEGER (matches Student Manager)
-- - student_name TEXT (from Student Manager profile)
-- - student_email TEXT (from Student Manager profile)
--
-- Next steps:
-- 1. Create Supabase Auth accounts for students
-- 2. Students login via Login.html
-- 3. Forum automatically uses their Student Manager data
--
-- ========================================================
Success. No rows returned

