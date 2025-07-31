#!/bin/bash

# Repository Secrets and Variables Setup Script
# This script demonstrates the GitHub CLI commands to set up the required
# secrets and variables for the CI/CD pipeline

# Note: You must have GitHub CLI (gh) installed and authenticated
# Install: https://cli.github.com/

REPO="xeladu/opm"

echo "Setting up repository variables for CI/CD pipeline..."

# Repository Variables (public, visible in logs)
echo "📋 Setting repository variables..."

gh variable set FIREBASE_PROJECT_ID \
  --repo $REPO \
  --body "opm-password-manager"

echo "✅ FIREBASE_PROJECT_ID set to: opm-password-manager"

# Repository Secrets (encrypted, hidden from logs)
echo "🔐 Setting repository secrets..."

# Note: Replace 'dummy-firebase-token-here' with actual token from 'firebase login:ci'
gh secret set FIREBASE_TOKEN \
  --repo $REPO \
  --body "1//DUMMY_FIREBASE_TOKEN_REPLACE_WITH_ACTUAL_TOKEN_FROM_FIREBASE_LOGIN_CI"

echo "✅ FIREBASE_TOKEN set (dummy value - replace with actual token)"

echo ""
echo "🎉 Repository secrets and variables configured!"
echo ""
echo "⚠️  IMPORTANT: Replace dummy values with actual values:"
echo "   1. Get Firebase token: firebase login:ci"
echo "   2. Update FIREBASE_TOKEN secret with the generated token"
echo "   3. Update FIREBASE_PROJECT_ID if using a different project"
echo ""
echo "📖 See docs/ci-cd-setup.md for detailed setup instructions"