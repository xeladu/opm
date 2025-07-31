# CI/CD Pipeline Setup

This document describes the automated CI/CD pipeline for the Open Password Manager project.

## Pipeline Overview

The CI/CD pipeline is built using GitHub Actions and provides:

- ✅ **Automated Testing** - Runs Flutter tests on every PR
- 🔍 **Code Analysis** - Performs static analysis using Flutter analyzer
- 🏗️ **Build Verification** - Ensures the web app builds successfully
- 🚀 **Preview Deployments** - Deploys PR previews to Firebase Hosting
- 📦 **Production Deployment** - Deploys to production on main branch pushes

## Pipeline Triggers

The pipeline runs on:
- **Pull Request Events**: `opened`, `synchronize`, `reopened`
- **Push to Main Branch**: For production deployments

## Jobs

### 1. Test Job
- Sets up Flutter 3.8.1
- Installs dependencies (`flutter pub get`)
- Runs code analysis (`flutter analyze`)
- Executes tests with coverage (`flutter test --coverage`)
- Uploads coverage reports to Codecov

### 2. Build Web Job
- Builds the Flutter web application for release
- Uploads build artifacts for deployment jobs

### 3. Deploy Preview Job (PR only)
- Downloads build artifacts
- Deploys to Firebase Hosting preview channel
- Comments on PR with preview URL
- Preview expires after 30 days

### 4. Deploy Production Job (main branch only)
- Downloads build artifacts
- Deploys to Firebase Hosting production

## Required Secrets and Variables

### Repository Variables
Configure these in your GitHub repository settings under `Settings > Secrets and variables > Actions`:

| Variable Name | Description | Example Value |
|---------------|-------------|---------------|
| `FIREBASE_PROJECT_ID` | Your Firebase project ID | `opm-password-manager` |

### Repository Secrets
Configure these in your GitHub repository settings under `Settings > Secrets and variables > Actions`:

| Secret Name | Description | How to Get |
|-------------|-------------|------------|
| `FIREBASE_TOKEN` | Firebase CLI token for deployment | Run `firebase login:ci` locally |

## Setup Instructions

### 1. Firebase Project Setup

1. Create a Firebase project at [Firebase Console](https://console.firebase.google.com/)
2. Enable Firebase Hosting for your project
3. Note your project ID

### 2. Firebase CLI Token

To get your Firebase token for GitHub Actions:

```bash
# Install Firebase CLI globally
npm install -g firebase-tools

# Login and get CI token
firebase login:ci
```

Copy the token that's generated and add it as a secret named `FIREBASE_TOKEN`.

### 3. GitHub Repository Configuration

1. Go to your repository `Settings > Secrets and variables > Actions`
2. Add the following **Variables**:
   - `FIREBASE_PROJECT_ID`: Your Firebase project ID
3. Add the following **Secrets**:
   - `FIREBASE_TOKEN`: Your Firebase CLI token

### 4. Firebase Hosting Configuration

The pipeline uses the `firebase.json` and `.firebaserc` files for configuration:

- **firebase.json**: Defines hosting rules, rewrites, and caching headers
- **.firebaserc**: Specifies the default Firebase project

## Pipeline Features

### Test Coverage
- Generates test coverage reports
- Uploads to Codecov for coverage tracking
- Non-blocking (won't fail CI if upload fails)

### Preview Deployments
- Creates unique preview channels for each PR
- Automatically comments on PR with preview URL
- Previews expire after 30 days for cleanup

### Caching
- Flutter SDK and pub cache are cached between runs
- Node.js dependencies are cached for Firebase CLI
- Improves pipeline performance and reliability

### Error Handling
- Jobs depend on each other appropriately
- Deployment only happens after successful tests and builds
- Clear job names and step descriptions for debugging

## Local Development

To test the pipeline components locally:

```bash
# Install dependencies
flutter pub get

# Run analysis
flutter analyze

# Run tests with coverage
flutter test --coverage

# Build web app
flutter build web --release

# Test Firebase deployment (requires setup)
firebase serve --only hosting
```

## Troubleshooting

### Common Issues

1. **Firebase Token Expired**
   - Regenerate token with `firebase login:ci`
   - Update the `FIREBASE_TOKEN` secret

2. **Build Failures**
   - Check Flutter version compatibility
   - Ensure all dependencies are properly specified in `pubspec.yaml`

3. **Deployment Failures**
   - Verify Firebase project ID and permissions
   - Check Firebase Hosting is enabled for the project

### Debug Pipeline
- Check the Actions tab in GitHub for detailed logs
- Each job and step is clearly labeled for easy debugging
- Artifacts are available for download if needed

## Security Notes

- Secrets are not exposed in logs
- Firebase token has appropriate permissions scope
- Preview deployments are temporary and auto-expire
- No sensitive data is committed to the repository