---
title: "Cài đặt Firebase cho Flutter"
description: "Hướng dẫn cài đặt Firebase cho Flutter"
order: 7
category: "firebase"
---

# Cài đặt Firebase cho Flutter

- Truy cập [firebase.google.com](https://firebase.google.com) và tạo một dự án mới.
- Cài đặt firebase cli [hướng dẫn](https://firebase.google.com/docs/cli)
- Đăng nhập vào firebase cli

```bash
firebase login
```

- Tạo một ứng dụng flutter

```bash
flutter create your_app_name
```

- Cài đặt gói firebase flutter

```bash
cd your_app_name
flutter pub add firebase_core
```

- Thêm đoạn code sau vào main.dart của bạn

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

- Sử dụng flutterfire để quản lý dữ liệu firebase

```bash
# Install the CLI if not already done so
dart pub global activate flutterfire_cli

# Run the `configure` command, select a Firebase project and platforms
flutterfire configure
```

Một file firebase_options.dart sẽ được tạo cho bạn chứa tất cả các tùy chọn cần thiết để khởi tạo.
