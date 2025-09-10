# Firebase Flutter App

A Flutter application demonstrating Firebase integration with authentication, database, storage, and realtime features.

## 🔥 Firebase Features

This app includes examples of:
- **Authentication**: Email/password and Google sign-in
- **Firestore Database**: CRUD operations with real-time updates
- **Realtime Database**: Live data synchronization
- **Cloud Storage**: File upload and download
- **Security**: Proper Firebase security rules implementation

## 🚀 Quick Start

### Prerequisites
- Flutter SDK installed
- Firebase account
- Android Studio / Xcode for mobile development

### Setup Firebase Configuration

**⚠️ Important**: Firebase configuration files are not included in this repository for security reasons.

📖 **[Follow the complete Firebase setup guide](./FIREBASE_SETUP.md)** for detailed instructions.

**Quick setup:**
1. Create a Firebase project at [Firebase Console](https://console.firebase.google.com/)
2. Install Firebase CLI: `npm install -g firebase-tools`
3. Install FlutterFire CLI: `dart pub global activate flutterfire_cli`
4. Run: `flutterfire configure` in the project directory
5. Copy `.env.example` to `.env` and configure if needed

### Run the App

```bash
# Install dependencies
flutter pub get

# Run on your preferred platform
flutter run
```

## 📁 Project Structure

```
lib/
├── main.dart                 # App entry point with Firebase initialization
├── firebase_options.dart     # Generated Firebase configuration (not in git)
├── components/
│   └── custom_button.dart    # Reusable UI components
└── pages/
    ├── authentication.dart   # Auth examples (login/signup)
    ├── database.dart         # Firestore CRUD operations
    ├── realtime_database.dart # Realtime Database examples
    └── storage.dart          # File upload/download examples
```

## 🔒 Security

- Firebase configuration files are gitignored for security
- Environment variables are used for sensitive data
- Proper Firebase security rules should be configured
- See [FIREBASE_SETUP.md](./FIREBASE_SETUP.md) for security best practices

## 📚 Documentation

- [Firebase Setup Guide](./FIREBASE_SETUP.md) - Complete setup instructions
- [Quick Setup](./SETUP.md) - Environment configuration
- [Flutter Documentation](https://docs.flutter.dev/)
- [Firebase Documentation](https://firebase.google.com/docs)

## 🛠️ Development

### Available Scripts

```bash
# Run the app
flutter run

# Run tests
flutter test

# Build for production
flutter build apk          # Android
flutter build ios          # iOS
flutter build web          # Web
```

### Troubleshooting

If you encounter issues:
1. Check [FIREBASE_SETUP.md](./FIREBASE_SETUP.md) troubleshooting section
2. Ensure all Firebase configuration files are properly placed
3. Verify Firebase services are enabled in your project
4. Run `flutter clean && flutter pub get` to refresh dependencies

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch
3. **Do not commit Firebase configuration files**
4. Test your changes thoroughly
5. Submit a pull request

## 📄 License

This project is open source and available under the [MIT License](LICENSE).
