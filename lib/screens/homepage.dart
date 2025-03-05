import 'dart:io';
import 'dart:typed_data';
import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:image_picker/image_picker.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final Gemini gemini = Gemini.instance;
  List<ChatMessage> messages = <ChatMessage>[];

  ChatUser currentUser = ChatUser(firstName: 'User', id: '0');
  ChatUser geminiUser = ChatUser(
    firstName: 'Gemini',
    id: '1',
    profileImage: 'assets/logo.png',
  );
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Gemini Chat')),
      body: DashChat(
        inputOptions: InputOptions(
          trailing: [
            IconButton(
              icon: Icon(Icons.image),
              onPressed: () {
                voidSendMediaMessage();
              },
            ),
            ],
        ),
        currentUser: currentUser,
        onSend: sendMessage,
        messages: messages,
      ),
    );
  }

  void sendMessage(ChatMessage chatMessage) {
  setState(() {
    messages = [chatMessage, ...messages];
  });

  try {
    String question = chatMessage.text;
    List<Uint8List> images = [];

    if (chatMessage.medias?.isNotEmpty ?? false) {
      images = [File(chatMessage.medias!.first.url).readAsBytesSync()];
    }

    gemini.streamGenerateContent(question, images: images).listen((event) {
      // Extract text properly
      String response =
          event.content?.parts?.map((part) {
            if (part is TextPart) return part.text;
            return ""; // Handle non-text parts gracefully
          }).join(" ") ?? "";

      ChatMessage? lastMessage = messages.isNotEmpty ? messages.first : null;

      if (lastMessage != null && lastMessage.user == geminiUser) {
        messages.removeAt(0); // Remove from list before modifying
        lastMessage.text += " $response";
        setState(() {
          messages = [lastMessage, ...messages];
        });
      } else {
        ChatMessage message = ChatMessage(
          text: response,
          user: geminiUser,
          createdAt: DateTime.now(),
        );
        setState(() {
          messages = [message, ...messages];
        });
      }
    });
  } catch (e) {
    print("Error: $e");
  }
}

  voidSendMediaMessage() async {
    ImagePicker picker = ImagePicker();
    XFile? file = await picker.pickImage(source: ImageSource.gallery);
    if (file != null) {
      ChatMessage chatMessage = ChatMessage(
        user: currentUser,
        createdAt: DateTime.now(),
        text: "Description of the image",
        medias: [
          ChatMedia(url: file.path, fileName: '', type: MediaType.image),
        ],
      );
      sendMessage(chatMessage);
    }
  }
}
