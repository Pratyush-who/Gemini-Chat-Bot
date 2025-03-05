import 'package:aichatbot/const.dart';
import 'package:aichatbot/screens/homepage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_gemini/flutter_gemini.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(); // Load environment variables
  Gemini.init(apiKey: dotenv.env['GEMINI_API_KEY']!);
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
