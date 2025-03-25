import 'package:fire_chat/pkg/lib/models/message.dart';
import 'package:fire_chat/pkg/lib/services/notification_services.dart';
import 'package:fire_chat/pkg/lib/ui/chat_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:voice_message_package/voice_message_package.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // Initialize Firebase
  await NotificationService().initialize();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chaty Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomeScreen(), // Initial screen
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _user1Controller = TextEditingController();
  final TextEditingController _user2Controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Chaty Example")),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            TextField(
              controller: _user1Controller,
              decoration: const InputDecoration(
                hintText: "Enter your name",
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _user2Controller,
              decoration: const InputDecoration(
                hintText: "Enter another user's name",
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Navigate to ChatScreen with sample data
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChatScreen(
                      intialChatLimit: 15,
                      senderId: _user1Controller.text,
                      receiverId: _user2Controller.text,
                      messageBubbleBuilder: (
                          {required isMe, required message}) {
                        return _MessageBubble(isMe: isMe, message: message);
                      },
                    ),
                  ),
                );
              },
              child: const Text("Start Chat"),
            ),
            VoiceMessageView(
              controller: VoiceController(
                isFile: false,
                maxDuration: Duration(seconds: 10),
                audioSrc:
                    'https://filesamples.com/samples/audio/aac/sample4.aac',
                onComplete: () {
                  /// do something on complete
                },
                onPause: () {
                  /// do something on pause
                },
                onPlaying: () {
                  /// do something on playing
                },
                onError: (err) {
                  /// do somethin on error
                },
              ),
              innerPadding: 12,
              cornerRadius: 20,
            ),
          ],
        ),
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({
    required this.isMe,
    required this.message,
  });
  final bool isMe;
  final Message message;

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.all(10),
        margin: const EdgeInsets.symmetric(vertical: 5),
        decoration: BoxDecoration(
          color: isMe ? Colors.blue : Colors.grey[300],
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (message.mediaUrl != null)
              Image.network(
                message.mediaUrl!,
                width: 200,
                height: 200,
                fit: BoxFit.cover,
              ),
            if (message.text.isNotEmpty)
              Text(
                message.text,
                style: const TextStyle(fontSize: 16),
              ),
            const SizedBox(height: 5),
            Text(
              message.timestamp.toLocal().toString(),
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
