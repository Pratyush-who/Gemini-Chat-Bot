import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  List<ChatMessage> messages = <ChatMessage>[];

  ChatUser currentUser = ChatUser(firstName: 'User', id: '0');
  ChatUser geminiUser = ChatUser(
    firstName: 'Gemini',
    id: '1',
    profileImage: 'assets/gemini.png',
  );
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Gemini Chat')),
      body: DashChat(
        currentUser: currentUser,
        onSend: sendMessage,
        messages: messages,
      ),
    );
  }

  void sendMessage(ChatMessage chatMessage) {
    setState(() {
    });
  }
}
