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
        "passwordDbName": "your-password-table-name",
        "saltDbName": "your-salt-table-name"
    }
}
```

### Configuration Parameters

| Key | Explanation |
| --- | --- |
| url | Your Supabase project URL |
| anonKey | Public anonymous key for client connections |
| passwordDbName | Table name for storing password entries |
| saltDbName | Table name for storing encryption salts |

### Finding Your Configuration Values

1. In your Supabase dashboard, go to **Settings** → **API**
2. Copy the **Project URL** for the `url` field
3. Copy the **anon/public** key for the `anonKey` field
4. Choose a table name for `passwordDbName` (e.g., "passwords")
5. Choose a table name for `saltDbName` (e.g., "user_salts")

## Step 3: Database Setup

### Create Password Entries Table

1. Go to the **SQL Editor** in your Supabase dashboard
2. Click "New query"
3. Run this SQL script to create the passwords table:

```sql
-- Create passwords table
CREATE TABLE passwords (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL DEFAULT auth.uid() REFERENCES auth.users(id) ON DELETE CASCADE,
  name text NOT NULL,
  created_at text NOT NULL,
  updated_at text NOT NULL,
  username text NOT NULL,
  password text NOT NULL,
  urls text[],
  comments text
);

-- Enable RLS
ALTER TABLE passwords ENABLE ROW LEVEL SECURITY;

-- Create policies for passwords table
CREATE POLICY "Users can view own passwords" ON passwords
    FOR SELECT TO authenticated USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own passwords" ON passwords
    FOR INSERT TO authenticated WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own passwords" ON passwords
    FOR UPDATE TO authenticated USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own passwords" ON passwords
    FOR DELETE TO authenticated USING (auth.uid() = user_id);

-- Create index for better performance
CREATE INDEX idx_passwords_user_id ON passwords(user_id);
```

### Create User Salts Table

Run this SQL script to create the salt storage table for cross-platform encryption:

```sql
-- Create user_salts table for cross-platform encryption salt storage
CREATE TABLE user_salts (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  salt text NOT NULL,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now()
);

-- Add unique constraint to ensure one salt per user
ALTER TABLE user_salts ADD CONSTRAINT unique_user_salt UNIQUE (user_id);

-- Enable RLS (Row Level Security)
ALTER TABLE user_salts ENABLE ROW LEVEL SECURITY;

-- Create policies for RLS
CREATE POLICY "Users can view own salt" ON user_salts
    FOR SELECT TO authenticated USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own salt" ON user_salts
    FOR INSERT TO authenticated WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own salt" ON user_salts
    FOR UPDATE TO authenticated USING (auth.uid() = user_id);

-- Create index for better performance
CREATE INDEX idx_user_salts_user_id ON user_salts(user_id);

-- Add trigger to update updated_at column
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = now();
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_user_salts_updated_at 
    BEFORE UPDATE ON user_salts 
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

1. Click on your `passwords` table
2. Go to the **Policies** tab
3. Verify you see policies for SELECT, INSERT, UPDATE, and DELETE
4. Repeat for the `user_salts` table

## Step 6: Test Your Setup

1. Save your `config.json` file in the project root
2. Run the app: `flutter run -d chrome`
3. Try to create an account (you may need to confirm via email)
4. Sign in with your new account
5. Create a test password entry
6. Sign out and sign in again to verify data persistence
7. Test on different platforms to verify cross-platform encryption works

## Database Schema

### Tables Created

1. **`passwords`** - Stores encrypted password entries
   ```sql
   - id (uuid, primary key)
   - user_id (uuid, foreign key to auth.users)
   - name (text, encrypted)
   - username (text, encrypted) 
   - password (text, encrypted)
   - urls (text[], encrypted)
   - comments (text, encrypted)
   - created_at (text)
   - updated_at (text)
   ```

2. **`user_salts`** - Stores encryption salts for cross-platform compatibility
   ```sql
   - id (uuid, primary key)
   - user_id (uuid, foreign key to auth.users, unique)
   - salt (text, base64 encoded salt)
   - created_at (timestamp with time zone)
   - updated_at (timestamp with time zone)
   ```

Your Supabase backend is now ready for Open Password Manager!
