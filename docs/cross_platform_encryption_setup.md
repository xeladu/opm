# Cross-Platform Encryption Setup Guide

## Overview
This guide explains how to set up backend databases for cross-platform encryption support in Open Password Manager. The shared salt management ensures that encrypted data can be decrypted across all platforms (Web, Android, iOS).

## What Was Fixed
Previously, each platform stored encryption salts locally:
- **Web**: Browser localStorage
- **Android/iOS**: FlutterSecureStorage

This caused "Invalid Cipher Text Exception" when trying to decrypt data across platforms because each platform generated different salts, resulting in different encryption keys.

**Solution**: Store salts in the backend database so all platforms use the same salt for the same user.

---

## Supabase Setup

### 1. Run Complete Setup Script
Execute this SQL in your Supabase SQL Editor (available in `docs/supabase_complete_setup.sql`):

```sql
-- Complete setup script creates both passwords and user_salts tables
-- See docs/supabase_complete_setup.sql for the full script
```

Or run the individual scripts:
1. Create the passwords table for your password entries
2. Create the user_salts table using `docs/supabase_user_salts_table.sql`

### 2. Verify Setup
1. Check that both `passwords` and `user_salts` tables exist in your Supabase dashboard
2. Verify RLS policies are enabled for both tables
3. Test authentication and salt generation

For detailed setup instructions, see [Supabase Setup Guide](setup-supabase.md).

---

## Firebase Setup

### 1. Configure Firestore Security Rules
Add these rules to your Firestore Security Rules in the Firebase Console:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Allow users to read and write their own salt
    match /user_salts/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Existing rules for password entries
    match /{collection}/{document=**} {
      allow read, write: if request.auth != null && collection == 'passwords_' + request.auth.uid;
    }
  }
}
```

### 2. Collection Structure
The app automatically creates documents in the `user_salts` collection with this structure:
```
user_salts/
  {userId}/
    salt: "base64-encoded-salt"
    createdAt: serverTimestamp
    updatedAt: serverTimestamp
```

For detailed setup instructions, see [Firebase Setup Guide](setup-firebase.md).

---

## Appwrite Setup

### 1. Create user_salts Collection
1. Create a collection with ID: `user_salts`
2. Add attributes:
   - `userId` (String, required, size: 255)
   - `salt` (String, required, size: 255)
   - `createdAt` (DateTime, optional)
   - `updatedAt` (DateTime, optional)

### 2. Set Permissions
**Collection Level:**
- Create Documents: Any
- Read Documents: Users
- Update Documents: Users
- Delete Documents: Users

### 3. Create Index
Create an index for efficient queries:
- Index Key: `userId`
- Index Type: key
- Order: ASC

For detailed setup instructions, see [Appwrite Setup Guide](setup-appwrite.md).

---

## Testing Cross-Platform Encryption

### 1. Test Scenario
1. Sign in on web platform and create a password entry
2. Sign in with the same account on Android
3. Verify that the password entry can be decrypted and displayed correctly
4. Create a new entry on Android
5. Switch back to web and verify the new entry is accessible

### 2. Expected Behavior
- ✅ No "Invalid Cipher Text Exception"
- ✅ All password entries are accessible across all platforms
- ✅ Salt is automatically synchronized via backend storage
- ✅ First-time users get a salt generated and stored in the backend

### 3. Troubleshooting
If you still get encryption errors:
1. Check that the user is properly authenticated
2. Verify backend permissions are correctly set
3. Clear app data and sign in again to regenerate salt
4. Check backend logs for salt retrieval/storage errors

---

## Migration Notes

### For Existing Users
Existing users with local salts will need to:
1. Export their passwords (if possible)
2. Clear app data to reset local storage
3. Sign in again (this will generate a new backend-stored salt)
4. Re-import or manually re-enter their passwords

### Data Migration Script (Optional)
If you need to migrate existing local salts to the backend, you'll need to:
1. Create a migration function that reads local salts
2. Upload them to the backend during the next sign-in
3. This requires custom implementation based on your app's current state

---

## Security Considerations

1. **Salt Storage**: Salts are stored in the backend but are not sensitive security data by themselves
2. **User Isolation**: Each user can only access their own salt through proper authentication and authorization
3. **Platform Consistency**: All platforms now use identical encryption keys for the same user
4. **Backup**: Salts are automatically backed up with your backend database
5. **Recovery**: Users who lose access can recover their salt by signing in on any platform

This setup ensures consistent cross-platform encryption while maintaining security best practices.
