import 'package:aichatbot/screens/homepage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_gemini/flutter_gemini.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await dotenv.load(fileName: ".env"); // Load the .env file
  } catch (e) {
    print("Error loading .env file: $e");
  }

  Gemini.init(apiKey: dotenv.env['GEMINI_API_KEY']!); // Use the API key

  runApp(const MainApp());
}
class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Gemini ChatBot',
      home: HomePage(),
    );
  }
}
