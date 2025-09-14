---
title: "Cài đặt Supabase cho Flutter"
description: "Hướng dẫn cài đặt Supabase cho Flutter"
order: 1
category: "supabase"
---

# Cài đặt Supabase cho Flutter

- Truy cập [supabase.com](https://supabase.com) và tạo một dự án mới.
- Tạo một dự án mới hoặc chọn một dự án đã có.
- Nhấn nút 'Connect' và lấy url cùng anon/public key.
- Cài đặt gói supabase flutter.

```bash
flutter pub add supabase_flutter
```

- Thêm gói dotenv để không đẩy dữ liệu lên git.

```bash
flutter pub add dotenv
```

- Tạo file .env trong thư mục gốc và thêm url supabase cùng anon/public key của bạn.

```bash
SUPABASE_URL=https://your-project-ref.supabase.co
SUPABASE_ANON_KEY=your_actual_anon_key
```

- Thêm .env vào assets trong pubspec.yaml.

```yaml
flutter:
  assets:
    - .env
```

- Viết code để cấu hình supabase trong main.dart.

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

