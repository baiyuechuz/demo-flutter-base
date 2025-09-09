import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'components/custom_button.dart';

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
            const Text("Hello World", style: TextStyle(color: Colors.white)),
            const SizedBox(height: 20),
            Text(
              "Supabase URL: ${dotenv.env['SUPABASE_URL'] ?? 'Not configured'}",
              style: TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 40),
            // Example usage of the custom button component
            CustomGradientButton(
              text: "Click Me!",
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Button pressed!')),
                );
              },
            ),
            const SizedBox(height: 20),
            CustomGradientButton(
              text: "Custom Width",
              width: 250,
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Custom width button pressed!')),
                );
              },
            ),
            const SizedBox(height: 20),
            CustomGradientButton(
              text: "Disabled",
              onPressed: null, // Disabled button
            ),
          ],
        ),
      ),
    );
  }
}
