-- Complete Supabase Database Setup for Open Password Manager
-- This script creates all necessary tables and configurations

-- =======================================================
-- 1. Create passwords table for storing password entries
-- =======================================================

CREATE TABLE passwords (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL DEFAULT auth.uid() REFERENCES auth.users(id) ON DELETE CASCADE,
  name text NOT NULL,
  created_at text NOT NULL,
  updated_at text NOT NULL,
  username text NOT NULL,
  password text NOT NULL,
  urls text[],
  comments text,
  folder text
);

-- Enable RLS for passwords table
ALTER TABLE passwords ENABLE ROW LEVEL SECURITY;

-- Create policies for passwords table - users can only access their own data
CREATE POLICY "Users can view own passwords" ON passwords
    FOR SELECT TO authenticated USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own passwords" ON passwords
    FOR INSERT TO authenticated WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own passwords" ON passwords
    FOR UPDATE TO authenticated USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own passwords" ON passwords
    FOR DELETE TO authenticated USING (auth.uid() = user_id);

-- Create index for better performance on passwords table
CREATE INDEX idx_passwords_user_id ON passwords(user_id);

-- =======================================================
-- 2. Create user_salts table for cross-platform encryption
-- =======================================================

CREATE TABLE user_salts (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  salt text NOT NULL,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now()
);

-- Add unique constraint to ensure one salt per user
ALTER TABLE user_salts ADD CONSTRAINT unique_user_salt UNIQUE (user_id);

-- Enable RLS for user_salts table
ALTER TABLE user_salts ENABLE ROW LEVEL SECURITY;

-- Create policies for user_salts table - users can only access their own salt
CREATE POLICY "Users can view own salt" ON user_salts
    FOR SELECT TO authenticated USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own salt" ON user_salts
    FOR INSERT TO authenticated WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own salt" ON user_salts
    FOR UPDATE TO authenticated USING (auth.uid() = user_id);

-- Create index for better performance on user_salts table
CREATE INDEX idx_user_salts_user_id ON user_salts(user_id);

-- =======================================================
-- 3. Create trigger function for updating timestamps
-- =======================================================

CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = now();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Apply trigger to user_salts table
CREATE TRIGGER update_user_salts_updated_at 
    BEFORE UPDATE ON user_salts 
    FOR EACH ROW 
    EXECUTE FUNCTION update_updated_at_column();

-- =======================================================
-- Setup Complete!
-- =======================================================

-- Verify tables were created successfully
SELECT 
    table_name,
    table_type
FROM information_schema.tables 
WHERE table_schema = 'public' 
  AND table_name IN ('passwords', 'user_salts');

-- Verify RLS is enabled
SELECT 
    schemaname,
    tablename,
    rowsecurity
FROM pg_tables 
WHERE schemaname = 'public' 
  AND tablename IN ('passwords', 'user_salts');

-- List all policies created
SELECT 
    schemaname,
    tablename,
    policyname,
    cmd,
    qual
FROM pg_policies 
WHERE tablename IN ('passwords', 'user_salts')
ORDER BY tablename, cmd;
