-- Create the realtime_data table for Supabase Real-time Get/Set Demo
CREATE TABLE realtime_data (
  id BIGSERIAL PRIMARY KEY,
  key TEXT UNIQUE NOT NULL,
  value TEXT NOT NULL,
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Enable Row Level Security (RLS)
ALTER TABLE realtime_data ENABLE ROW LEVEL SECURITY;

-- Create policy to allow all operations (for demo purposes)
-- In production, add proper authentication policies
CREATE POLICY "Allow all operations on realtime_data" ON realtime_data
  FOR ALL USING (true);

-- Enable real-time for this table
ALTER PUBLICATION supabase_realtime ADD TABLE realtime_data;

-- Create index for better performance
CREATE INDEX idx_realtime_data_key ON realtime_data(key);
CREATE INDEX idx_realtime_data_updated_at ON realtime_data(updated_at DESC);

-- Insert some sample data
INSERT INTO realtime_data (key, value) VALUES 
  ('counter', '0'),
  ('temperature', '22°C'),
  ('status', 'online');