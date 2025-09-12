---
title: "Setup Firebase For Flutter"
description: "How to setup Firebase for Flutter"
order: 7
category: "firebase"
---

# Setup Firebase For Flutter

- Go to [firebase.google.com](https://firebase.google.com) and create a new project.
- Install firebase cli [manual](https://firebase.google.com/docs/cli)
- Login to firebase cli

```bash
firebase login
```

- Create a app flutter

```bash
flutter create your_app_name
```

- Install firebase flutter package

```bash
cd your_app_name
flutter pub add firebase_core
```

- Add this following code to your main.dart

```dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  debugPrint('Firebase initialized successfully');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Firebase Demo',
          style: TextStyle(color: Colors.white),
        ),
          backgroundColor: Color(0xFF0b1221),
      ),
      backgroundColor: Color(0xFF0b1221),
      body: Center(
        child: Text("Hello World"),
      ),
    );
  }
}
```

- Use flutterfire to manage my firebase data

```bash
# Install the CLI if not already done so
dart pub global activate flutterfire_cli

# Run the `configure` command, select a Firebase project and platforms
flutterfire configure
```

A firebase_options.dart file will be generated for you containing all the options required for initialization.
