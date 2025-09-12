---
title: "Setup Supabase For Flutter"
description: "How to setup Supabase for Flutter"
order: 1
category: "supabase"
---

# Setup Supabase For Flutter

- Go to [supabase.com](https://supabase.com) and create a new project.
- Create a new project or select an existing one.
- Click button 'Connect' and get url and anon/public key.
- Install supabase flutter package.

```bash
flutter pub add supabase_flutter
```

- Add dotenv package to no push data to git.

```bash
flutter pub add dotenv
```

- Create a .env file in root directory and add your supabase url and anon/public key.

```bash
SUPABASE_URL=https://your-project-ref.supabase.co
SUPABASE_ANON_KEY=your_actual_anon_key
```

- Add .env to assets in pubspec.yaml.

```yaml
flutter:
  assets:
    - .env
```

- Write code to config supabase in main.dart.

```dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");

  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );

  debugPrint('Supabase initialized successfully');

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
           'Supabase Demo', style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Color(0xFF0b1221),
      ),
      body: Center(
          child: Text("Hello World"),
      ),
    )
)
```
