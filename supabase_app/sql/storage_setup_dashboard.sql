-- Alternative Storage Setup for Supabase Dashboard
-- Use this version if you get permission errors with the main setup file

-- Step 1: Create the profiles storage bucket (run this first)
INSERT INTO storage.buckets (id, name, public)
VALUES ('profiles', 'profiles', true)
ON CONFLICT (id) DO NOTHING;

-- Step 2: Create storage policies (run these one by one)
-- Policy 1: Allow authenticated users to upload their own profile images
CREATE POLICY "Users can upload their own profile images" ON storage.objects
  FOR INSERT WITH CHECK (
    bucket_id = 'profiles' 
    AND auth.uid()::text = (storage.foldername(name))[1]
    AND auth.role() = 'authenticated'
  );

-- Policy 2: Allow authenticated users to view all profile images  
CREATE POLICY "Users can view all profile images" ON storage.objects
  FOR SELECT USING (
    bucket_id = 'profiles'
    AND auth.role() = 'authenticated'
  );

-- Policy 3: Allow users to update their own profile images
CREATE POLICY "Users can update their own profile images" ON storage.objects
  FOR UPDATE USING (
    bucket_id = 'profiles' 
    AND auth.uid()::text = (storage.foldername(name))[1]
    AND auth.role() = 'authenticated'
  );

-- Policy 4: Allow users to delete their own profile images
CREATE POLICY "Users can delete their own profile images" ON storage.objects
  FOR DELETE USING (
    bucket_id = 'profiles' 
    AND auth.uid()::text = (storage.foldername(name))[1]
    AND auth.role() = 'authenticated'
  );