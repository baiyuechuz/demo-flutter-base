# Flutter Backend-as-a-Service Demo

A comprehensive demonstration project showcasing the implementation of popular Backend-as-a-Service (BaaS) solutions with Flutter. This repository contains two separate Flutter applications that demonstrate the features and capabilities of **Firebase** and **Supabase**.

## Purpose

This demo project serves as a practical comparison and learning resource for developers choosing between Firebase and Supabase for their Flutter applications. Each implementation demonstrates:

- Authentication systems
- Real-time database operations
- Cloud storage solutions
- API integrations
- Best practices for each platform

## Project Structure

```
demo-flutter-base/
├── firebase/          # Firebase implementation
│   ├── lib/
│   ├── android/
│   ├── ios/
│   ├── web/
│   └── pubspec.yaml
├── supabase/          # Supabase implementation
│   ├── lib/
│   ├── android/
│   ├── ios/
│   ├── web/
│   └── pubspec.yaml
└── README.md
```

## Firebase Demo

The Firebase implementation demonstrates:

- **Firebase Authentication** - User registration, login, and session management
- **Cloud Firestore** - Real-time NoSQL database operations
- **Firebase Storage** - File upload and management
- **Cloud Functions** - Serverless backend logic
- **Firebase Analytics** - User behavior tracking
- **Push Notifications** - FCM integration

### Getting Started with Firebase

1. Navigate to the Firebase project:

   ```bash
   cd firebase
   ```

2. Install dependencies:

   ```bash
   flutter pub get
   ```

3. Configure Firebase:
   - Create a new Firebase project at [Firebase Console](https://console.firebase.google.com/)
   - Add your Flutter app to the project
   - Download and add configuration files:
     - `google-services.json` for Android (place in `android/app/`)
     - `GoogleService-Info.plist` for iOS (place in `ios/Runner/`)

4. Run the application:
   ```bash
   flutter run
   ```

## Supabase Demo

The Supabase implementation demonstrates:

- **Supabase Auth** - Authentication with email, social providers
- **PostgreSQL Database** - Relational database with real-time subscriptions
- **Storage** - File management and CDN
- **Edge Functions** - Serverless Deno functions
- **Row Level Security** - Database-level security policies
- **Real-time Subscriptions** - Live data updates

### Getting Started with Supabase

1. Navigate to the Supabase project:

   ```bash
   cd supabase
   ```

2. Install dependencies:

   ```bash
   flutter pub get
   ```

3. Configure Supabase:
   - Create a new project at [Supabase Dashboard](https://app.supabase.com/)
   - Get your project URL and anon key
   - Add configuration to your app (typically in environment variables or config files)

4. Run the application:
   ```bash
   flutter run
   ```

## Firebase vs Supabase Comparison

| Feature            | Firebase                  | Supabase                     |
| ------------------ | ------------------------- | ---------------------------- |
| **Database**       | NoSQL (Firestore)         | SQL (PostgreSQL)             |
| **Authentication** | Comprehensive social auth | Email + social auth          |
| **Real-time**      | Real-time listeners       | PostgreSQL subscriptions     |
| **Storage**        | Cloud Storage             | S3-compatible storage        |
| **Functions**      | Cloud Functions (Node.js) | Edge Functions (Deno)        |
| **Pricing**        | Pay-as-you-go             | Open source + hosted options |
| **Learning Curve** | Moderate                  | Easier for SQL developers    |

## Features Demonstrated

### Common Features (Both Implementations)

- User authentication and authorization
- CRUD operations with real-time updates
- File upload and management
- Offline support and data synchronization
- Cross-platform compatibility (iOS, Android, Web)

### Firebase Specific Features

- Advanced security rules
- ML Kit integration
- Firebase Analytics
- A/B testing with Remote Config
- Crashlytics for error reporting

### Supabase Specific Features

- SQL queries and joins
- Row Level Security policies
- Database functions and triggers
- PostgREST API auto-generation
- Built-in admin dashboard

## Development Setup

### Prerequisites

- Flutter SDK (3.9.0 or higher)
- Dart SDK
- Android Studio / VS Code
- iOS development setup (for iOS builds)

### Environment Setup

1. Clone this repository
2. Choose your preferred backend (Firebase or Supabase)
3. Follow the specific setup instructions above
4. Configure your backend service
5. Run the demo application

## Learning Resources

### Firebase Resources

- [Firebase Documentation](https://firebase.google.com/docs)
- [FlutterFire Documentation](https://firebase.flutter.dev/)
- [Firebase YouTube Channel](https://www.youtube.com/user/Firebase)

### Supabase Resources

- [Supabase Documentation](https://supabase.com/docs)
- [Supabase Flutter Documentation](https://supabase.com/docs/reference/dart)
- [Supabase YouTube Channel](https://www.youtube.com/c/Supabase)

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request. For major changes, please open an issue first to discuss what you would like to change.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Useful Links

- [Flutter Documentation](https://docs.flutter.dev/)
- [Firebase Console](https://console.firebase.google.com/)
- [Supabase Dashboard](https://app.supabase.com/)
- [Dart Packages](https://pub.dev/)

---

**Note**: This is a demonstration project. For production use, ensure you implement proper security measures, error handling, and follow best practices for your chosen backend service.
