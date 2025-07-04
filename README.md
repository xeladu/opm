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
        "measurementId": "..."
    },
}
```

You can find the configuration values in your Firebase dashboard under *Project settings* and *SDK setup and configuration* for your app.

## Supabase configuration steps

Create a file `config.json` in the project root. Add the following content to enable Supabase as a backend.

```json
{
    "provider": "supabase",
    "supabaseConfig": {
        "url": "...",
        "anonKey": "..."
    },
}
```

You can find the url in the *Connect* screen when choosing Flutter as a mobile framework. Your `anonKey` is visible in *Settings* - *API Keys*.

## Appwrite configuration steps

Create a file `config.json` in the project root. Add the following content to enable Appwrite as a backend.

```json
{
    "provider": "appwrite",
    "appwriteConfig": {
        "endpoint": "...",
        "project": "..."
    }
}
```

You can find the configuration values in your Appwrite dashboard under *Settings* and *API credentials* for your app.

## How to deploy

Coming soon

## How to contribute

Coming soon
