# Supabase Setup Guide

## Overview
This guide walks you through setting up Supabase as the backend for Open Password Manager, including authentication, PostgreSQL database, and cross-platform encryption salt storage.

## Prerequisites
- A GitHub, Google, or email account
- Access to [Supabase Dashboard](https://supabase.com/dashboard)

## Step 1: Create Supabase Project

1. Go to [Supabase Dashboard](https://supabase.com/dashboard)
2. Click "New project"
3. Select your organization or create a new one
4. Enter project details:
   - **Name**: open-password-manager (or your preferred name)
   - **Database Password**: Choose a secure password
   - **Region**: Select the region closest to your users
5. Click "Create new project"
6. Wait for the project to be provisioned (usually takes 1-2 minutes)

## Step 2: Configuration File

Create a file `config.json` in the project root with the following content:

```json
{
    "provider": "supabase",
    "supabaseConfig": {
        "url": "https://your-project-id.supabase.co",
        "anonKey": "your-anon-key",
        "vaultDbName": "your-password-table-name",
        "utilsDbName": "your-salt-table-name"
    }
}
```

### Configuration Parameters

| Key | Explanation |
| --- | --- |
| url | Your Supabase project URL |
| anonKey | Public anonymous key for client connections |
| vaultDbName | Table name for storing password entries |
| utilsDbName | Table name for storing encryption utilities |

### Finding Your Configuration Values

1. In your Supabase dashboard, go to **Settings** → **API**
2. Copy the **Project URL** for the `url` field
3. Copy the **anon/public** key for the `anonKey` field
4. Choose a table name for `vaultDbName` (e.g., "vault")
5. Choose a table name for `utilsDbName` (e.g., "utils")

## Step 3: Database Setup

### Create Vault Entries Table

1. Go to the **SQL Editor** in your Supabase dashboard
2. Click "New query"
3. Run this SQL script to create the vault table (Remember to replace the table names if needed!):

```sql
-- Create vault table
CREATE TABLE vault (
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

-- Enable RLS
ALTER TABLE vault ENABLE ROW LEVEL SECURITY;

-- Create policies for passwords table
CREATE POLICY "Users can view own vault" ON vault
    FOR SELECT TO authenticated USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own vault" ON vault
    FOR INSERT TO authenticated WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own vault" ON vault
    FOR UPDATE TO authenticated USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own vault" ON vault
    FOR DELETE TO authenticated USING (auth.uid() = user_id);

-- Create index for better performance
CREATE INDEX idx_passwords_user_id ON vault(user_id);
```

### Create Utils Table

Run this SQL script to create the salt storage table for cross-platform encryption:

```sql
-- Create utils table for cross-platform encryption salt storage
CREATE TABLE utils (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  salt text NOT NULL,
  encMek text NOT NULL,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now()
);

-- Add unique constraint to ensure one entry per user
ALTER TABLE utils ADD CONSTRAINT unique_utils UNIQUE (user_id);

-- Enable RLS (Row Level Security)
ALTER TABLE utils ENABLE ROW LEVEL SECURITY;

-- Create policies for RLS
CREATE POLICY "Users can view own utils" ON utils
    FOR SELECT TO authenticated USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own utils" ON utils
    FOR INSERT TO authenticated WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own utils" ON utils
    FOR UPDATE TO authenticated USING (auth.uid() = user_id);

-- Create index for better performance
CREATE INDEX idx_utils_user_id ON utils(user_id);

-- Add trigger to update updated_at column
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = now();
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_utils_updated_at 
    BEFORE UPDATE ON utils 
    FOR EACH ROW 
    EXECUTE FUNCTION update_updated_at_column();
```

## Step 4: Authentication Setup

Supabase provides authentication out of the box. To configure it:

1. Go to **Authentication** → **Settings** in your dashboard
2. Under **Email Auth**, ensure these are enabled:
   - **Enable email confirmations**: ✅ (recommended)
   - **Enable email change confirmations**: ✅ (recommended)
   - **Enable secure password change**: ✅ (recommended)

### Email Templates (Optional)

You can customize email templates under **Authentication** → **Email Templates**:
- Confirmation email
- Magic link email  
- Password recovery email

## Step 5: Row Level Security (RLS)

Your tables should already have RLS enabled from the SQL scripts above. You can verify this in the **Database** → **Tables** section:

1. Click on your vault table
2. Go to the **Policies** tab
3. Verify you see policies for SELECT, INSERT, UPDATE, and DELETE
4. Repeat for the utils table

## Step 6: Test Your Setup

1. Save your `config.json` file in the project root
2. Run the app: `flutter run -d chrome`
3. Try to create an account (you may need to confirm via email)
4. Sign in with your new account
5. Create a test password entry
6. Sign out and sign in again to verify data persistence
7. Test on different platforms to verify cross-platform encryption works

Your Supabase backend is now ready for Open Password Manager!
