# AVC Flutter Build Setup Guide

This document provides comprehensive instructions for setting up build environments and CI/CD pipeline for the AVC Flutter mobile application.

## Prerequisites

### General Requirements
- Flutter SDK 3.16.0 or later
- Dart SDK 3.0.0 or later
- Git

### Android Requirements
- Android Studio or Android SDK
- Java Development Kit (JDK) 17
- Android SDK API Level 26 (Android 8.0) minimum
- Android SDK API Level 34 (Android 14) target

### iOS Requirements (macOS only)
- Xcode 15.0 or later
- iOS 14.0 minimum deployment target
- Apple Developer Account (for distribution)
- CocoaPods

## Local Development Setup

### 1. Clone and Setup Project

```bash
git clone <repository-url>
cd avc_flutter
flutter pub get
flutter packages pub run build_runner build --delete-conflicting-outputs
```

### 2. Android Setup

#### 2.1 Create Signing Configuration

1. Generate a keystore (if you don't have one):
```bash
keytool -genkey -v -keystore android/app/keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias avc-key
```

2. Copy the template and fill in your values:
```bash
cp android/key.properties.template android/key.properties
```

3. Edit `android/key.properties`:
```properties
storeFile=keystore.jks
keyAlias=avc-key
storePassword=your-store-password
keyPassword=your-key-password
```

#### 2.2 Firebase Configuration

1. Create a Firebase project at https://console.firebase.google.com
2. Add Android app with package name `com.avc.mobile`
3. Download `google-services.json` and place it in `android/app/`

### 3. iOS Setup

#### 3.1 Xcode Configuration

1. Open `ios/Runner.xcworkspace` in Xcode
2. Select the Runner project
3. Update Bundle Identifier to your unique identifier
4. Configure signing with your Apple Developer account

#### 3.2 Firebase Configuration

1. Add iOS app to your Firebase project
2. Download `GoogleService-Info.plist` and add it to the iOS project in Xcode

### 4. Build Locally

#### Using Build Scripts

**Linux/macOS:**
```bash
# Debug build for Android
./scripts/build.sh -p android -t debug

# Release build for iOS
./scripts/build.sh -p ios -t release -e prod

# Build for all platforms
./scripts/build.sh -p all -e staging
```

**Windows (PowerShell):**
```powershell
# Debug build for Android
.\scripts\build.ps1 -Platform android -BuildType debug

# Release build for Android
.\scripts\build.ps1 -Platform android -BuildType release -Environment prod

# Build for all platforms
.\scripts\build.ps1 -Platform all -Environment staging
```

#### Using Flutter Commands Directly

**Android:**
```bash
# Debug
flutter build apk --debug --flavor dev

# Release
flutter build appbundle --release --flavor prod
```

**iOS:**
```bash
# Debug
flutter build ios --debug --no-codesign

# Release
flutter build ios --release
```

## CI/CD Pipeline Setup

### GitHub Actions Configuration

The project includes a comprehensive GitHub Actions workflow (`.github/workflows/ci-cd.yml`) that:

1. Runs tests and code analysis
2. Builds for Android and iOS
3. Deploys to TestFlight (iOS) and Google Play Console (Android)

### Required GitHub Secrets

#### Android Secrets
- `ANDROID_KEYSTORE`: Base64 encoded keystore file
- `ANDROID_KEY_ALIAS`: Key alias from keystore
- `ANDROID_STORE_PASSWORD`: Keystore password
- `ANDROID_KEY_PASSWORD`: Key password
- `GOOGLE_PLAY_SERVICE_ACCOUNT`: Base64 encoded service account JSON

#### iOS Secrets
- `IOS_CERTIFICATE`: Base64 encoded .p12 certificate
- `IOS_CERTIFICATE_PASSWORD`: Certificate password
- `IOS_PROVISIONING_PROFILE`: Base64 encoded provisioning profile
- `APP_STORE_CONNECT_API_KEY`: App Store Connect API key
- `APP_STORE_CONNECT_ISSUER_ID`: Issuer ID
- `APP_STORE_CONNECT_KEY_ID`: Key ID

### Setting Up Secrets

#### 1. Android Keystore
```bash
# Encode keystore to base64
base64 -i android/app/keystore.jks | pbcopy
```

#### 2. Google Play Service Account
1. Go to Google Play Console → Setup → API access
2. Create a service account
3. Download the JSON key file
4. Encode to base64:
```bash
base64 -i service-account.json | pbcopy
```

#### 3. iOS Certificate
1. Export certificate from Keychain as .p12
2. Encode to base64:
```bash
base64 -i certificate.p12 | pbcopy
```

#### 4. iOS Provisioning Profile
1. Download from Apple Developer Portal
2. Encode to base64:
```bash
base64 -i profile.mobileprovision | pbcopy
```

## App Store Configuration

### TestFlight (iOS)

1. Create app in App Store Connect
2. Configure app information, pricing, and availability
3. Upload build using Xcode or CI/CD pipeline
4. Add beta testers and release for testing

### Google Play Console (Android)

1. Create app in Google Play Console
2. Complete store listing information
3. Upload AAB file to internal testing track
4. Add testers and release for testing

## Build Flavors and Environments

The project supports three environments:

### Development (dev)
- Package: `com.avc.mobile.dev`
- App Name: "AVC Dev"
- Debug builds, development APIs

### Staging (staging)
- Package: `com.avc.mobile.staging`
- App Name: "AVC Staging"
- Release builds, staging APIs

### Production (prod)
- Package: `com.avc.mobile`
- App Name: "AVC"
- Release builds, production APIs

## Troubleshooting

### Common Android Issues

1. **Gradle build fails**
   - Ensure Java 17 is installed and JAVA_HOME is set
   - Clean project: `flutter clean && flutter pub get`

2. **Signing issues**
   - Verify keystore path and passwords in `key.properties`
   - Ensure keystore file exists in `android/app/`

3. **Firebase issues**
   - Verify `google-services.json` is in `android/app/`
   - Check package name matches Firebase configuration

### Common iOS Issues

1. **Code signing fails**
   - Verify Apple Developer account is active
   - Check provisioning profiles are valid
   - Ensure bundle identifier is unique

2. **Archive fails**
   - Clean build folder in Xcode
   - Verify all dependencies are properly linked

3. **Firebase issues**
   - Verify `GoogleService-Info.plist` is added to Xcode project
   - Check bundle identifier matches Firebase configuration

### CI/CD Issues

1. **GitHub Actions fails**
   - Verify all required secrets are set
   - Check secret values are properly base64 encoded
   - Review workflow logs for specific errors

2. **Deployment fails**
   - Verify app store credentials are valid
   - Check app store configuration is complete
   - Ensure version numbers are incremented

## Performance Optimization

### Build Optimization

1. **Enable R8 (Android)**
   - Already configured in `android/gradle.properties`
   - Reduces APK size by ~30%

2. **Enable bitcode (iOS)**
   - Configured in Xcode project settings
   - Allows Apple to optimize for specific devices

3. **Tree shaking**
   - Automatically enabled in release builds
   - Removes unused code

### CI/CD Optimization

1. **Caching**
   - Flutter SDK and dependencies are cached
   - Reduces build time by ~50%

2. **Parallel builds**
   - Android and iOS builds run in parallel
   - Reduces total pipeline time

3. **Conditional deployment**
   - Only deploys on main branch
   - Saves resources on feature branches

## Security Considerations

### Code Protection

1. **Obfuscation**
   - Enabled in release builds
   - Makes reverse engineering difficult

2. **Certificate pinning**
   - Configured for API communications
   - Prevents man-in-the-middle attacks

3. **Secure storage**
   - Uses platform-specific secure storage
   - Encrypts sensitive data

### CI/CD Security

1. **Secret management**
   - All sensitive data stored as GitHub secrets
   - Never exposed in logs or artifacts

2. **Access control**
   - Deployment requires specific branch and approvals
   - Limited to authorized team members

3. **Audit trail**
   - All builds and deployments are logged
   - Full traceability of changes

## Monitoring and Analytics

### Build Monitoring

1. **Build status**
   - GitHub Actions provides build status
   - Notifications on failures

2. **Test coverage**
   - Codecov integration for coverage reports
   - Minimum 80% coverage required

3. **Performance metrics**
   - Build time tracking
   - APK/IPA size monitoring

### App Monitoring

1. **Crash reporting**
   - Firebase Crashlytics integration
   - Real-time crash alerts

2. **Performance monitoring**
   - Firebase Performance Monitoring
   - App startup and screen load times

3. **Analytics**
   - Firebase Analytics
   - User engagement and feature usage

## Support and Maintenance

### Regular Updates

1. **Dependencies**
   - Monthly dependency updates
   - Security patch reviews

2. **Platform updates**
   - iOS/Android SDK updates
   - Flutter framework updates

3. **Certificate renewal**
   - iOS certificates expire annually
   - Android keystore is long-term

### Backup and Recovery

1. **Keystore backup**
   - Store Android keystore securely
   - Multiple backup locations

2. **Certificate backup**
   - Export iOS certificates
   - Store in secure location

3. **Configuration backup**
   - Version control all configuration
   - Document all setup steps

For additional support, contact the development team or refer to the project documentation.