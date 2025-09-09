import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'components/custom_button.dart';
import 'pages/authentication.dart';
import 'pages/database.dart';
import 'pages/realtime_database.dart';
import 'pages/storage.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  await dotenv.load(fileName: ".env");

  // Initialize Supabase with environment variables
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
          'Supabase Demo',
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
