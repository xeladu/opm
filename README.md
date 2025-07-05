# Open Password Manager
Open Password Manager is an open source alternative with encrypted storage for various hosters implemented as a Flutter web app.

## Features

- Password store
- Cloud or local
- End-to-end encryption
- Export passwords

## Supported hosters and deployment types

- [Firebase](https://firebase.google.com/) 
- [Supabase](https://supabase.com/) 
- [Appwrite](https://appwrite.io/) 

## Firebase configuration steps

### Configuration file

Create a file `config.json` in the project root. Add the following content to enable Firebase as a backend.

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
        "collectionId": "..."
    },
}
```

| Key | Explanation |
| --- | --- |
| apiKey | Required for identifying the Firebase project |
| authDomain | Required for identifying the Firebase project |
| projectId | Required for identifying the Firebase project |
| storageBucket | Required for identifying the Firebase project |
| messagingSenderId | Required for identifying the Firebase project |
| appId | Required for identifying the Firebase project |
| measurementId | Required for identifying the Firebase project |
| collectionId | Collection name prefix to be used in Firestore |

You can find the configuration values in your Firebase dashboard under *Project settings* and *SDK setup and configuration* for your app.

### Firebase Authentication

Activate the email/password authentication provider!

### Firebase Firestore

Passwords are stored in documents in the collection `$collection_<uid>` where `$collection` is the configuration value and `<uid>` is the unique user identifier of Firebase Authentication. The default database instance `(default)` is used. Secondary databases are not supported. You can set a security rule to allow/deny access per user like this:

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /{collection}/{document=**} {
      allow read, write: if request.auth != null && collection == 'passwords_' + request.auth.uid;
    }
  }
}
```

## Supabase configuration steps

Create a file `config.json` in the project root. Add the following content to enable Supabase as a backend.

```json
{
    "provider": "supabase",
    "supabaseConfig": {
        "url": "...",
        "anonKey": "...",
        "databaseName": "..."
    },
}
```

| Key | Explanation |
| --- | --- |
| url | Required for identifying the Supabase project |
| anonKey | Required for identifying the Supabase project |
| databaseName | The name of the database to store the data |

You can find the url in the *Connect* screen when choosing Flutter as a mobile framework. Your `anonKey` is visible in *Settings* - *API Keys*.

### Database

Create a database and put the name in the config file. Add the following columns:

// TODO

## Appwrite configuration steps

Create a file `config.json` in the project root. Add the following content to enable Appwrite as a backend.

```json
{
    "provider": "appwrite",
    "appwriteConfig": {
        "endpoint": "...",
        "project": "...",
        "databaseId": "...",
        "collectionId": "..."
    }
}
```

| Key | Explanation |
| --- | --- |
| endpoint | Required for identifying the Appwrite project |
| project | Required for identifying the Appwrite project |
| databaseId | The id of the database to store the data |
| collectionId | The id of the collection to store the data |

You can find the configuration values in your Appwrite dashboard under *Settings* and *API credentials* for your app.

### Database

// TODO

## How to deploy

Coming soon

## How to contribute

Coming soon
