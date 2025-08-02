# Firebase Setup Guide

## Overview
This guide walks you through setting up Firebase as the backend for Open Password Manager, including authentication, Firestore database, and cross-platform encryption salt storage.

## Prerequisites
- A Google account
- Access to [Firebase Console](https://console.firebase.google.com/)

## Step 1: Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Create a project" or "Add project"
3. Enter your project name (e.g., "open-password-manager")
4. Choose whether to enable Google Analytics (optional)
5. Click "Create project"

## Step 2: Configuration File

Create a file `config.json` in the project root with the following content:

```json
{
    "provider": "firebase",
    "firebaseConfig": {
        "apiKey": "...",
        "authDomain": "...",
        "projectId": "...",
        "storageBucket": "...",
        "messagingSenderId": "...",
        "appId": "...",
        "measurementId": "...",
        "passwordCollectionPrefix": "passwords",
        "saltCollectionName": "salts",
    }
}
```

### Configuration Parameters

| Key | Explanation |
| --- | --- |
| apiKey | Required for identifying the Firebase project |
| authDomain | Required for identifying the Firebase project |
| projectId | Required for identifying the Firebase project |
| storageBucket | Required for identifying the Firebase project |
| messagingSenderId | Required for identifying the Firebase project |
| appId | Required for identifying the Firebase project |
| measurementId | Required for identifying the Firebase project |
| passwordCollectionPrefix | Collection name prefix for passwords to be used in Firestore |
| saltCollectionName | Collection name for salts to be used in Firestore |

You can find these configuration values in your Firebase dashboard:
1. Go to Project Settings (⚙️ icon)
2. Scroll down to "Your apps" section
3. Click "SDK setup and configuration"
4. Copy the config values

## Step 3: Enable Authentication

1. In the Firebase Console, go to "Authentication"
2. Click "Get started" if it's your first time
3. Go to the "Sign-in method" tab
4. Click on "Email/Password"
5. Enable "Email/Password" authentication
6. Click "Save"

## Step 4: Set Up Firestore Database

### Create Database
1. In the Firebase Console, go to "Firestore Database"
2. Click "Create database"
3. Choose "Start in test mode" (we'll add security rules later)
4. Select a location for your database
5. Click "Done"

### Configure Security Rules

Go to the "Rules" tab in Firestore and replace the default rules with:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Allow users to read and write their own salt for cross-platform encryption
    match /user_salts/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Allow users to access their own password entries
    match /{collection}/{document=**} {
      allow read, write: if request.auth != null && collection == 'passwords_' + request.auth.uid;
    }
  }
}
```

Click "Publish" to deploy the rules.

## Step 5: Test Your Setup

1. Save your `config.json` file in the project root
2. Run the app: `flutter run -d chrome`
3. Try to create an account and sign in
4. Create a test password entry
5. Sign out and sign in again to verify data persistence

Your Firebase backend is now ready for Open Password Manager!
