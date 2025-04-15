import 'dart:async';

import 'package:chaty/services/notification_services.dart';
import 'package:chaty/ui/chat_list_screen.dart';
import 'package:chaty/ui/chat_screen.dart';
import 'package:chaty/utils/extensions.dart';
import 'package:chaty/utils/selection_controller.dart';
import 'package:fire_chat/chat_view_screen.dart';
import 'package:fire_chat/message_bubble.dart';
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

  final textEditingController = TextEditingController();
  SelectedController selectedController = SelectedController();
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
                      builder: (context) => ChatViewScreen(
                            user1: _user1Controller.text,
                            user2: _user2Controller.text,
                          )),
                );
              },
              child: const Text("Start Chat"),
            ),
            ElevatedButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ChatListScreen(
                                getnumberOfusers: (numberOfusers) {
                                  numberOfusers.log("Number of users");
                                },
                                currentUserId: _user1Controller.text,
                                chatTileBuilder: ({required chatSummary}) {
                                  return ListTile(
                                    leading: (chatSummary.unreadMessageCount[
                                                        _user1Controller
                                                            .text] ??
                                                    0)
                                                .log(_user1Controller.text) >
                                            0
                                        ? CircleAvatar(
                                            backgroundColor: Colors.red,
                                            radius: 10,
                                            child: Text(
                                              chatSummary.unreadMessageCount[
                                                      _user1Controller.text]
                                                  .toString(),
                                              style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 12),
                                            ),
                                          )
                                        : SizedBox(), // ✅ Show dot if unreadCount > 0,
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => ChatScreen(
                                            intialChatLimit: 15,
                                            senderId: _user1Controller.text,
                                            receiverId: chatSummary.otherUserId,
                                          ),
                                        ),
                                      );
                                    },
                                    title: Text(chatSummary.otherUserId),
                                    subtitle: Text(chatSummary.lastMessage),
                                    trailing: Text(
                                      chatSummary.lastMessageTime
                                          .toLocal()
                                          .timeAgo(),
                                    ),
                                  );
                                },
                              )));
                },
                child: Text('list of messages')),
          ],
        ),
      ),
    );
  }
}
