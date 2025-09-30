-- Complete Supabase Database Setup for Open Password Manager
-- This script creates all necessary tables and configurations

-- =======================================================
-- 1. Create vault table for storing vault entries
-- =======================================================

CREATE TABLE vault (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL DEFAULT auth.uid() REFERENCES auth.users(id) ON DELETE CASCADE,
  name text NOT NULL,
  created_at text NOT NULL,
  updated_at text NOT NULL,
  type text,
  username text NOT NULL,
  password text NOT NULL,
  urls text[],
  comments text,
  folder text,
  ssh_private_key text,
  ssh_public_key text,
  ssh_fingerprint text,
  card_holder_name text,
  card_number text,
  card_expiration_month text,
  card_expiration_year text,
  card_security_code text,
  card_issuer text,
  card_pin text,
  api_key text,
  oauth_provider text,
  oauth_client_id text,
  oauth_access_token text,
  oauth_refresh_token text,
  wifi_ssid text,
  wifi_password text,
  pgp_private_key text,
  pgp_public_key text,
  pgp_fingerprint text,
  smime_certificate text,
  smime_private_key text
);
-- Enable RLS for vault table
ALTER TABLE vault ENABLE ROW LEVEL SECURITY;

-- Create policies for vault table - users can only access their own data
CREATE POLICY "Users can view own vault" ON vault
    FOR SELECT TO authenticated USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own vault" ON vault
    FOR INSERT TO authenticated WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own vault" ON vault
    FOR UPDATE TO authenticated USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own vault" ON vault
    FOR DELETE TO authenticated USING (auth.uid() = user_id);

-- Create index for better performance on vault table
CREATE INDEX idx_vault_user_id ON vault(user_id);

-- =======================================================
-- 2. Create utils table for cross-platform encryption
-- =======================================================

CREATE TABLE utils (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  salt text NOT NULL,
  encMek text NOT NULL,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now()
);

-- Add unique constraint to ensure one salt per user
ALTER TABLE utils ADD CONSTRAINT unique_utils UNIQUE (user_id);

-- Enable RLS for utils table
ALTER TABLE utils ENABLE ROW LEVEL SECURITY;

-- Create policies for utils table - users can only access their own salt
CREATE POLICY "Users can view own utils" ON utils
    FOR SELECT TO authenticated USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own utils" ON utils
    FOR INSERT TO authenticated WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own utils" ON utils
    FOR UPDATE TO authenticated USING (auth.uid() = user_id);

-- Create index for better performance on utils table
CREATE INDEX idx_utils_user_id ON utils(user_id);

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

-- Apply trigger to utils table
CREATE TRIGGER update_utils_updated_at 
    BEFORE UPDATE ON utils 
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
  AND table_name IN ('vault', 'utils');

-- Verify RLS is enabled
SELECT 
    schemaname,
    tablename,
    rowsecurity
FROM pg_tables 
WHERE schemaname = 'public' 
  AND tablename IN ('vault', 'utils');

-- List all policies created
SELECT 
    schemaname,
    tablename,
    policyname,
    cmd,
    qual
FROM pg_policies 
WHERE tablename IN ('vault', 'utils')
ORDER BY tablename, cmd;
