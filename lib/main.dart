import 'package:fire_chat/package/lib/services/chat_service.dart';
import 'package:fire_chat/package/lib/services/notification_services.dart';
import 'package:fire_chat/package/lib/ui/chat_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

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
                      chatId: ChatService().getChatId(
                          _user1Controller.text, _user2Controller.text),
                      senderId: _user1Controller.text,
                      receiverId: _user2Controller.text,
                    ),
                  ),
                );
              },
              child: const Text("Start Chat"),
            ),
          ],
        ),
      ),
    );
  }
}
