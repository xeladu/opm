# Deployment

Open Password Manager currently supports the following platforms

| Platform | OPM support |
| --- | --- |
| Android | ✅ |
| iOS | ⌛ coming soon |
| Web | ✅ |
| MacOS | ⌛ coming soon |
| Linux | ⌛ coming soon |
| Windows | ⌛ coming soon |

All releases are tracked under the [GitHub releases page](https://github.com/xeladu/opm/releases).

To create a new release, create a new branch named `release/x.y.z` and follow the [semantic version](https://semver.org/) naming approach. This triggers the [Deploy](https://github.com/xeladu/opm/blob/main/.github/workflows/deploy.yml) pipeline.

> ⚠️ Remember to align app versions to branch versions or the pipeline will fail!

The pipeline will perform the following deployment steps:

- Build and publish web version to Firebase Hosting live channel
- Build and push Android version to Google Play store (no publishing)
- Build and push iOS version to Apple App store (no publishing) (⌛ coming soon)
- Build and publish Windows version (⌛ coming soon)
- Build and publish MacOS version (⌛ coming soon)
- Build and publish Linux version (⌛ coming soon)

A new release will only be created if all deployment steps work!