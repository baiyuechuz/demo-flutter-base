# Quick Setup Guide

This is a quick setup guide for getting the Firebase Flutter app running. For comprehensive setup instructions, see [FIREBASE_SETUP.md](./FIREBASE_SETUP.md).

## Prerequisites

- Flutter SDK installed
- Firebase account
- Git repository cloned

## Quick Setup Steps

### 1. Install Required Tools

```bash
# Install Firebase CLI
npm install -g firebase-tools

# Install FlutterFire CLI
dart pub global activate flutterfire_cli

# Login to Firebase
firebase login
```

### 2. Configure Firebase

```bash
# In the firebase_app directory, run:
flutterfire configure
```

This will:
- List your Firebase projects
- Let you select which project to use
- Generate required configuration files automatically

### 3. Set Up Environment Variables (Optional)

```bash
# Copy the environment template
cp .env.example .env

# Edit .env with your specific values if needed
```

### 4. Install Dependencies and Run

```bash
# Install Flutter dependencies
flutter pub get

# Run the app
flutter run
```

## What Gets Generated

After running `flutterfire configure`, you should have:

- `android/app/google-services.json` - Android Firebase config
- `ios/Runner/GoogleService-Info.plist` - iOS Firebase config  
- `macos/Runner/GoogleService-Info.plist` - macOS Firebase config
- `lib/firebase_options.dart` - Flutter Firebase options
- `firebase.json` - Firebase project configuration

## Troubleshooting

### Common Issues:

**"No Firebase projects found"**
- Make sure you're logged in: `firebase login`
- Check you have projects in [Firebase Console](https://console.firebase.google.com/)

**"FlutterFire command not found"**
- Install FlutterFire CLI: `dart pub global activate flutterfire_cli`
- Make sure Dart's global packages are in your PATH

**Build errors**
- Run `flutter clean && flutter pub get`
- For iOS: `cd ios && pod install`

### Need More Help?

📖 **[See the complete Firebase setup guide](./FIREBASE_SETUP.md)** for:
- Detailed step-by-step instructions
- Platform-specific setup
- Security configuration
- Advanced troubleshooting
- Firebase services configuration

## Security Reminders

⚠️ **Important**: 
- Firebase configuration files are automatically gitignored
- Never commit API keys or sensitive configuration
- Use different Firebase projects for dev/staging/production
- Configure proper Firebase security rules

## Next Steps

After setup:
1. Test authentication features
2. Try database operations
3. Upload files to storage
4. Configure Firebase security rules
5. Set up different environments (dev/prod)