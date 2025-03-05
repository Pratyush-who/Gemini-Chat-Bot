import 'dart:io';
import 'dart:typed_data';
import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

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
      backgroundColor: const Color.fromRGBO(27, 27, 27, 1),
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(34, 38, 41, 1),
        elevation: 0,
        centerTitle: true,
        leading: Image.asset('assets/logo.png', height: 24, width: 24),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Gemini Chat',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(color: Color.fromRGBO(27, 27, 27, 1)),
        child: DashChat(
          currentUser: currentUser,
          onSend: sendMessage,
          messages: messages,
          inputOptions: InputOptions(
            inputDecoration: InputDecoration(
              hintText: "Ask Gemini something...",
              hintStyle: const TextStyle(color: Colors.grey),
              filled: true,
              fillColor: const Color.fromRGBO(34, 38, 41, 0.7),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(24),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 10,
              ),
            ),
            sendButtonBuilder: (onSend) {
              return IconButton(
                icon: const Icon(
                  Icons.send_rounded,
                  color: Color.fromRGBO(90, 216, 255, 1),
                ),
                onPressed: onSend,
              );
            },
            trailing: [
              IconButton(
                icon: const Icon(
                  Icons.image_rounded,
                  color: Color.fromRGBO(90, 216, 255, 1),
                ),
                onPressed: () {
                  voidSendMediaMessage();
                },
              ),
            ],
            inputToolbarStyle: BoxDecoration(
              color: const Color.fromRGBO(34, 38, 41, 0.5),
              borderRadius: BorderRadius.circular(0),
            ),
          ),
          messageOptions: MessageOptions(
            showTime: true,
            timePadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            timeFormat: DateFormat('HH:mm'),
            messageDecorationBuilder: (message, previousMessage, nextMessage) {
              bool isUser = message.user.id == currentUser.id;
              return BoxDecoration(
                color:
                    isUser
                        ? const Color.fromRGBO(90, 216, 255, 1)
                        : const Color.fromRGBO(34, 38, 41, 1),
                borderRadius: BorderRadius.circular(16),
              );
            },
            messageTextBuilder: (message, previousMessage, nextMessage) {
              bool isUser = message.user.id == currentUser.id;
              return Text(
                message.text,
                style: TextStyle(
                  color: isUser ? Colors.black : Colors.white,
                  fontSize: 16,
                ),
              );
            },
            avatarBuilder: (user, onPress, longPress) {
              if (user.id == geminiUser.id) {
                return CircleAvatar(
                  backgroundColor: const Color.fromRGBO(27, 27, 27, 1),
                  child: ClipOval(
                    child: Image.asset(
                      'assets/logo.png',
                      width: 40,
                      height: 40,
                      fit: BoxFit.cover,
                    ),
                  ),
                );
              }
              return CircleAvatar(
                backgroundColor: const Color.fromRGBO(90, 216, 255, 1),
                child: Text(
                  user.firstName![0],
                  style: const TextStyle(color: Colors.black),
                ),
              );
            },
            containerColor: const Color.fromRGBO(27, 27, 27, 1),
            messagePadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),
              // currentUserContainerPadding: const EdgeInsets.only(
              //   left: 48,
              //   right: 8,
              // ),
              // otherUserContainerPadding: const EdgeInsets.only(
              //   left: 8,
              //   right: 48,
              // ),
          ),
        ),
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
            event.content?.parts
                ?.map((part) {
                  if (part is TextPart) return part.text;
                  return ""; // Handle non-text parts gracefully
                })
                .join(" ") ??
            "";

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
