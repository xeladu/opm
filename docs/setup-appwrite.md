# Appwrite Setup Guide

## Overview
This guide walks you through setting up Appwrite as the backend for Open Password Manager, including authentication, database collections, and cross-platform encryption salt storage.

## Prerequisites
- An Appwrite Cloud account or self-hosted Appwrite instance
- Access to [Appwrite Console](https://cloud.appwrite.io/)

## Step 1: Create Appwrite Project

### Using Appwrite Cloud
1. Go to [Appwrite Cloud](https://cloud.appwrite.io/)
2. Sign up or log in to your account
3. Click "Create Project"
4. Enter project details:
   - **Name**: open-password-manager (or your preferred name)
   - **Project ID**: Will be auto-generated (note this down)
5. Click "Create"

### Using Self-Hosted Appwrite
If you're using a self-hosted Appwrite instance, create a project through your Appwrite console.

## Step 2: Configuration File

Create a file `config.json` in the project root with the following content:

```json
{
    "provider": "appwrite",
    "appwriteConfig": {
        "endpoint": "https://cloud.appwrite.io/v1",
        "project": "your-project-id",
        "databaseId": "your-database-id",
        "vaultCollectionId": "your-collection-id",
        "utilsCollectionId": "your-collection-id",
    }
}
```

### Configuration Parameters

| Key | Explanation |
| --- | --- |
| endpoint | Appwrite server endpoint (cloud or self-hosted) |
| project | Your Appwrite project ID |
| databaseId | ID of the project database |
| vaultCollectionId | ID of the collection to store vault entries |
| utilsCollectionId | ID of the collection to store encryption/decryption utilities |

### Finding Your Configuration Values

1. **Endpoint**: 
   - For Appwrite Cloud: `https://cloud.appwrite.io/v1`
   - For self-hosted: `https://your-domain.com/v1`

2. **Project ID**: Available in your project dashboard under Settings → General

3. **Database/Collection IDs**: You'll create these in the next steps

## Step 3: Platform Setup

1. In your Appwrite Console, go to **Settings** → **Platforms**
2. Add platforms for your app:

### Web Platform
- **Platform Type**: Web
- **Name**: Open Password Manager Web
- **Hostname**: `localhost` (for development) and your production domain

### Android Platform (if building for Android)
- **Platform Type**: Android
- **Name**: Open Password Manager Android
- **Package Name**: `com.example.open_password_manager` (match your Flutter app)

### iOS Platform (if building for iOS)
- **Platform Type**: iOS  
- **Name**: Open Password Manager iOS
- **Bundle ID**: `com.example.openPasswordManager` (match your Flutter app)

## Step 4: Authentication Setup

1. Go to **Auth** in your Appwrite Console
2. Authentication is enabled by default
3. Configure settings under **Auth** → **Settings**:
   - **User Registration**: Enable
   - **Email/Password Login**: Enable
   - **Email Verification**: Enable (optional)

## Step 5: Database Setup

### Create Database

1. Go to **Databases** in your Appwrite Console
2. Click "Create Database"
3. Enter details:
   - **Name**: OPM Database
   - **Database ID**: `opm-database`
4. Click "Create"

### Create Vault Entries Collection

1. Inside your database, click "Create Collection"
2. Enter details:
   - **Name**: Vault (your choice)
   - **Collection ID**: `vault` (your choice)
3. Click "Create"

#### Add Attributes to Vault Collection

Add these attributes one by one by clicking "Create Attribute":

| Attribute | Type | Size | Required | Default |
| --- | --- | --- | --- | --- |
| `id` | String | 36 | ✅ | - |
| `name` | String | 256 | ✅ | - |
| `created_at` | String | 256 | ✅ | - |
| `updated_at` | String | 256 | ✅ | - |
| `username` | String | 256 | ✅ | - |
| `password` | String | 256 | ✅ | - |
| `urls` | String (Array) | 1024 | ❌ | - |
| `comments` | String | 1024 | ❌ | - |
| `folder` | String | 256 | ❌ | - |

#### Set Permissions for Vault Collection

1. Go to the **Settings** tab of your vault collection
2. Enable **Document Security**
3. Set **Collection Permissions**:
   - **Create**: Role `users` (any authenticated user can create)
   - **Read**: ❌
   - **Update**: ❌
   - **Delete**: ❌

**Document-level permissions** will be automatically set by the app to restrict access to the document creator only.

### Create Utils Collection

1. Create another collection:
   - **Name**: Utils (your choice) 
   - **Collection ID**: `utils` (your choice)

#### Add Attributes to Utils Collection

| Attribute | Type | Size | Required | Default |
| --- | --- | --- | --- | --- |
| `user_id` | String | 255 | ✅ | - |
| `salt` | String | 255 | ✅ | - |
| `encMek` | String | 255 | ✅ | - |

#### Set Permissions for Utils Collection

1. Enable **Document Security**
2. Set **Collection Permissions**:
   - **Create**: Role `users`
   - **Read**: ❌
   - **Update**: ❌
   - **Delete**: ❌

**Document-level permissions** will be automatically set by the app to restrict access to the document creator only.

#### Create Index for Utils

1. Go to **Indexes** tab in the utils collection
2. Click "Create Index"
3. Set:
   - **Index Key**: `user_id`
   - **Index Type**: `key`
   - **Order**: `ASC`

## Step 6: Test Your Setup

1. Save your `config.json` file in the project root
2. Run the app: `flutter run -d chrome`
3. Try to create an account
4. Sign in with your new account
5. Create a test password entry
6. Sign out and sign in again to verify data persistence
7. Test cross-platform by accessing from different devices/browsers

Your Appwrite backend is now ready for Open Password Manager!
