-- Create the notes table for Supabase CRUD Demo
CREATE TABLE notes (
  id BIGSERIAL PRIMARY KEY,
  title TEXT NOT NULL,
  description TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ
);

-- Enable Row Level Security (RLS)
ALTER TABLE notes ENABLE ROW LEVEL SECURITY;

-- Create policy to allow all operations (for demo purposes)
-- In production, add proper authentication policies
CREATE POLICY "Allow all operations on notes" ON notes
  FOR ALL USING (true);

-- Create index for better performance
CREATE INDEX idx_notes_created_at ON notes(created_at DESC);
