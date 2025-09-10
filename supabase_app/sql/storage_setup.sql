-- Storage Setup for Supabase Image Upload
-- This file sets up the storage bucket and policies for image uploads

-- Create the profiles storage bucket
INSERT INTO storage.buckets (id, name, public)
VALUES ('profiles', 'profiles', true)
ON CONFLICT (id) DO NOTHING;

-- Note: RLS is already enabled on storage.objects by default in Supabase
-- No need to manually enable it

-- Policy: Allow authenticated users to upload their own profile images
CREATE POLICY "Users can upload their own profile images" ON storage.objects
  FOR INSERT WITH CHECK (
    bucket_id = 'profiles' 
    AND auth.uid()::text = (storage.foldername(name))[1]
    AND auth.role() = 'authenticated'
  );

-- Policy: Allow authenticated users to view all profile images
CREATE POLICY "Users can view all profile images" ON storage.objects
  FOR SELECT USING (
    bucket_id = 'profiles'
    AND auth.role() = 'authenticated'
  );

-- Policy: Allow users to update their own profile images
CREATE POLICY "Users can update their own profile images" ON storage.objects
  FOR UPDATE USING (
    bucket_id = 'profiles' 
    AND auth.uid()::text = (storage.foldername(name))[1]
    AND auth.role() = 'authenticated'
  );

-- Policy: Allow users to delete their own profile images
CREATE POLICY "Users can delete their own profile images" ON storage.objects
  FOR DELETE USING (
    bucket_id = 'profiles' 
    AND auth.uid()::text = (storage.foldername(name))[1]
    AND auth.role() = 'authenticated'
  );

-- Alternative: More permissive policy for demo purposes (LESS SECURE)
-- Uncomment these and comment out the above policies if you want to allow all operations

-- CREATE POLICY "Allow all operations on profiles bucket" ON storage.objects
--   FOR ALL USING (bucket_id = 'profiles');

-- Note: The file naming convention should be: profile_{user_id}.jpg
-- This ensures users can only access their own files when using the secure policies above