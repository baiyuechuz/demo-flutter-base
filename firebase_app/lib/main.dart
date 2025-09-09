import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_core/firebase_core.dart';
import 'components/custom_button.dart';
import 'pages/authentication.dart';
import 'pages/database.dart';
import 'pages/realtime_database.dart';
import 'pages/storage.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");

  await Firebase.initializeApp(
    options: FirebaseOptions(
      apiKey: dotenv.env['FIREBASE_API_KEY']!,
      authDomain: dotenv.env['FIREBASE_AUTH_DOMAIN']!,
      projectId: dotenv.env['FIREBASE_PROJECT_ID']!,
      storageBucket: dotenv.env['FIREBASE_STORAGE_BUCKET']!,
      messagingSenderId: dotenv.env['FIREBASE_MESSAGING_SENDER_ID']!,
      appId: dotenv.env['FIREBASE_APP_ID']!,
      databaseURL: dotenv.env['FIREBASE_DATABASE_URL'],
      measurementId: dotenv.env['FIREBASE_MEASUREMENT_ID'],
    ),
  );

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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Select a button to see feature demo",
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
            const SizedBox(height: 20),
            CustomGradientButton(
              text: "Database",
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const DatabasePage()),
                );
              },
            ),
            const SizedBox(height: 20),
            CustomGradientButton(
              text: "Realtime Database",
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const RealtimeDatabasePage(),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
            CustomGradientButton(
              text: "Storage",
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const StoragePage()),
                );
              },
            ),
            const SizedBox(height: 20),
            CustomGradientButton(
              text: "Authentication",
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AuthenticationPage(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
